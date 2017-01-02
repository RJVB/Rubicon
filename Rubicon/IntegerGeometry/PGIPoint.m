/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGIPoint.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/1/17 1:13 PM
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

#import "PGIPoint.h"

@implementation PGIPoint {
	}

	@synthesize x = _x;
	@synthesize y = _y;

	-(instancetype)initWithX:(NSInteger)x Y:(NSInteger)y {
		self = [super init];

		if(self) {
			_x = x;
			_y = y;
		}

		return self;
	}

	+(instancetype)pointWithX:(NSInteger)x Y:(NSInteger)y {
		return [[PGIPoint alloc] initWithX:x Y:y];
	}

	+(instancetype)pointWithNSPoint:(NSPoint)point {
		return [self pointWithX:(NSInteger)ceil(point.x) Y:(NSInteger)ceil(point.y)];
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGIPoint *copy = ((PGIPoint *)[[[self class] allocWithZone:zone] init]);

		if(copy != nil) {
			copy->_x = self.x;
			copy->_y = self.y;
		}

		return copy;
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToPoint:other] : [super isEqual:other])));
	}

	-(BOOL)isEqualToPoint:(PGIPoint *)point {
		return (point && ((self == point) || ((self.x == point.x) && (self.y == point.y))));
	}

	-(NSUInteger)hash {
		return (((NSUInteger)self.x * 31u) + (NSUInteger)self.y);
	}

	-(NSPoint)toNSPoint {
		return NSMakePoint(self.x, self.y);
	}

	-(NSString *)description {
		return [NSString stringWithFormat:@"%@{%@, %@}", NSStringFromClass([self class]), @(self.x), @(self.y)];
	}

@end
