/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTimedReadLock.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/6/17 7:21 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017  Project Galen. All rights reserved.
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

#ifndef __Rubicon_PGTimedReadLock_H_
#define __Rubicon_PGTimedReadLock_H_

#import <Cocoa/Cocoa.h>
#import "PGTimedWait.h"
#import <Rubicon/PGTimeSpec.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGTimedReadLock : PGTimedWait

    -(instancetype)initWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock;

    +(instancetype)readLockWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock;

@end

@interface PGTimedWriteLock : PGTimedReadLock

    -(instancetype)initWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock;

    +(instancetype)writeLockWithTimeout:(PGTimeSpec *)absTime readWriteLock:(pthread_rwlock_t *)rwlock;

@end

NS_ASSUME_NONNULL_END
#endif //__Rubicon_PGTimedReadLock_H_
