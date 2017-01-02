/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSize.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/2/17 7:10 AM
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

#import "PGSize.h"
#import "PGISize.h"

@implementation PGSize {
	}

	@synthesize width = _width;
	@synthesize height = _height;

	-(instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height {
		self = [super init];

		if(self) {
			_width  = width;
			_height = height;
		}

		return self;
	}

	+(instancetype)sizeWithWidth:(CGFloat)width height:(CGFloat)height {
		return [(PGSize *)[self alloc] initWithWidth:width height:height];
	}

	+(instancetype)sizeWithNSSize:(NSSize)size {
		return [(PGSize *)[self alloc] initWithWidth:size.width height:size.height];
	}

	+(instancetype)sizeWithPGISize:(PGISize *)size {
		return [(PGSize *)[self alloc] initWithWidth:size.width height:size.height];
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGSize *copy = ((PGSize *)[[[self class] allocWithZone:zone] init]);

		if(copy != nil) {
			copy->_width  = self.width;
			copy->_height = self.height;
		}

		return copy;
	}

	-(BOOL)isEqualToWidth:(CGFloat)width height:(CGFloat)height {
		return ((self.width == width) && (self.height == height));
	}

	-(BOOL)_isEqualToSize:(PGSize *)size {
		return [self isEqualToWidth:size.width height:size.height];
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self _isEqualToSize:other] : [super isEqual:other])));
	}

	-(BOOL)isEqualToSize:(PGSize *)size {
		return (size && ((self == size) || [self isEqualToWidth:size.width height:size.height]));
	}

	-(BOOL)isEqualToNSSize:(NSSize)size {
		return [self isEqualToWidth:size.width height:size.height];
	}

	-(BOOL)isEqualToPGISize:(PGISize *)size {
		return [self isEqualToWidth:size.width height:size.height];
	}

	-(NSSize)toNSSize {
		return NSMakeSize(self.width, self.height);
	}

	-(PGISize *)toPGISize {
		return [PGISize sizeWithWidth:(NSInteger)ceil(self.width) height:(NSInteger)ceil(self.height)];
	}

	-(NSUInteger)hash {
		return (([@(self.width) hash] * 31u) + [@(self.height) hash]);
	}

	-(NSString *)description {
		return [NSString stringWithFormat:@"%@{ %lf, %lf }", NSStringFromClass([self class]), self.width, self.height];
	}

@end
