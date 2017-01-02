/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSDividedRectResults.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/2/17 8:40 AM
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

#import "PGDivideRectResults.h"
#import "PGRect.h"

@implementation PGDivideRectResults {
	}

	@synthesize slice = _slice;
	@synthesize remainder = _remainder;

	-(instancetype)initWithSlice:(PGRect *)slice remainder:(PGRect *)remainder {
		self = [super init];

		if(self) {
			_slice     = [slice copy];
			_remainder = [remainder copy];
		}

		return self;
	}

	+(instancetype)resultsWithSlice:(PGRect *)slice remainder:(PGRect *)remainder {
		return [[self alloc] initWithSlice:slice remainder:remainder];
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToResults:other] : [super isEqual:other])));
	}

	-(BOOL)isEqualToResults:(PGDivideRectResults *)results {
		if(self == results) {
			return YES;
		}
		if(results == nil) {
			return NO;
		}
		if(!((self.slice == results.slice) || [self.slice isEqualToRect:results.slice])) {
			return NO;
		}
		return ((self.remainder == results.remainder) || [self.remainder isEqualToRect:results.remainder]);
	}

	-(NSUInteger)hash {
		return (([self.slice hash] * 31u) + [self.remainder hash]);
	}

@end
