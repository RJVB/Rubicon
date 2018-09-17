/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTimeSpec.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/14/17 5:49 PM
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
#ifndef __Rubicon_PGTimeSpec_H_
#define __Rubicon_PGTimeSpec_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This is simply an object wrapper around the standard C timespec structure.  This class makes no
 * assumptions about the meaning of the time that it has stored other than the seconds field must be
 * >= zero and the nanoseconds field must be in the range 0..999,999,999 inclusive. In most cases it
 * represents a relative point in time in relation to something more meaningful like when the computer
 * was powered on or from the epoch (midnight, January 1, 1970 GMT).  It may also indicate a timeout
 * value such as a certain number of nanoseconds that they nanosleep() function will suspend execution
 * of the current thread.
 */
@interface PGTimeSpec : NSObject<NSCopying>

    @property(nonatomic, readonly) NSLong years;
    @property(nonatomic, readonly) NSLong days;
    @property(nonatomic, readonly) NSLong hours;
    @property(nonatomic, readonly) NSLong minutes;
    @property(nonatomic, readonly) NSLong seconds;
    @property(nonatomic, readonly) NSLong milliseconds;
    @property(nonatomic, readonly) NSLong microseconds;
    @property(nonatomic, readonly) NSLong nanoseconds;

    -(instancetype)init;

    -(instancetype)initWithSeconds:(NSInteger)seconds andNanos:(NSInteger)nanos;

    -(instancetype)initWithTimeVal:(PTimeVal)timeVal;

    -(instancetype)initWithTimeSpec:(const PTimeSpec)timeSpec;

    -(BOOL)isEqual:(id)other;

    -(BOOL)isEqualToSpec:(PGTimeSpec *)spec;

    -(NSUInteger)hash;

    -(id)copyWithZone:(nullable NSZone *)zone;

    -(TimeSpec)toUnixTimeSpec;

    -(TimeVal)toUnixTimeVal;

    -(PGTimeSpec *)sleep;

    -(PGTimeSpec *)remainingTimeFromAbsoluteTime;

    +(instancetype)timeSpecWithCurrentTime;

    +(instancetype)timeSpecWithSeconds:(NSInteger)seconds andNanos:(NSInteger)nanos;

    +(instancetype)timeSpecWithTimeVal:(PTimeVal)timeVal;

    +(instancetype)timeSpecWithTimeSpec:(const PTimeSpec)timeSpec;

    +(instancetype)timeSpecWithFutureSeconds:(NSInteger)seconds andNanos:(NSInteger)nanos;

    +(void)validateSeconds:(NSInteger)seconds andNanos:(NSInteger)nanos;

@end

NS_ASSUME_NONNULL_END
#endif //__Rubicon_PGTimeSpec_H_
