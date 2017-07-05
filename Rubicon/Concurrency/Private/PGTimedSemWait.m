/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTimedSemWait.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/15/17 1:24 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
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

#import "PGTimedSemWait.h"

@implementation PGTimedSemWait {
        sem_t *_semaphore;
    }

    -(instancetype)initWithTimeout:(PGTimeSpec *)absTime semaphore:(sem_t *)semaphore {
        self = [super initWithTimeout:absTime];

        if(self) {
            _semaphore = semaphore;
        }

        return self;
    }

    -(BOOL)action:(id *)results {
        if(results) *results = nil;

        if(sem_wait(_semaphore)) {
            if(errno == EINTR && self.didTimeOut) {
                return NO;
            }
            else {
                @throw [NSException exceptionWithName:PGSemaphoreException reason:PGStrError(errno) userInfo:nil];
            }
        }

        return YES;
    }

    -(void)dealloc {
        _semaphore = SEM_FAILED;
    }

@end
