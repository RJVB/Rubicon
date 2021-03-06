/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSemaphore.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/11/17 2:31 PM
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
 *//************************************************************************/
#import "PGInternal.h"
#import "PGTimedSemWait.h"

@implementation PGSemaphore {
        sem_t *_semaphore;
    }

    @synthesize value = _value;
    @synthesize name = _name;

    -(instancetype)initWithSemaphoreName:(NSString *)name value:(NSUInteger)value {
        self = [super init];

        if(self) {
            _value     = ((value < 1) ? 1 : ((value > SEM_VALUE_MAX) ? SEM_VALUE_MAX : value));
            _name      = (name.length ? [self cleanName:name] : [self makeName]);
            _semaphore = sem_open(self.name.UTF8String, O_CREAT, (S_IRUSR | S_IWUSR), _value);

            if(_semaphore == SEM_FAILED) {
                @throw [NSException exceptionWithName:PGSemaphoreException reason:PGStrError(errno) userInfo:nil];
            }
        }

        return self;
    }

    +(instancetype)semaphoreWithName:(NSString *)name value:(NSUInteger)value {
        return [[self alloc] initWithSemaphoreName:name value:value];
    }

    -(NSString *)makeName {
        return [PGFormat(@"%@%@", PGDefaultSemaphoreNamePrefix, @(PGSystemRealTime(0))) limitLength:PGMaxSemaphoreNameLength];
    }

    -(NSString *)cleanName:(NSString *)name {
        return [name hasPrefix:@"/"] ? [name copy] : PGFormat(@"/%@", name);
    }

    -(BOOL)isOpen {
        return (_semaphore != SEM_FAILED);
    }

    -(void)dealloc {
        [self close];
    }

    -(void)close {
        dispatch_sync(PGSharedSerialQueue(), ^{
            if(self.isOpen) {
                sem_close(self->_semaphore);
                self->_semaphore = SEM_FAILED;
                sem_unlink(self.name.UTF8String);
            }
        });
    }

    -(void)post {
        if(sem_post(_semaphore)) {
            @throw [NSException exceptionWithName:PGSemaphoreException reason:PGStrError(errno) userInfo:nil];
        }
    }

    -(void)wait {
        if(sem_wait(_semaphore)) {
            @throw [NSException exceptionWithName:PGSemaphoreException reason:PGStrError(errno) userInfo:nil];
        }
    }

    -(BOOL)tryWait {
        if(sem_trywait(_semaphore)) {
            if(errno == EAGAIN) {
                return NO;
            }
            else {
                @throw [NSException exceptionWithName:PGSemaphoreException reason:PGStrError(errno) userInfo:nil];
            }
        }

        return YES;
    }

    -(BOOL)timedWait:(PGTimeSpec *)abstime {
        return ([self tryWait] ? YES : [[[PGTimedSemWait alloc] initWithTimeout:abstime semaphore:_semaphore] timedAction:NULL]);
    }

@end

