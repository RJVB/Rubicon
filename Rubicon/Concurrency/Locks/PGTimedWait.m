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
 *//************************************************************************/
#import "PGInternal.h"
#include <pthread.h>

void ignoreSignal(int _signal);

void threadCleanup(voidp obj);

#define setErr(f, v) do { if(f) (*(f)) = (v); } while(0)

NS_INLINE BOOL getRemainingTime(TimeSpec *remtime, TimeSpec *abstime, TimeSpec *waittime, NSInteger *errorNo) {
    if(PGRemainingTimeFromAbsoluteTime(abstime, remtime)) {
        setErr(errorNo, errno);
        return YES;
    }

    if((remtime->tv_sec == 0) && (remtime->tv_nsec < waittime->tv_nsec)) waittime->tv_nsec = remtime->tv_nsec;
    setErr(errorNo, 0);
    return NO;
}

NS_INLINE BOOL sleepSome(PTimeSpec waittime, NSInteger *errorNo) {
    if(nanosleep(waittime, NULL)) {
        setErr(errorNo, errno);
        return (errno != EINTR);
    }

    setErr(errorNo, 0);
    return NO;
}

@interface PGTimedWait()

    @property(copy) PGTimeSpec *absTime;
    @property /* */ BOOL       didTimeOut;
    @property /* */ NSThread   *nsThread2;

    -(void)cleanup;

@end

@implementation PGTimedWait {
        pthread_t       _thread1;
        pthread_t       _thread2;
        pthread_mutex_t _mlock;
    }

    @synthesize absTime = _absTime;
    @synthesize didTimeOut = _didTimeOut;
    @synthesize nsThread2 = _nsThread2;

    -(instancetype)initWithTimeout:(PGTimeSpec *)absTime {
        self = [super init];

        if(self) {
            self.didTimeOut = NO;
            self.absTime    = [absTime copy];
            //_mlock = PTHREAD_RECURSIVE_MUTEX_INITIALIZER;
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
        PGSetReference(results, nil);
        return YES;
    }

    -(BOOL)timedAction {
        id actionResults = nil;
        return [self timedAction:&actionResults];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-stack-address"

    -(BOOL)timedAction:(id *)results {
        pthread_mutex_lock(&_mlock);
        @try {
            BOOL        success       = NO;
            NSException *exception    = nil;
            id          actionResults = nil;
            int         savedState    = 0;
            void        *me           = PG_BRDG_CAST(void)self;

            if(TEMP_FAILURE_RETRY(nanosleep(NULL, NULL))) return NO;

            self.didTimeOut = 0;
            _thread1 = pthread_self();

            pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &savedState);
            pthread_cleanup_push(threadCleanup, me);

                pthread_setcancelstate(savedState, NULL);
                if(self.nsThread2) {
                    [self.nsThread2 start];
                    @try { success = [self action:&actionResults]; } @catch(NSException *caughtException) { exception = caughtException; }
                }

            pthread_cleanup_pop(1);
            if(exception && !success) @throw exception;
            PGSetReference(results, actionResults);
            return success;
        }
        @finally { pthread_mutex_unlock(&_mlock); }
    }

#pragma clang diagnostic pop

    -(void)cleanup {
        if(!self.didTimeOut) [self.nsThread2 cancel];
    }

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma ide diagnostic ignored "UnusedValue"

void ignoreSignal(int _signal) {
    _signal = 0;
}

#pragma clang diagnostic pop

void threadCleanup(voidp obj) {
    PGTimedWait *__unsafe_unretained timedWait = (PG_BRDG_CAST(PGTimedWait)obj);
    [timedWait cleanup];
}

