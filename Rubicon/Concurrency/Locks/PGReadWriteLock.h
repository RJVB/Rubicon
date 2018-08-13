/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGReadWriteLock.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/12/17 6:12 PM
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
 *//************************************************************************/
#ifndef __Rubicon_PGReadWriteLock_H_
#define __Rubicon_PGReadWriteLock_H_

#import <Rubicon/PGTools.h>

@class PGTimeSpec;
NS_ASSUME_NONNULL_BEGIN

@interface PGReadWriteLock : NSObject<NSLocking>

    -(instancetype)init;

    -(void)lock;

    -(void)writeLock;

    -(BOOL)tryLock;

    -(BOOL)tryWriteLock;

    -(BOOL)timedWriteLock:(PGTimeSpec *)absTime;

    -(BOOL)timedLock:(PGTimeSpec *)absTime;

    -(void)unlock;

@end

NS_ASSUME_NONNULL_END
#endif //__Rubicon_PGReadWriteLock_H_
