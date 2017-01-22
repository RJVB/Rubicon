/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: pthread_rwlock_timedrdlock.c
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 01/19/17 8:19 PM
 * DESCRIPTION:
 *
 * Copyright © 2016 Galen Rhodes All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *******************************************************************************/

#ifdef __APPLE__
#include "pthread_rwlock_timedrdlock.h"

#include <sys/time.h>
#include <errno.h>
#include <signal.h>

/*
 *  A structure of type timeoutDetails is passed to the thread used to
 *  implement the timeout.
 */

typedef struct {
	struct timespec delay;          /* Specifies the delay, relative to now */
	pthread_t       callingThread;  /* The thread doing the sem_wait call */
	volatile short  *timedOutShort; /* Address of a flag set to indicate that the timeout was triggered. */
} timeoutDetails;

/*  A structure of type cleanupDetails is passed to the thread cleanup
 *  routine which is called at the end of the routine or if the thread calling
 *  it is cancelled.
 */

typedef struct {
	pthread_t        *threadIdAddr;   /* Address of the variable that holds the Id of the timeout thread. */
	struct sigaction *sigHandlerAddr; /* Address of the old signal action handler. */
	volatile short   *timedOutShort;  /* Address of a flag set to indicate that the timeout was triggered. */
} cleanupDetails;

/*  Forward declarations of internal routines */

int _sem_timedwait(sem_t *sem, const struct timespec *waitTime);

int _pthread_rwlock_timedrdlock(pthread_rwlock_t *rwlock, const struct timespec *waitTime);

int _pthread_rwlock_timedwrlock(pthread_rwlock_t *rwlock, const struct timespec *waitTime);

static void *timeoutThreadMain(void *passedPtr);

static int triggerSignal(int Signal, pthread_t Thread);

static void ignoreSignal(int Signal);

static void timeoutThreadCleanup(void *passedPtr);

static int normalizeTimeout(const struct timespec *abstime, struct timespec *deltatime);

/* -------------------------------------------------------------------------- */
/*
 *              p t h r e a d _ r w l o c k _ t i m e d r d l o c k
 *
 *  This is the main code for the pthread_rwlock_timedrdlock() implementation.
 */
int pthread_rwlock_timedrdlock(pthread_rwlock_t *rwlock, const struct timespec *abstime) {
	struct timespec dt;
	int             r = pthread_rwlock_tryrdlock(rwlock);
	return ((r == 0) ? 0 : ((r != EBUSY) ? (errno = r) : (normalizeTimeout(abstime, &dt) ? errno : _pthread_rwlock_timedrdlock(rwlock, &dt))));
}

/* -------------------------------------------------------------------------- */
/*
 *               p t h r e a d _ r w l o c k _ t i m e d w r l o c k
 *
 *  This is the main code for the pthread_rwlock_timedrdlock() implementation.
 */
int pthread_rwlock_timedwrlock(pthread_rwlock_t *rwlock, const struct timespec *abstime) {
	struct timespec dt;
	int             r = pthread_rwlock_trywrlock(rwlock);
	return ((r == 0) ? 0 : ((r != EBUSY) ? (errno = r) : (normalizeTimeout(abstime, &dt) ? errno : _pthread_rwlock_timedwrlock(rwlock, &dt))));
}

/* -------------------------------------------------------------------------- */
/*
 *                      s e m _ t i m e d w a i t
 *
 *  This is the main code for the sem_timedwait() implementation.
 */
int sem_timedwait(sem_t *sem, const struct timespec *abstime) {
	struct timespec dt;
	return ((sem_trywait(sem) == 0) ? 0 : ((errno != EAGAIN) ? -1 : (normalizeTimeout(abstime, &dt) ? -1 : _sem_timedwait(sem, &dt))));
}

