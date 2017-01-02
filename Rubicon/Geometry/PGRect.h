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

#import <Cocoa/Cocoa.h>

@class PGPoint;
@class PGSize;
@class PGIRect;
@class PGDivideRectResults;

@interface PGRect : NSObject<NSCopying>

	@property(nonatomic, readonly) PGPoint *origin;
	@property(nonatomic, readonly) PGSize  *size;
	@property(nonatomic, readonly) CGFloat minX;
	@property(nonatomic, readonly) CGFloat minY;
	@property(nonatomic, readonly) CGFloat width;
	@property(nonatomic, readonly) CGFloat height;
	@property(nonatomic, readonly) CGFloat maxX;
	@property(nonatomic, readonly) CGFloat maxY;
	@property(nonatomic, readonly) CGFloat midX;
	@property(nonatomic, readonly) CGFloat midY;
	@property(nonatomic, readonly) CGFloat x;
	@property(nonatomic, readonly) CGFloat y;

	-(instancetype)initWithOrigin:(PGPoint *)origin size:(PGSize *)size;

	-(instancetype)initWithX:(CGFloat)x Y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

	-(BOOL)isEqualToX:(CGFloat)other Y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

	-(BOOL)isEqual:(id)other;

	-(BOOL)isEqualToRect:(PGRect *)rect;

	-(NSUInteger)hash;

	-(NSRect)toNSRect;

	-(PGIRect *)toPGIRect;

	-(PGRect *)insetRectForX:(CGFloat)dx Y:(CGFloat)dy;

	-(PGRect *)offsetRectWithX:(CGFloat)dx Y:(CGFloat)dy;

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

	-(PGDivideRectResults *)divideRect:(CGFloat)amount edge:(NSRectEdge)edge;

	-(id)copyWithZone:(NSZone *)zone;

	+(instancetype)rectWithPGIRect:(PGIRect *)rect;

	+(instancetype)rectWithNSRect:(NSRect)rect;

	+(instancetype)rectWithX:(CGFloat)x Y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

	+(instancetype)rectWithOrigin:(PGPoint *)origin size:(PGSize *)size;

@end

#endif //__Rubicon_PGRect_H_
