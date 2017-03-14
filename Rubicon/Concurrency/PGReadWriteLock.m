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

#include <pthread.h>
#import "PGReadWriteLock.h"
#import "PGTimedReadLock.h"

typedef enum {
	PGRWNoLockHeld,
	PGRWReadLockHeld,
	PGRWWriteLockHeld
} PGRWCurrentLock;

@interface PGRWLockCounts : NSObject

	@property(readwrite) NSUInteger      count;
	@property(readwrite) PGRWCurrentLock currentLock;

	-(instancetype)init;

	+(instancetype)counts;

@end

@interface PGReadWriteLock()

	-(void)osTest:(int)rc;

	-(BOOL)osBusyTest:(int)rc;

	-(PGRWLockCounts *)lockCounts;

	-(void)dealloc;

	-(NSException *)upDownException:(PGRWLockCounts *)lc;

	-(BOOL)privateTimedWriteLock:(PGTimeSpec *)absTime;

	-(BOOL)privateTimedReadLock:(PGTimeSpec *)absTime;
@end

@implementation PGReadWriteLock {
		BOOL             _open;
		pthread_rwlock_t _rwlock;
		NSString         *_tlsKey;
	}

	-(instancetype)init {
		self = [super init];

		if(self) {
			_open = NO;
			[self osTest:pthread_rwlock_init(&_rwlock, NULL)];
			_open   = YES;
			_tlsKey = [NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), [NSUUID UUID].UUIDString];
		}

		return self;
	}

	-(void)osTest:(int)rc {
		if(rc) {
			@throw [NSException exceptionWithName:PGReadWriteLockException reason:PGStrError(rc) userInfo:nil];
		}
	}

	-(BOOL)osBusyTest:(int)rc {
		if(rc) {
			if(rc == EBUSY) {
				return NO;
			}
			else {
				[self osTest:rc];
			}
		}

		return YES;
	}

	-(PGRWLockCounts *)lockCounts {
		NSThread       *currentThread = NSThread.currentThread;
		PGRWLockCounts *lc            = currentThread.threadDictionary[_tlsKey];

		if(lc == nil) {
			lc = [PGRWLockCounts counts];
			currentThread.threadDictionary[_tlsKey] = lc;
		}

		return lc;
	}

	-(void)dealloc {
		if(_open) {
			pthread_rwlock_destroy(&_rwlock);
			_open = NO;
			[NSThread.currentThread.threadDictionary removeObjectForKey:_tlsKey];
		}
	}

	-(void)lock {
		PGRWLockCounts *lc = self.lockCounts;

		switch(lc.currentLock) {
			case PGRWNoLockHeld:
				[self osTest:pthread_rwlock_rdlock(&_rwlock)];
				lc.count       = 1;
				lc.currentLock = PGRWReadLockHeld;
				break;
			case PGRWReadLockHeld:
				lc.count++;
				break;
			case PGRWWriteLockHeld:
				@throw [self upDownException:lc];
				break;
		}
	}

	-(void)writeLock {
		PGRWLockCounts *lc = self.lockCounts;

		switch(lc.currentLock) {
			case PGRWNoLockHeld:
				[self osTest:pthread_rwlock_wrlock(&_rwlock)];
				lc.currentLock = PGRWWriteLockHeld;
				lc.count       = 1;
				break;
			case PGRWWriteLockHeld:
				lc.count++;
				break;
			case PGRWReadLockHeld:
				@throw [self upDownException:lc];
				break;
		}
	}

	-(BOOL)tryLock {
		PGRWLockCounts *lc = self.lockCounts;

		switch(lc.currentLock) {
			case PGRWNoLockHeld:
				if([self osBusyTest:pthread_rwlock_tryrdlock(&_rwlock)]) {
					lc.currentLock = PGRWReadLockHeld;
					lc.count       = 1;
					return YES;
				}
				break;
			case PGRWReadLockHeld:
				lc.count++;
				return YES;
			case PGRWWriteLockHeld:
				@throw [self upDownException:lc];
				break;
		}

		return NO;
	}

	-(BOOL)tryWriteLock {
		PGRWLockCounts *lc = self.lockCounts;

		switch(lc.currentLock) {
			case PGRWNoLockHeld:
				if([self osBusyTest:pthread_rwlock_trywrlock(&_rwlock)]) {
					lc.count       = 1;
					lc.currentLock = PGRWWriteLockHeld;
					return YES;
				}
				break;
			case PGRWWriteLockHeld:
				lc.count++;
				return YES;
			case PGRWReadLockHeld:
				@throw [self upDownException:lc];
				break;
		}

		return NO;
	}

	-(BOOL)timedWriteLock:(PGTimeSpec *)absTime {
		PGRWLockCounts *lc = self.lockCounts;

		switch(lc.currentLock) {
			case PGRWNoLockHeld:
				if([self privateTimedWriteLock:absTime]) {
					lc.count       = 1;
					lc.currentLock = PGRWWriteLockHeld;
					return YES;
				}
				break;
			case PGRWWriteLockHeld:
				lc.count++;
				return YES;
			case PGRWReadLockHeld:
				@throw [self upDownException:lc];
				break;
		}

		return NO;
	}

	-(BOOL)timedLock:(PGTimeSpec *)absTime {
		PGRWLockCounts *lc = self.lockCounts;

		switch(lc.currentLock) {
			case PGRWNoLockHeld:
				if([self privateTimedReadLock:absTime]) {
					lc.currentLock = PGRWReadLockHeld;
					lc.count       = 1;
					return YES;
				}
				break;
			case PGRWReadLockHeld:
				lc.count++;
				return YES;
			case PGRWWriteLockHeld:
				@throw [self upDownException:lc];
				break;
		}

		return NO;
	}

	-(void)unlock {
		PGRWLockCounts *lc = self.lockCounts;

		if(lc.currentLock != PGRWNoLockHeld) {
			if(lc.count == 1) {
				[self osTest:pthread_rwlock_unlock(&_rwlock)];
				lc.count       = 0;
				lc.currentLock = PGRWNoLockHeld;
			}
			else if(lc.count) {
				lc.count--;
			}
			else {
				lc.currentLock = PGRWNoLockHeld;
				@throw [NSException exceptionWithName:PGReadWriteLockException reason:@"No locks are currently held." userInfo:nil];
			}
		}
	}

	-(NSException *)upDownException:(PGRWLockCounts *)lc {
		NSString *dir    = (lc.currentLock == PGRWReadLockHeld ? @"read" : @"write");
		NSString *reason = [NSString stringWithFormat:@"%@ %@ locks are currently held.", @(lc.count), dir];
		return [NSException exceptionWithName:PGReadWriteLockException reason:reason userInfo:nil];
	}

	-(BOOL)privateTimedWriteLock:(PGTimeSpec *)absTime {
		return ([self tryWriteLock] ? YES : [[PGTimedWriteLock writeLockWithTimeout:absTime readWriteLock:&_rwlock] timedAction]);
	}

	-(BOOL)privateTimedReadLock:(PGTimeSpec *)absTime {
		return ([self tryLock] ? YES : [[PGTimedWriteLock writeLockWithTimeout:absTime readWriteLock:&_rwlock] timedAction]);
	}

@end

@implementation PGRWLockCounts {
	}

	@synthesize count = _count;
	@synthesize currentLock = _currentLock;

	-(instancetype)init {
		self = [super init];

		if(self) {
			self.count       = 0;
			self.currentLock = PGRWNoLockHeld;
		}

		return self;
	}

	+(instancetype)counts {
		return [[self alloc] init];
	}

@end
