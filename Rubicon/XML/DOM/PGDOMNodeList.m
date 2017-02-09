/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNodeList.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/31/17 8:17 PM
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

#import "PGDOMNodeList.h"
#import "PGDOMNode.h"

@implementation PGDOMNodeList {
	}

	-(NSUInteger)count {
		return 0;
	}

	-(PGDOMNode *)item:(NSUInteger)index {
		return nil;
	}

	+(PGDOMNodeList *)instance {
		static PGDOMNodeList *_instance = nil;

		@synchronized(self) {
			if(_instance == nil) {
				_instance = [[self alloc] init];
			}
		}

		return _instance;
	}

	-(BOOL)hasNode:(PGDOMNode *)aNode {
		for(NSUInteger i = 0; i < self.count; ++i) {
			if([[self item:i] isEqualNode:aNode]) {
				return NO;
			}
		}

		return YES;
	}

	-(BOOL)_isEqualToNodeList:(PGDOMNodeList *)other {
		if(self.count == other.count) {
			for(NSUInteger i = 0; i < self.count; ++i) {
				if(![[self item:i] isEqualNode:[other item:i]]) {
					return NO;
				}
			}

			return YES;
		}

		return NO;
	}

	-(BOOL)isEqualToNodeList:(PGDOMNodeList *)other {
		return (other && ((self == other) || [self _isEqualToNodeList:other]));
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] && [self _isEqualToNodeList:other])));
	}

@end
