/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTimedWait.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/21/17 7:21 PM
 * DESCRIPTION: This class is based on the work done by Keith Shortridge with
 *              the Australian Astronomical Observatory (AAO) who created a
 *              drop-in implementation of sem_timedwait() that was missing from
 *              Apple's OS X operating system.  His implementation can be found
 *              here https://github.com/attie/libxbee3/blob/master/xsys_darwin/sem_timedwait.c
 *
 *
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 * Copyright © 2013 Australian Astronomical Observatory (AAO).
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

#import "PGTimedWait.h"
#import "PGTimeSpec.h"

#import <pthread.h>

@interface PGTimedWait()

	-(void)wait;

	-(void)cleanup;

@end

static void ignoreSignal(int _signal) {
	_signal = 0;
}

static void threadCleanup(void *obj) {
	[((__bridge_transfer PGTimedWait *)obj) cleanup];
}

static void *objectThread(void *obj) {
	[((__bridge_transfer PGTimedWait *)obj) wait];
	return NULL;
}

@implementation PGTimedWait {
		pthread_t _thread1;
		pthread_t _thread2;
		// struct sigaction _action; // This may go away since we're not using it.
	}

	@synthesize timedOut = _timedOut;
	@synthesize inUse = _inUse;
	@synthesize absTime = _absTime;

	-(instancetype)initWithTimeout:(PGTimeSpec *)absTime {
		self = [super init];

		if(self) {
			_absTime  = [absTime copy];
			_thread1  = (pthread_t)0;
			_thread2  = (pthread_t)0;
			_timedOut = NO;
			_inUse    = NO;
		}

		return self;
	}

	-(void)dealloc {
		_thread1 = (pthread_t)0;
		_thread2 = (pthread_t)0;
	}

	-(BOOL)timedAction:(id *)actionResults {
		@synchronized(self) {
			BOOL       success   = NO;
			PGTimeSpec *waitTime = self.absTime.remainingTimeFromAbsoluteTime;

			if(waitTime) {
				_inUse   = YES;
				_thread1 = pthread_self();

				NSException *e         = nil;
				id          results    = nil;
				int         savedState = 0;

				#pragma clang diagnostic push
				#pragma clang diagnostic ignored "-Wreturn-stack-address"
				pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &savedState);
				pthread_cleanup_push(threadCleanup, (__bridge_retained void *)self);

					if([self launchWaitingThread:savedState]) {
						/*
						 * We'll catch any thrown exception so that we can
						 * rethrow it after the stack is cleaned up.
						 */
						@try {
							success = [self action:actionResults];
						}
						@catch(NSException *e1) {
							e = e1;
						}
					}

				pthread_cleanup_pop(1);
				#pragma clang diagnostic pop

				_inUse   = NO;
				_thread1 = (pthread_t)0;
				_thread2 = (pthread_t)0;
				if(e) @throw e;
				if(actionResults) *actionResults = results;
			}

			return success;
		}
	}

	-(BOOL)launchWaitingThread:(int)savedState {
		int aState   = 0;
		int threadOK = pthread_create(&_thread2, NULL, objectThread, (__bridge_retained void *)self);
		pthread_setcancelstate(savedState, &aState);
		return (threadOK >= 0);
	}

	-(BOOL)action:(id *)results {
		*results = NULL;
		return YES;
	}

	-(void)wait {
		if(_thread1) {
			struct timespec requestedDelay = self.absTime.remainingTimeFromAbsoluteTime.toUnixTimeSpec;
			struct timespec remainingDelay = { .tv_sec = 0, .tv_nsec = 0 };

			for(;;) {
				if(nanosleep(&requestedDelay, &remainingDelay) == 0) {
					break;
				}
				else if(errno == EINTR) {
					requestedDelay = remainingDelay;
				}
				else {
					break;
				}
			}

			[self signalAction];
		}
	}

	-(void)signalAction {
		if(pthread_kill(_thread1, 0) == 0) {
			struct sigaction siginfo;
			siginfo.sa_handler = ignoreSignal;
			siginfo.sa_flags   = 0;

			_timedOut = YES;
			sigemptyset(&siginfo.sa_mask);

			if(sigaction(SIGUSR2, &siginfo, NULL) == 0) {
				pthread_kill(_thread1, SIGUSR2);
			}
		}
	}

	-(void)cleanup {
		if(!self.timedOut) pthread_cancel(_thread2);
		pthread_join(_thread2, NULL);
	}

@end
