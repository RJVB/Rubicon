/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGIRect.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/1/17 1:32 PM
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

#import "PGIRect.h"
#import "PGIPoint.h"
#import "PGISize.h"

@implementation PGIRect {
	}

	@synthesize origin = _origin;
	@synthesize size = _size;

	-(instancetype)init {
		self = [super init];

		if(self) {
			_origin = [PGIPoint pointWithX:0 Y:0];
			_size   = [PGISize sizeWithWidth:0 height:0];
		}

		return self;
	}

	-(instancetype)initWithOrigin:(PGIPoint *)origin size:(PGISize *)size {
		self = [super init];

		if(self) {
			_origin = [origin copy];
			_size   = [size copy];
		}

		return self;
	}

	-(instancetype)initWithX:(NSInteger)x Y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height {
		self = [super init];

		if(self) {
			_origin = [PGIPoint pointWithX:x Y:y];
			_size   = [PGISize sizeWithWidth:width height:height];
		}

		return self;
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGIRect *copy = (PGIRect *)[[[self class] allocWithZone:zone] init];

		if(copy) {
			copy->_origin = [self.origin copyWithZone:zone];
			copy->_size   = [self.size copyWithZone:zone];
		}

		return copy;
	}

	-(NSInteger)maxX {
		return (self.origin.x + self.width);
	}

	-(NSInteger)midX {
		return (NSInteger)(self.origin.x + ceil(self.width * 0.5));
	}

	-(NSInteger)width {
		return self.size.width;
	}

	-(NSInteger)height {
		return self.size.height;
	}

	-(NSInteger)minX {
		return self.origin.x;
	}

	-(NSInteger)maxY {
		return (self.origin.y + self.height);
	}

	-(NSInteger)midY {
		return (NSInteger)(self.origin.y + ceil(self.height * 0.5));
	}

	-(NSInteger)minY {
		return self.origin.y;
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToRect:other] : [super isEqual:other])));
	}

	-(BOOL)isEqualToRect:(PGIRect *)rect {
		return (rect && ((self == rect) || ([self.origin isEqual:rect.origin] && [self.size isEqual:rect.size])));
	}

	-(NSUInteger)hash {
		return ((self.origin.hash * 31u) + self.size.hash);
	}

	-(NSRect)toNSRect {
		return NSMakeRect(self.origin.x, self.origin.y, self.size.width, self.size.height);
	}

	-(instancetype)offsetByX:(NSInteger)dx Y:(NSInteger)dy {
		return [[self class] rectWithX:self.minX + dx Y:self.minY + dy width:self.width height:self.height];
	}

	-(instancetype)insetByX:(NSInteger)dx Y:(NSInteger)dy {
		return [[self class] rectWithX:(self.minX + dx) Y:(self.minY + dy) width:(self.width - (2 * dx)) height:(self.height - (2 * dy))];
	}

	-(instancetype)unionWithRect:(PGIRect *)rect {
		if(self.isEmpty && (rect == nil || rect.isEmpty)) {
			return [PGIRect rectWithX:0 Y:0 width:0 height:0];
		}
		else if(rect == nil || rect.isEmpty) {
			return self;
		}
		else if(self.isEmpty) {
			return rect;
		}

		PGIPoint *p1 = [PGIPoint pointWithX:MIN(self.minX, rect.minX) Y:MIN(self.minY, rect.minY)];
		PGISize  *s1 = [PGISize sizeWithWidth:(MAX(self.maxX, rect.maxX) - p1.x) height:(MAX(self.maxY, rect.maxY) - p1.y)];
		return [PGIRect rectWithOrigin:p1 size:s1];
	}

	-(instancetype)intersectionWithRect:(PGIRect *)rect {
		if(self.isEmpty || rect == nil || rect.isEmpty) {
			return [PGIRect rectWithX:0 Y:0 width:0 height:0];
		}
		else if(self.maxX <= rect.minX || rect.maxX <= self.minX || self.maxY <= rect.minY || rect.maxY <= self.minY) {
			return [PGIRect rectWithX:0 Y:0 width:0 height:0];
		}
		else {
			return [PGIRect rectWithX:((self.minX <= rect.minX) ? rect.origin.x : self.origin.x)
									Y:((self.minY <= rect.minY) ? rect.origin.y : self.origin.y)
								width:(((self.maxX >= rect.maxX) ? rect.maxX : self.maxX) - rect.origin.x)
							   height:(((self.maxY >= rect.maxY) ? rect.maxY : self.maxY) - rect.origin.y)];
		}
	}

	-(BOOL)isEmpty {
		return ((self.width <= 0) || (self.height <= 0));
	}

	-(NSString *)description {
		return [NSString stringWithFormat:@"%@{%@, %@}", NSStringFromClass([self class]), [self.origin description], [self.size description]];
	}

	+(instancetype)rectWithOrigin:(PGIPoint *)origin size:(PGISize *)size {
		return [[self alloc] initWithOrigin:origin size:size];
	}

	+(instancetype)rectWithX:(NSInteger)x Y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height {
		return [[self alloc] initWithX:x Y:y width:width height:height];
	}

	+(instancetype)rectWithNSRect:(NSRect)rect {
		return [[self alloc]
					  initWithX:(NSInteger)floor(NSMinX(rect))
							  Y:(NSInteger)floor(NSMinY(rect))
						  width:(NSInteger)ceil(NSWidth(rect))
						 height:(NSInteger)ceil(NSHeight(rect))];
	}

@end
