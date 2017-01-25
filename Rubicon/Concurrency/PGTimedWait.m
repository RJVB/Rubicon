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

#import <Rubicon/Rubicon.h>
#import <pthread.h>

void ignoreSignal(int _signal);

void threadCleanup(void *obj);

void *waitThread(void *obj);

@interface PGTimedWait()

	@property(atomic) pthread_t                  thread1;
	@property(atomic) pthread_t                  thread2;
	@property(atomic, readonly, retain) NSString *lock1;

	-(void)wait;

	-(void)cleanup;

	-(void)setDidTimeOut:(BOOL)timedOut;

	-(void)setAbsTime:(PGTimeSpec *)absTime;

@end

@implementation PGTimedWait {
		volatile BOOL _didTimeOut;
		volatile int  _oserrno;
	}

	@synthesize absTime = _absTime;
	@synthesize thread1 = _thread1;
	@synthesize thread2 = _thread2;
	@synthesize lock1 = _lock1;

	-(instancetype)initWithTimeout:(PGTimeSpec *)absTime {
		self = [super init];

		if(self) {
			_lock1   = @"SomethingToLock1";
			_oserrno = 0;

			self.absTime    = absTime;
			self.didTimeOut = NO;
			self.thread1    = (pthread_t)0;
			self.thread2    = (pthread_t)0;
		}

		return self;
	}

	-(void)dealloc {
		self.thread1 = (pthread_t)0;
		self.thread2 = (pthread_t)0;
	}

	-(void)setAbsTime:(PGTimeSpec *)absTime {
		_absTime = [absTime copy];
	}

	-(void)createWaitThread {
		self.thread1 = pthread_self();

		int results = pthread_create(&_thread2, NULL, waitThread, (__bridge_retained void *)self);

		if(results) {
			@throw [NSException exceptionWithName:@"PGTimedWaitException" reason:[NSString stringWithUTF8String:strerror(results)] userInfo:nil];
		}
	}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-stack-address"

	-(BOOL)timedAction:(id *)results {
		@synchronized(self) {
			int         savedState    = 0;
			int         ignoredState  = 0;
			id          actionResults = nil;
			BOOL        success       = NO;
			NSException *caught       = nil;

			pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &savedState);
			pthread_cleanup_push(threadCleanup, (__bridge_retained void *)self);

				[self createWaitThread];
				pthread_setcancelstate(savedState, &ignoredState);

				@try {
					success = [self action:&actionResults];
				}
				@catch(NSException *e) {
					caught = e;
				}

			pthread_cleanup_pop(1);

			if(caught) @throw caught;
			return !self.didTimeOut;
		}
	}

#pragma clang diagnostic pop

	-(BOOL)action:(id *)results {
		*results = NULL;
		return YES;
	}

	-(void)signalAction {
	}

	-(void)wait {
		if(self.thread1) {
			PGTimeSpec *waitTime = self.absTime.remainingTimeFromAbsoluteTime;

			if(waitTime) {
				TimeSpec sWaitTime = waitTime.toUnixTimeSpec;
				TimeSpec sRemTime;
				BOOL     waiting   = YES;

				while(waiting) {
					waiting = (nanosleep(&sWaitTime, &sRemTime) != 0);

					if(waiting) {
						if(errno == EINTR) {
							sWaitTime = sRemTime;
						}
						else {
							waiting = NO;
						}
					}
				}
			}
		}
	}

	-(void)cleanup {
		if(self.thread2) {
			if(!self.didTimeOut) pthread_cancel(self.thread2);
			pthread_join(self.thread2, NULL);
			self.thread2 = (pthread_t)0;
		}
	}

	-(BOOL)didTimeOut {
		@synchronized(self.lock1) {
			return _didTimeOut;
		}
	}

	-(void)setDidTimeOut:(BOOL)timedOut {
		@synchronized(self.lock1) {
			_didTimeOut = timedOut;
		}
	}

@end

void ignoreSignal(int _signal) {
	_signal = 0;
}

void threadCleanup(void *obj) {
	[((__bridge_transfer PGTimedWait *)obj) cleanup];
}

void *waitThread(void *obj) {
	[((__bridge_transfer PGTimedWait *)obj) wait];
	return NULL;
}