static int normalizeTimeout(const struct timespec *abstime, struct timespec *deltatime) {
	if((abstime->tv_nsec < 0) || (abstime->tv_nsec > 1000000000)) {
		return (errno = EINVAL);
	}
	else {
		struct timeval currentTime; /* Time now */
		gettimeofday(&currentTime, NULL);
		deltatime->tv_sec  = abstime->tv_sec - currentTime.tv_sec;
		deltatime->tv_nsec = (abstime->tv_nsec - (currentTime.tv_usec * 1000));

		while(deltatime->tv_nsec < 0) {
			deltatime->tv_nsec += 1000000000;
			deltatime->tv_sec--;
		}

		return (((deltatime->tv_sec < 0) || ((deltatime->tv_sec == 0) && (deltatime->tv_nsec < 0))) ? (errno = ETIMEDOUT) : 0);
	}
}

/* -------------------------------------------------------------------------- */
/*
 *                  t i m e o u t  T h r e a d  C l e a n u p
 *
 *  This internal routine tidies up at the end of a sem_timedwait() call.
 *  It is set as a cleanup routine for the current thread (not the timer
 *  thread) so it is executed even if the thread is cancelled. This is
 *  important, as we need to tidy up the timeout thread. If we took the
 *  semaphore (in other words, if we didn't timeout) then the timer thread
 *  will still be running, sitting in its nanosleep() call, and we need
 *  to cancel it. If the timer thread did signal a timeout then it will
 *  now be closing down. In either case, we need to join it (using a call
 *  to pthread_join()) or its resources will never be released.
 *  The single argument is a pointer to a cleanupDetails structure that has
 *  all the routine needs to know.
 */

static void timeoutThreadCleanup(void *passedPtr) {
	/*  Get what we need from the structure we've been passed. */

	cleanupDetails *detailsPtr   = (cleanupDetails *)passedPtr;
	short          timedOut      = *(detailsPtr->timedOutShort);
	pthread_t      timeoutThread = *(detailsPtr->threadIdAddr);

	/*  If we created the thread, stop it - doesn't matter if it's no longer
	 *  running, pthread_cancel can handle that. We make sure we wait for it
	 *  to complete, because it is this pthread_join() call that releases any
	 *  memory the thread may have allocated. Note that cancelling a thread is
	 *  generally not a good idea, because of the difficulty of cleaning up
	 *  after it, but this is a very simple thread that does nothing but call
	 *  nanosleep(), and that we can cancel quite happily.
	 */

	if(!timedOut) pthread_cancel(timeoutThread);
	pthread_join(timeoutThread, NULL);

	/*  The code originally restored the old action handler, which generally
	 *  was the default handler that caused the task to exit. Just occasionally,
	 *  there seem to be cases where the signal is still queued and ready to
	 *  trigger even though the thread that presumably sent it off just before
	 *  it was cancelled has finished. I had thought that once we'd joined
	 *  that thread, we could be sure of not seeing the signal, but that seems
	 *  not to be the case, and so restoring a handler that will allow the task
	 *  to crash is not a good idea, and so the line below has been commented
	 *  out.
	 *
	 *  sigaction (SIGUSR2,detailsPtr->sigHandlerAddr,NULL);
	 */
}

/* -------------------------------------------------------------------------- */
/*
 *                  t i m e o u t  T h r e a d  M a i n
 *
 *  This internal routine is the main code for the timeout thread.
 *  The single argument is a pointer to a timeoutDetails structure that has
 *  all the thread needs to know - thread to signal, delay time, and the
 *  address of a flag to set if it triggers a timeout.
 */

