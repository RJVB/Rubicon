/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGRWLockCounts.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/15/17 1:29 PM
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

#ifndef __Rubicon_PGRWLockCounts_H_
#define __Rubicon_PGRWLockCounts_H_

#import <Cocoa/Cocoa.h>

typedef enum {
    PGRWNoLockHeld, PGRWReadLockHeld, PGRWWriteLockHeld
} PGRWCurrentLock;
NS_ASSUME_NONNULL_BEGIN

@interface PGRWLockCounts : NSObject

    @property(readwrite) NSUInteger      count;
    @property(readwrite) PGRWCurrentLock currentLock;

    -(instancetype)init;

    +(instancetype)counts;

@end

NS_ASSUME_NONNULL_END
#endif //__Rubicon_PGRWLockCounts_H_
