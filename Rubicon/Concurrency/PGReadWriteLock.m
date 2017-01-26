/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGReadWriteLock.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/12/17 6:12 PM
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

#import <pthread.h>
#import "PGReadWriteLock.h"
#import "PGTimedWait.h"
#import "PGTimeSpec.h"

@interface PGTimedReadLock : PGTimedWait

	-(instancetype)initWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock;

	-(BOOL)action:(id *)results;

	-(int)performAction:(pthread_rwlock_t *)rwlock;

@end

@interface PGTimedWriteLock : PGTimedReadLock

	-(int)performAction:(pthread_rwlock_t *)rwlock;

@end

@implementation PGReadWriteLock {
		pthread_rwlock_t _rwlock;
		BOOL             _open;
	}

	-(instancetype)init {
		self = [super init];

		if(self) {
			_open = NO;
			int rc = pthread_rwlock_init(&_rwlock, NULL);

			if(rc) {
				@throw [NSException exceptionWithName:PGReadWriteLockException reason:[self errorMessageForCode:rc] userInfo:nil];
			}

			_open = YES;
		}

		return self;
	}

	-(NSString *)errorMessageForCode:(int)code {
		return [NSString stringWithUTF8String:strerror(code)];
	}

	-(void)dealloc {
		[self close];
	}

	-(void)close {
		if(_open) {
			pthread_rwlock_destroy(&_rwlock);
			_open = NO;
		}
	}

	-(void)lock {
		int rc = pthread_rwlock_rdlock(&_rwlock);
		if(rc) @throw [NSException exceptionWithName:PGReadWriteLockException reason:[self errorMessageForCode:rc] userInfo:nil];
	}

	-(void)writeLock {
		int rc = pthread_rwlock_wrlock(&_rwlock);
		if(rc) @throw [NSException exceptionWithName:PGReadWriteLockException reason:[self errorMessageForCode:rc] userInfo:nil];
	}

	-(BOOL)tryLock {
		int rc = pthread_rwlock_tryrdlock(&_rwlock);

		if(rc) {
			if(rc == EBUSY) {
				return NO;
			}
			else {
				@throw [NSException exceptionWithName:PGReadWriteLockException reason:[self errorMessageForCode:rc] userInfo:nil];
			}
		}

		return YES;
	}

	-(BOOL)tryWriteLock {
		int rc = pthread_rwlock_trywrlock(&_rwlock);

		if(rc) {
			if(rc == EBUSY) {
				return NO;
			}
			else {
				@throw [NSException exceptionWithName:PGReadWriteLockException reason:[self errorMessageForCode:rc] userInfo:nil];
			}
		}

		return YES;
	}

	-(BOOL)timedWriteLock:(PGTimeSpec *)absTime {
		return ([self tryWriteLock] ? [[[PGTimedWriteLock alloc] initWithTimeout:absTime readWriteLock:&_rwlock] timedAction:NULL] : YES);
	}

	-(BOOL)timedLock:(PGTimeSpec *)absTime {
		return ([self tryLock] ? [[[PGTimedReadLock alloc] initWithTimeout:absTime readWriteLock:&_rwlock] timedAction:NULL] : YES);
	}

	-(void)unlock {
		int rc = pthread_rwlock_unlock(&_rwlock);
		if(rc) @throw [NSException exceptionWithName:PGReadWriteLockException reason:[self errorMessageForCode:rc] userInfo:nil];
	}

@end

@implementation PGTimedReadLock {
		pthread_rwlock_t *_rwlock;
	}

	-(instancetype)initWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock {
		self = [super initWithTimeout:absTime];

		if(self) {
			_rwlock = rwlock;
		}

		return self;
	}

	-(int)performAction:(pthread_rwlock_t *)rwlock {
		return pthread_rwlock_rdlock(rwlock);
	}

	-(BOOL)action:(id *)results {
		*results = nil;
		int rc = [self performAction:_rwlock];

		if(rc) {
			if((rc == EINTR) && self.didTimeOut) {
				return NO;
			}
			else {
				NSString *reason = [NSString stringWithUTF8String:strerror(rc)];
				@throw [NSException exceptionWithName:PGReadWriteLockException reason:reason userInfo:nil];
			}
		}

		return YES;
	}

@end

@implementation PGTimedWriteLock {
	}

	-(int)performAction:(pthread_rwlock_t *)rwlock {
		return pthread_rwlock_wrlock(rwlock);
	}

@end

