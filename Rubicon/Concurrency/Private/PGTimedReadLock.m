/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTimedReadLock.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/6/17 7:21 PM
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

#include <pthread.h>
#import "PGTimedReadLock.h"

@interface PGTimedReadLock()

	@property(readwrite) pthread_rwlock_t *rwlock;

	-(int)performAction;

@end

@implementation PGTimedReadLock {
	}

	@synthesize rwlock = _rwlock;

	-(instancetype)initWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock {
		self = [super initWithTimeout:absTime];

		if(self) {
			self.rwlock = rwlock;
		}

		return self;
	}

	-(int)performAction {
		return pthread_rwlock_rdlock(self.rwlock);
	}

	-(BOOL)action:(id *)results {
		*results = nil;
		int rc = [self performAction];

		if(rc) {
			if((rc == EINTR) && self.didTimeOut) {
				return NO;
			}
			else {
				@throw [NSException exceptionWithName:PGReadWriteLockException reason:PGStrError(rc) userInfo:nil];
			}
		}

		return YES;
	}

	+(instancetype)readLockWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock {
		return [[PGTimedReadLock alloc] initWithTimeout:absTime readWriteLock:rwlock];
	}

@end

@implementation PGTimedWriteLock {
	}

	-(instancetype)initWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock {
		return (self = [super initWithTimeout:absTime readWriteLock:rwlock]);
	}

	-(int)performAction {
		return pthread_rwlock_wrlock(self.rwlock);
	}

	+(instancetype)writeLockWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock {
		return [[PGTimedWriteLock alloc] initWithTimeout:absTime readWriteLock:rwlock];
	}

@end