static void *timeoutThreadMain(void *passedPtr) {
	void *Return = (void *)0;

	/*  We grab all the data held in the calling thread right now. In some
	 *  cases, we find that the calling thread has vanished and released
	 *  its memory, including the details structure, by the time the timeout
	 *  expires, and then we get an access violation when we try to set the
	 *  'timed out' flag.
	 */

	timeoutDetails  details        = *((timeoutDetails *)passedPtr);
	struct timespec requestedDelay = details.delay;

	/*  We do a nanosleep() for the specified delay, and then trigger a
	 *  timeout. Note that we allow for the case where the nanosleep() is
	 *  interrupted, and restart it for the remaining time. If the
	 *  thread that is doing the sem_wait() call gets the semaphore, it
	 *  will cancel this thread, which is fine as we aren't doing anything
	 *  other than a sleep and a signal.
	 */

	for(;;) {
		struct timespec remainingDelay;
		if(nanosleep(&requestedDelay, &remainingDelay) == 0) {
			break;
		}
		else if(errno == EINTR) {
			requestedDelay = remainingDelay;
		}
		else {
			Return = (void *)(long)errno;
			break;
		}
	}

	/*  We've completed the delay without being cancelled, so we now trigger
	 *  the timeout by sending a signal to the calling thread. And that's it,
	 *  although we set the timeout flag first to indicate that it was us
	 *  that interrupted the sem_wait() call. One precaution: before we
	 *  try to set the timed-out flag, make sure the calling thread still
	 *  exists - this may not be the case if things are closing down a bit
	 *  messily. We check this quickly using a zero test signal.
	 */

	if(pthread_kill(details.callingThread, 0) == 0) {
		*(details.timedOutShort) = 1;

		if(triggerSignal(SIGUSR2, details.callingThread) < 0) {
			Return = (void *)(long)errno;
		}
	}

	return Return;
}

/* -------------------------------------------------------------------------- */
/*
 *                    t r i g g e r  S i g n a l
 *
 *  This is a general purpose routine that sends a specified signal to
 *  a specified thread, setting up a signal handler that does nothing,
 *  and then giving the signal. The only effect will be to interrupt any
 *  operation that is currently blocking - in this case, we expect this to
 *  be a sem_wait() call.
 */

static int triggerSignal(int Signal, pthread_t Thread) {
	int              Result = 0;
	struct sigaction SignalDetails;

	SignalDetails.sa_handler = ignoreSignal;
	SignalDetails.sa_flags   = 0;

	(void)sigemptyset(&SignalDetails.sa_mask);

	if((Result = sigaction(Signal, &SignalDetails, NULL)) == 0) {
		Result = pthread_kill(Thread, Signal);
	}

	return Result;
}

/* -------------------------------------------------------------------------- */
#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnusedValue"
#pragma clang diagnostic ignored "-Wunused-parameter"

/*
 *                     i g n o r e  S i g n a l
 *
 *  And this is the signal handler that does nothing. (It clears its argument,
 *  but this has no effect and prevents a compiler warning about an unused
 *  argument.)
 */
static void ignoreSignal(int Signal) {
	Signal = 0;
}

int _sem_timedwait(sem_t *sem, const struct timespec *waitTime) {
	int              result = 0;        /* Code returned by this routine 0 or -1 */
	volatile short   timedOut;          /* Flag to set on timeout */
	timeoutDetails   details;           /* All the stuff the thread must know */
	struct sigaction oldSignalAction;   /* Current signal setting */
	pthread_t        timeoutThread;     /* Id of timeout thread */
	cleanupDetails   cleaningDetails;   /* What the cleanup routine needs */
	int              oldCancelState;    /* Previous cancellation state */
	int              ignoreCancelState; /* Used in call, but ignored */
	int              createStatus;      /* Status of pthread_create() call */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-stack-address"
	pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &oldCancelState);
	timeoutThread = (pthread_t)0;
	cleaningDetails.timedOutShort  = &timedOut;
	cleaningDetails.threadIdAddr   = &timeoutThread;
	cleaningDetails.sigHandlerAddr = &oldSignalAction;
	pthread_cleanup_push(timeoutThreadCleanup, &cleaningDetails);

		details.delay         = (*waitTime);
		details.callingThread = pthread_self();
		details.timedOutShort = &timedOut;
		timedOut = 0;
		sigaction(SIGUSR2, NULL, &oldSignalAction);

		createStatus = pthread_create(&timeoutThread, NULL, timeoutThreadMain, (void *)&details);
		pthread_setcancelstate(oldCancelState, &ignoreCancelState);

		if(createStatus < 0) {
			result = -1;
		}
		else {
			result = ((sem_wait(sem) == 0) ? 0 : -1);
			if(result && timedOut && (errno == EINTR)) errno = ETIMEDOUT;
		}

	pthread_cleanup_pop(1);
