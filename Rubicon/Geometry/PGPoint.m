/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGPoint.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/2/17 6:52 AM
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

#import "PGPoint.h"
#import "PGIPoint.h"
#import "NSObject+PGObject.h"

@implementation PGPoint {
	}

	@synthesize x = _x;
	@synthesize y = _y;

	-(instancetype)initWithX:(NSFloat)x Y:(NSFloat)y {
		self = [super init];

		if(self) {
			_x = x;
			_y = y;
		}

		return self;
	}

	-(instancetype)initWithPGIPoint:(PGIPoint *)point {
		return (self = [self initWithX:point.x Y:point.y]);
	}

	-(instancetype)initWithNSPoint:(NSPoint)point {
		return (self = [self initWithX:point.x Y:point.y]);
	}

	+(instancetype)pointWithX:(NSFloat)x Y:(NSFloat)y {
		return [(PGPoint *)[self alloc] initWithX:x Y:y];
	}

	+(instancetype)pointWithPGIPoint:(PGIPoint *)point {
		return [(PGPoint *)[self alloc] initWithPGIPoint:point];
	}

	+(instancetype)pointWithNSPoint:(NSPoint)point {
		return [(PGPoint *)[self alloc] initWithNSPoint:point];
	}

	+(instancetype)pointWithAngle:(NSFloat)angle magnitude:(NSFloat)magnitude {
		NSFloat x, y;
#if defined(__APPLE__)
		__sincos(angle, &y, &x);
#elif defined(LINUX)
		sincos(angle, &y, &x);
#else
		x = cos(angle);
		y = sin(angle);
#endif
		return [(PGPoint *)[self alloc] initWithX:(magnitude * x) Y:(magnitude * y)];
	}

	-(NSFloat)angle {
		return atan2(self.y, self.x);
	}

	-(NSFloat)magnitude {
		return sqrt((self.x * self.x) + (self.y * self.y));
	}

	-(NSPoint)toNSPoint {
		return NSMakePoint(self.x, self.y);
	}

	-(PGIPoint *)toPGIPoint {
		return [PGIPoint pointWithX:(NSInteger)floor(self.x) Y:(NSInteger)floor(self.y)];
	}

	-(NSString *)description {
		return [NSString stringWithFormat:@"%@{ %lf, %lf }", NSStringFromClass([self class]), self.x, self.y];
	}

	-(BOOL)isEqualToX:(NSFloat)x Y:(NSFloat)y {
		return ((self.x == x) && (self.y == y));
	}

	-(BOOL)_isEqualToPoint:(PGPoint *)point {
		return [self isEqualToX:point.x Y:point.y];
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isExactInstanceOfObject:self] && [self _isEqualToPoint:other]) || ([super isEqual:other])));
	}

	-(BOOL)isEqualToPoint:(PGPoint *)point {
		return (point && ((self == point) || [self _isEqualToPoint:point]));
	}

	-(BOOL)isEqualToNSPoint:(NSPoint)point {
		return [self isEqualToX:point.x Y:point.y];
	}

	-(BOOL)isEqualsToPGIPoint:(PGIPoint *)point {
		return [self isEqualToX:point.x Y:point.y];
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGPoint *copy = ((PGPoint *)[[[self class] allocWithZone:zone] init]);

		if(copy != nil) {
			copy->_x = self.x;
			copy->_y = self.y;
		}

		return copy;
	}

	-(NSUInteger)hash {
		return (([@(self.x) hash] * 31u) + [@(self.y) hash]);
	}

@end
