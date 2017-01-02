/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGRect.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/2/17 7:50 AM
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

#import "PGRect.h"
#import "PGPoint.h"
#import "PGSize.h"
#import "PGIRect.h"
#import "PGDivideRectResults.h"

@implementation PGRect {
	}

	@synthesize origin = _origin;
	@synthesize size = _size;

	-(instancetype)initWithOrigin:(PGPoint *)origin size:(PGSize *)size {
		self = [super init];

		if(self) {
			_origin = [origin copy];
			_size   = [size copy];
		}

		return self;
	}

	-(instancetype)initWithX:(CGFloat)x Y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height {
		self = [super init];

		if(self) {
			_origin = [PGPoint pointWithX:x Y:y];
			_size   = [PGSize sizeWithWidth:width height:height];
		}

		return self;
	}

	+(instancetype)rectWithPGIRect:(PGIRect *)rect {
		return [(PGRect *)[self alloc] initWithX:rect.minX Y:rect.minY width:rect.width height:rect.height];
	}

	+(instancetype)rectWithNSRect:(NSRect)rect {
		return [(PGRect *)[self alloc] initWithX:rect.origin.x Y:rect.origin.y width:rect.size.width height:rect.size.height];
	}

	+(instancetype)rectWithX:(CGFloat)x Y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height {
		return [(PGRect *)[self alloc] initWithX:x Y:y width:width height:height];
	}

	+(instancetype)rectWithOrigin:(PGPoint *)origin size:(PGSize *)size {
		return [(PGRect *)[self alloc] initWithOrigin:origin size:size];
	}

	-(CGFloat)x {
		return self.origin.x;
	}

	-(CGFloat)y {
		return self.origin.y;
	}

	-(CGFloat)maxX {
		return (self.origin.x + self.size.width);
	}

	-(CGFloat)maxY {
		return (self.origin.y + self.size.height);
	}

	-(CGFloat)midX {
		return (self.origin.x + (self.size.width * (CGFloat)0.5));
	}

	-(CGFloat)midY {
		return (self.origin.y + (self.size.height * (CGFloat)0.5));
	}

	-(CGFloat)minX {
		return self.origin.x;
	}

	-(CGFloat)minY {
		return self.origin.y;
	}

	-(CGFloat)width {
		return self.size.width;
	}

	-(CGFloat)height {
		return self.size.height;
	}

	-(BOOL)isEqualToX:(CGFloat)x Y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height {
		return ((self.x == x) && (self.y == y) && (self.width == width) && (self.height == height));
	}

	-(BOOL)_isEqualToRect:(PGRect *)rect {
		return [self isEqualToX:rect.x Y:rect.y width:rect.width height:rect.height];
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToRect:other] : [super isEqual:other])));
	}

	-(BOOL)isEqualToRect:(PGRect *)rect {
		return (rect && ((self == rect) || [self _isEqualToRect:rect]));
	}

	-(NSUInteger)hash {
		return (([self.origin hash] * 31u) + [self.size hash]);
	}

	-(NSRect)toNSRect {
		return NSMakeRect(self.x, self.y, self.width, self.height);
	}

	-(PGIRect *)toPGIRect {
		return [PGIRect rectWithX:(NSInteger)floor(self.x) Y:(NSInteger)floor(self.y) width:(NSInteger)ceil(self.width) height:(NSInteger)ceil(self.height)];
	}

	-(PGRect *)insetRectForX:(CGFloat)dx Y:(CGFloat)dy {
		return [PGRect rectWithNSRect:NSInsetRect(self.toNSRect, dx, dy)];
	}

	-(PGRect *)offsetRectWithX:(CGFloat)dx Y:(CGFloat)dy {
		return [PGRect rectWithX:(self.x + dx) Y:(self.y + dy) width:self.width height:self.height];
	}

	-(PGRect *)unionWithRect:(PGRect *)rect {
		return [PGRect rectWithNSRect:NSUnionRect(self.toNSRect, (rect ? rect.toNSRect : NSZeroRect))];
	}

	-(PGRect *)unionWithNSRect:(NSRect)rect {
		return [PGRect rectWithNSRect:NSUnionRect(self.toNSRect, rect)];
	}

	-(PGRect *)intersectionWithRect:(PGRect *)rect {
		return [PGRect rectWithNSRect:NSIntersectionRect(self.toNSRect, (rect ? rect.toNSRect : NSZeroRect))];
	}

	-(PGRect *)intersectionWithNSRect:(NSRect)rect {
		return [PGRect rectWithNSRect:NSIntersectionRect(self.toNSRect, rect)];
	}

	-(BOOL)intersectsRect:(PGRect *)rect {
		return NSIntersectsRect(self.toNSRect, (rect ? rect.toNSRect : NSZeroRect));
	}

	-(BOOL)intersectsNSRect:(NSRect)rect {
		return NSIntersectsRect(self.toNSRect, rect);
	}

	-(BOOL)containsRect:(PGRect *)rect {
		return NSContainsRect(self.toNSRect, (rect ? rect.toNSRect : NSZeroRect));
	}

	-(BOOL)containsNSRect:(NSRect)rect {
		return NSContainsRect(self.toNSRect, rect);
	}

	-(BOOL)containsPoint:(PGPoint *)point {
		return NSPointInRect((point ? point.toNSPoint : NSZeroPoint), self.toNSRect);
	}

	-(BOOL)containsMouse:(PGPoint *)point flipped:(BOOL)flipped {
		return NSMouseInRect((point ? point.toNSPoint : NSZeroPoint), self.toNSRect, flipped);
	}

	-(BOOL)containsNSPoint:(NSPoint)point {
		return NSPointInRect(point, self.toNSRect);
	}

	-(BOOL)containsNSPointMouse:(NSPoint)point flipped:(BOOL)flipped {
		return NSMouseInRect(point, self.toNSRect, flipped);
	}

	-(PGDivideRectResults *)divideRect:(CGFloat)amount edge:(NSRectEdge)edge {
		NSRect slice = NSZeroRect;
		NSRect rem   = NSZeroRect;
		NSDivideRect(self.toNSRect, &slice, &rem, amount, edge);
		return [PGDivideRectResults resultsWithSlice:[PGRect rectWithNSRect:slice] remainder:[PGRect rectWithNSRect:rem]];
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGRect *copy = ((PGRect *)[[[self class] allocWithZone:zone] init]);

		if(copy != nil) {
			copy->_origin = [_origin copy];
			copy->_size   = [_size copy];
		}

		return copy;
	}

@end
