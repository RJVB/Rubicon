/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGPoint.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/2/17 6:52 AM
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

#ifndef __Rubicon_PGPoint_H_
#define __Rubicon_PGPoint_H_

#import <Rubicon/PGTools.h>

@class PGIPoint;

@interface PGPoint : NSObject<NSCopying>

	@property(nonatomic, readonly) NSFloat x;
	@property(nonatomic, readonly) NSFloat y;
	@property(nonatomic, readonly) NSFloat angle;
	@property(nonatomic, readonly) NSFloat magnitude;

	-(instancetype)initWithX:(NSFloat)x Y:(NSFloat)y;

	-(instancetype)initWithPGIPoint:(PGIPoint *)point;

	-(instancetype)initWithNSPoint:(NSPoint)point;

	+(instancetype)pointWithX:(NSFloat)x Y:(NSFloat)y;

	+(instancetype)pointWithPGIPoint:(PGIPoint *)point;

	+(instancetype)pointWithNSPoint:(NSPoint)point;

	+(instancetype)pointWithAngle:(NSFloat)angle magnitude:(NSFloat)magnitude;

	-(NSPoint)toNSPoint;

	-(PGIPoint *)toPGIPoint;

	-(BOOL)isEqualToX:(NSFloat)other Y:(NSFloat)y;

	-(BOOL)isEqualToPoint:(PGPoint *)other;

	-(BOOL)isEqualToNSPoint:(NSPoint)other;

	-(BOOL)isEqualsToPGIPoint:(PGIPoint *)other;

	-(id)copyWithZone:(NSZone *)zone;

	-(NSUInteger)hash;

@end

#endif //__Rubicon_PGPoint_H_
