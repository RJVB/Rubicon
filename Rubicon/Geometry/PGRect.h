/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGRect.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/2/17 7:50 AM
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

#ifndef __Rubicon_PGRect_H_
#define __Rubicon_PGRect_H_

#import <Rubicon/PGTools.h>

@class PGPoint;
@class PGSize;
@class PGIRect;
@class PGDivideRectResults;

@interface PGRect : NSObject<NSCopying>

	@property(nonatomic, readonly) PGPoint *origin;
	@property(nonatomic, readonly) PGSize  *size;
	@property(nonatomic, readonly) NSFloat minX;
	@property(nonatomic, readonly) NSFloat minY;
	@property(nonatomic, readonly) NSFloat width;
	@property(nonatomic, readonly) NSFloat height;
	@property(nonatomic, readonly) NSFloat maxX;
	@property(nonatomic, readonly) NSFloat maxY;
	@property(nonatomic, readonly) NSFloat midX;
	@property(nonatomic, readonly) NSFloat midY;
	@property(nonatomic, readonly) NSFloat x;
	@property(nonatomic, readonly) NSFloat y;

	-(instancetype)initWithOrigin:(PGPoint *)origin size:(PGSize *)size;

	-(instancetype)initWithX:(NSFloat)x Y:(NSFloat)y width:(NSFloat)width height:(NSFloat)height;

	-(BOOL)isEqualToX:(NSFloat)other Y:(NSFloat)y width:(NSFloat)width height:(NSFloat)height;

	-(BOOL)isEqual:(id)other;

	-(BOOL)isEqualToRect:(PGRect *)rect;

	-(NSUInteger)hash;

	-(NSRect)toNSRect;

	-(PGIRect *)toPGIRect;

	-(PGRect *)insetRectForX:(NSFloat)dx Y:(NSFloat)dy;

	-(PGRect *)offsetRectWithX:(NSFloat)dx Y:(NSFloat)dy;

	-(PGRect *)unionWithRect:(PGRect *)rect;

	-(PGRect *)unionWithNSRect:(NSRect)rect;

	-(PGRect *)intersectionWithRect:(PGRect *)rect;

	-(PGRect *)intersectionWithNSRect:(NSRect)rect;

	-(BOOL)intersectsRect:(PGRect *)rect;

	-(BOOL)intersectsNSRect:(NSRect)rect;

	-(BOOL)containsRect:(PGRect *)rect;

	-(BOOL)containsNSRect:(NSRect)rect;

	-(BOOL)containsPoint:(PGPoint *)point;

	-(BOOL)containsMouse:(PGPoint *)point flipped:(BOOL)flipped;

	-(BOOL)containsNSPoint:(NSPoint)point;

	-(BOOL)containsNSPointMouse:(NSPoint)point flipped:(BOOL)flipped;

	-(PGDivideRectResults *)divideRect:(NSFloat)amount edge:(NSRectEdge)edge;

	-(id)copyWithZone:(NSZone *)zone;

	+(instancetype)rectWithPGIRect:(PGIRect *)rect;

	+(instancetype)rectWithNSRect:(NSRect)rect;

	+(instancetype)rectWithX:(NSFloat)x Y:(NSFloat)y width:(NSFloat)width height:(NSFloat)height;

	+(instancetype)rectWithOrigin:(PGPoint *)origin size:(PGSize *)size;

@end

#endif //__Rubicon_PGRect_H_
