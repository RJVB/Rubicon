/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTimedWait.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/21/17 7:21 PM
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
 */

#ifndef __Rubicon_PGTimedWait_H_
#define __Rubicon_PGTimedWait_H_

#import <Rubicon/PGTimeSpec.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGTimedWait : NSObject

    @property(atomic, readonly, copy) PGTimeSpec *absTime;
    @property(atomic, readonly) volatile BOOL    didTimeOut;

    -(instancetype)initWithTimeout:(PGTimeSpec *)absTime;

    -(BOOL)timedAction:(id _Nullable *_Nullable)results;

    -(BOOL)timedAction;

    -(BOOL)action:(id _Nullable *_Nullable)results;

@end

NS_ASSUME_NONNULL_END
#endif //__Rubicon_PGTimedWait_H_
