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
 *******************************************************************************/

#import "PGSemaphore.h"
#import <Rubicon/sem_timedwait.h>

@implementation PGSemaphore {
		sem_t *_semaphore;
	}

	@synthesize value = _value;
	@synthesize name = _name;

	-(instancetype)initWithSemaphoreName:(NSString *)name value:(NSUInteger)value {
		self = [super init];

		if(self) {
			_semaphore = SEM_FAILED;
			_value     = ((value < 1) ? 1 : ((value > SEM_VALUE_MAX) ? SEM_VALUE_MAX : value));

			if(name.length) {
				if(![name hasPrefix:@"/"]) {
					_name = [NSString stringWithFormat:@"%@/%@", PGDefaultSemaphoreNamePrefix, name];
				}
				else {
					_name = [name copy];
				}
			}
			else {
				NSLong realTime = PGSystemRealTime(0);
				_name = [NSString stringWithFormat:@"%@/%@/%@", PGDefaultSemaphoreNamePrefix, @(getpid()), @(realTime)];
			}

			_semaphore = sem_open(self.name.UTF8String, O_CREAT);

			if(_semaphore == SEM_FAILED) {
				@throw [NSException exceptionWithName:PGSemaphoreException reason:[NSString stringWithUTF8String:strerror(errno)] userInfo:nil];
			}
		}

		return self;
	}

	-(BOOL)isOpen {
		return (_semaphore != SEM_FAILED);
	}

	-(void)dealloc {
		if(self.isOpen) {
			sem_close(_semaphore);
			_semaphore = SEM_FAILED;
			sem_unlink(self.name.UTF8String);
		}
	}

	+(instancetype)semaphoreWithName:(NSString *)name value:(NSUInteger)value {
		return [[self alloc] initWithSemaphoreName:name value:value];
	}

	-(void)post {
		if(sem_post(_semaphore)) {
			@throw [NSException exceptionWithName:PGSemaphoreException reason:[NSString stringWithUTF8String:strerror(errno)] userInfo:nil];
		}
	}

	-(void)wait {
		if(sem_wait(_semaphore)) {
			@throw [NSException exceptionWithName:PGSemaphoreException reason:[NSString stringWithUTF8String:strerror(errno)] userInfo:nil];
		}
	}

	-(BOOL)tryWait {
		if(sem_trywait(_semaphore)) {
			if(errno == EAGAIN) {
				return NO;
			}
			else {
				@throw [NSException exceptionWithName:PGSemaphoreException reason:[NSString stringWithUTF8String:strerror(errno)] userInfo:nil];
			}
		}

		return YES;
	}

	-(BOOL)timedWait:(PTimeSpec)abstime {
		if(sem_timedwait(_semaphore, abstime)) {
			if(errno == ETIMEDOUT) {
				return NO;
			}
			else {
				@throw [NSException exceptionWithName:PGSemaphoreException reason:[NSString stringWithUTF8String:strerror(errno)] userInfo:nil];
			}
		}

		return YES;
	}

@end
