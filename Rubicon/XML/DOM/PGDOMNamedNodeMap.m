/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNamedNodeMap.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/31/17 8:05 PM
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

#import "PGDOMNamedNodeMap.h"
#import "PGDOMNode.h"

NSString *const PGDOMException = @"PGDOMException";

@implementation PGDOMNamedNodeMap {
	}

	-(NSUInteger)count {
		return 0;
	}

	-(PGDOMNode *)namedItem:(NSString *)name {
		return nil;
	}

	-(PGDOMNode *)namedItem:(NSString *)name namespace:(NSString *)namespaceURI {
		return nil;
	}

	-(PGDOMNode *)item:(NSUInteger)index {
		return nil;
	}

	-(PGDOMNode *)removeNamedItem:(NSString *)name {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGDOMNode *)removeNamedItem:(NSString *)name namespace:(NSString *)namespaceURI {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGDOMNode *)setNamedItem:(PGDOMNode *)node {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGDOMNode *)setNamedItemWithNamespace:(PGDOMNode *)node {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(BOOL)isEqual:(id)other {
		return (self == other);
	}

	+(PGDOMNamedNodeMap *)instance {
		static PGDOMNamedNodeMap *_instance = nil;

		@synchronized(self) {
			if(_instance == nil) {
				_instance = [[self alloc] init];
			}
		}

		return _instance;
	}

@end
