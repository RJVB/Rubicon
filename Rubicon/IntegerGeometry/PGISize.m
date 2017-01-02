/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGISize.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/1/17 1:26 PM
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

#import "PGISize.h"

@implementation PGISize {
	}

	@synthesize width = _width;
	@synthesize height = _height;

	-(instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height {
		self = [super init];

		if(self) {
			_width  = width;
			_height = height;
		}

		return self;
	}

	+(instancetype)sizeWithWidth:(NSInteger)width height:(NSInteger)height {
		return [[self alloc] initWithWidth:width height:height];
	}

	+(instancetype)sizeWithNSSize:(NSSize)size {
		return [self sizeWithWidth:(NSInteger)ceil(size.width) height:(NSInteger)ceil(size.height)];
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGISize *copy = ((PGISize *)[[[self class] allocWithZone:zone] init]);

		if(copy != nil) {
			copy->_width  = self.width;
			copy->_height = self.height;
		}

		return copy;
	}

	-(NSString *)description {
		return [NSString stringWithFormat:@"%@{%@, %@}", NSStringFromClass([self class]), @(self.width), @(self.height)];
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToSize:other] : [super isEqual:other])));
	}

	-(BOOL)isEqualToSize:(PGISize *)size {
		return (size && ((self == size) || ((self.width == size.width) && (self.height == size.height))));
	}

	-(NSUInteger)hash {
		return (((NSUInteger)self.width * 31u) + (NSUInteger)self.height);
	}

	-(NSSize)toNSSize {
		return NSMakeSize(self.width, self.height);
	}

@end
