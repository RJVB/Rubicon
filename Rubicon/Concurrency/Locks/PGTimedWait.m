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
#import <pthread.h>

#define ZEROTHREAD(t) ((t) = ((pthread_t)(0)))
#define NSLEEP(at)    (clock_nanosleep(CLOCK_REALTIME, TIMER_ABSTIME, at, NULL) != 0)

static void ignoreSignal(int _signal);

static void threadCleanup(voidp obj);

static voidp threadWait(voidp obj);

@interface PGTimedWait()

    @property(copy) PGTimeSpec *absTime;
    @property /* */ BOOL       didTimeOut;
    @property /* */ BOOL       completed;

    -(void)cleanup;

    -(voidp)wait;

@end

@implementation PGTimedWait {
        pthread_t       _thread1;
        pthread_t       _thread2;
        NSRecursiveLock *_rlock;
    }

    @synthesize absTime = _absTime;
    @synthesize didTimeOut = _didTimeOut;
    @synthesize completed = _completed;

    -(instancetype)initWithTimeout:(PGTimeSpec *)absTime {
        self = [super init];

        if(self) {
            self.didTimeOut = NO;
            self.completed  = NO;
            self.absTime    = [absTime copy];

            _rlock = [NSRecursiveLock new];
            ZEROTHREAD(_thread1);
            ZEROTHREAD(_thread2);
        }

        return self;
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
        [_rlock lock];

        @try {
            self.didTimeOut = NO;
            self.completed  = NO;
            _thread1 = pthread_self();

            NSException      *exception    = nil;
            voidp            udata         = PG_BRDG_CAST(void)self;
            BOOL             success       = NO;
            int              savedState    = 0;
            int              ignoredState  = 0;
            id               actionResults = nil;
            struct sigaction oldSigAction;
            struct sigaction newSigAction;

            newSigAction.sa_handler = ignoreSignal;
            newSigAction.sa_flags   = 0;
            sigemptyset(&newSigAction.sa_mask);

            pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &savedState);
            pthread_cleanup_push(threadCleanup, udata);

                success = (sigaction(SIGUSR2, &newSigAction, &oldSigAction) == 0);
                if(success) success = (pthread_create(&_thread2, NULL, threadWait, udata) == 0);

                pthread_setcancelstate(savedState, &ignoredState);

                if(success) { @try { success = [self action:&actionResults]; } @catch(NSException *caughtException) { exception = caughtException; }}
                self.completed = YES;

            pthread_cleanup_pop(YES);

            if(exception) @throw exception;
            PGSetReference(results, actionResults);
            return success;
        }
        @finally {
            [_rlock unlock];
        }
    }

#pragma clang diagnostic pop

    -(void)cleanup {
        if(!self.didTimeOut) pthread_cancel(_thread2);
    }

    -(voidp)wait {
        TimeSpec at = self.absTime.toUnixTimeSpec;

        while((!self.completed) && NSLEEP(&at) && (errno == EINTR)) /* Do Nothing. */;

        if((!self.completed) && (pthread_kill(_thread1, 0) == 0)) {
            self.didTimeOut = YES;
            return ((voidp)(long)(pthread_kill(_thread1, SIGUSR2)));
        }

        return NULL;
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
    [(PG_BRDG_CAST(PGTimedWait)obj) cleanup];
}

voidp threadWait(voidp obj) {
    return [(PG_BRDG_CAST(PGTimedWait)obj) wait];
}