#pragma clang diagnostic pop
	return (result);
}

int _pthread_rwlock_timedrdlock(pthread_rwlock_t *rwlock, const struct timespec *waitTime) {
	volatile short   timedOut;          /* Flag to set on timeout */
	timeoutDetails   details;           /* All the stuff the thread must know */
	struct sigaction oldSignalAction;   /* Current signal setting */
	pthread_t        timeoutThread;     /* Id of timeout thread */
	cleanupDetails   cleaningDetails;   /* What the cleanup routine needs */
	int              oldCancelState;    /* Previous cancellation state */
	int              ignoreCancelState; /* Used in call, but ignored */
	int              createStatus;      /* Status of pthread_create() call */
	int              result = 0;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-stack-address"
	pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &oldCancelState);
	timeoutThread = (pthread_t)0;
	cleaningDetails.timedOutShort  = &timedOut;
	cleaningDetails.threadIdAddr   = &timeoutThread;
	cleaningDetails.sigHandlerAddr = &oldSignalAction;
	pthread_cleanup_push(timeoutThreadCleanup, &cleaningDetails);

		details.delay         = (*waitTime);
		details.callingThread = pthread_self();
		details.timedOutShort = &timedOut;
		timedOut = 0;
		sigaction(SIGUSR2, NULL, &oldSignalAction);

		createStatus = pthread_create(&timeoutThread, NULL, timeoutThreadMain, (void *)&details);
		pthread_setcancelstate(oldCancelState, &ignoreCancelState);

		if(createStatus < 0) {
			result = errno;
		}
		else {
			result = pthread_rwlock_rdlock(rwlock);
			if(result && timedOut && (result == EINTR)) result = ETIMEDOUT;
		}

	pthread_cleanup_pop(1);
#pragma clang diagnostic pop
	return (errno = result);
}

int _pthread_rwlock_timedwrlock(pthread_rwlock_t *rwlock, const struct timespec *waitTime) {
	volatile short   timedOut;          /* Flag to set on timeout */
	timeoutDetails   details;           /* All the stuff the thread must know */
	struct sigaction oldSignalAction;   /* Current signal setting */
	pthread_t        timeoutThread;     /* Id of timeout thread */
	cleanupDetails   cleaningDetails;   /* What the cleanup routine needs */
	int              oldCancelState;    /* Previous cancellation state */
	int              ignoreCancelState; /* Used in call, but ignored */
	int              createStatus;      /* Status of pthread_create() call */
	int              result = 0;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-stack-address"
	pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &oldCancelState);
	timeoutThread = (pthread_t)0;
	cleaningDetails.timedOutShort  = &timedOut;
	cleaningDetails.threadIdAddr   = &timeoutThread;
	cleaningDetails.sigHandlerAddr = &oldSignalAction;
	pthread_cleanup_push(timeoutThreadCleanup, &cleaningDetails);

		details.delay         = (*waitTime);
		details.callingThread = pthread_self();
		details.timedOutShort = &timedOut;
		timedOut = 0;
		sigaction(SIGUSR2, NULL, &oldSignalAction);

		createStatus = pthread_create(&timeoutThread, NULL, timeoutThreadMain, (void *)&details);
		pthread_setcancelstate(oldCancelState, &ignoreCancelState);

		if(createStatus < 0) {
			result = errno;
		}
		else {
			result = pthread_rwlock_wrlock(rwlock);
			if(result && timedOut && (result == EINTR)) result = ETIMEDOUT;
		}

	pthread_cleanup_pop(1);
#pragma clang diagnostic pop
	return (errno = result);
}

#pragma clang diagnostic pop

#endif
