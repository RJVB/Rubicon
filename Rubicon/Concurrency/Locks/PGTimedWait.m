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

#include <pthread.h>
#import "PGTimedWait.h"

void ignoreSignal(int _signal);

void threadCleanup(void *obj);

void *waitThread(void *obj);

@interface PGTimedWait()

    -(NSInteger)wait;

    -(void)cleanup;

@end

@implementation PGTimedWait {
        pthread_t     _thread1;
        pthread_t     _thread2;
        volatile BOOL _didTimeOut;
    }

    @synthesize absTime = _absTime;

    -(instancetype)initWithTimeout:(PGTimeSpec *)absTime {
        self = [super init];

        if(self) {
            _didTimeOut = NO;
            _absTime    = [absTime copy];
        }

        return self;
    }

    -(NSInteger)signalAction {
        struct sigaction sigAction;
        sigAction.sa_handler = ignoreSignal;
        sigAction.sa_flags   = 0;
        sigemptyset(&sigAction.sa_mask);
        NSInteger success = sigaction(SIGUSR2, &sigAction, NULL);
        return (success ? success : pthread_kill(_thread1, SIGUSR2));
    }

    -(BOOL)action:(id *)results {
        if(results) *results = nil;
        return YES;
    }

    -(BOOL)timedAction {
        return [self timedAction:nil];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-stack-address"

    -(BOOL)timedAction:(id *)results {
        @synchronized(self) {
            _didTimeOut = 0;

            id          actionResults = nil;
            int         savedState    = 0;
            BOOL        success       = NO;
            NSException *exception    = nil;

            _thread1 = pthread_self();
            pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &savedState);
            pthread_cleanup_push(threadCleanup, (__bridge void *)self);

                success = [self timedAction:&actionResults savedState:savedState exception:&exception];

            pthread_cleanup_pop(1);
            if((exception != nil) && !success) @throw exception;
            if(results) *results = actionResults;
            return success;
        }
    }

#pragma clang diagnostic pop

    -(BOOL)timedAction:(id *)results savedState:(int)savedState exception:(NSException **)exception {
        BOOL success = (pthread_create(&_thread2, NULL, waitThread, (__bridge void *)self) == 0);
        pthread_setcancelstate(savedState, NULL);

        if(success) {
            @try {
                success = [self action:results];
            }
            @catch(NSException *caughtException) {
                success = NO;
                *exception = caughtException;
            }
        }

        return success;
    }

    -(NSInteger)wait {
        NSInteger  errorNo   = 0;
        PGTimeSpec *waitTime = self.absTime.remainingTimeFromAbsoluteTime;

        if(waitTime) {
            TimeSpec sWaitTime = waitTime.toUnixTimeSpec;
            TimeSpec sRemTime;

            for(;;) {
                if(nanosleep(&sWaitTime, &sRemTime) == 0) {
                    break;
                }
                else if(errno == EINTR) {
                    sWaitTime = sRemTime;
                }
                else {
                    errorNo = errno;
                    break;
                }
            }
        }

        if(pthread_kill(_thread1, 0) == 0) {
            _didTimeOut = YES;
            if(self.signalAction) errorNo = errno;
        }

        return errorNo;
    }

    -(void)cleanup {
        if(!_didTimeOut) pthread_cancel(_thread2);
        pthread_join(_thread2, NULL);
    }

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma ide diagnostic ignored "UnusedValue"

void ignoreSignal(int _signal) {
    _signal = 0;
}

#pragma clang diagnostic pop

void threadCleanup(void *obj) {
    PGTimedWait *__unsafe_unretained timedWait = ((__bridge PGTimedWait *)obj);
    [timedWait cleanup];
}

void *waitThread(void *obj) {
    PGTimedWait *__unsafe_unretained timedWait = ((__bridge PGTimedWait *)obj);
    long errorNo = ((long)[timedWait wait]);
    return ((void *)errorNo);
}

