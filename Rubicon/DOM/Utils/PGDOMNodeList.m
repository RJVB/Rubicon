/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNodeList.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/15/17 7:07 PM
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
#import "PGDefines.h"
#import "PGReadWriteLock.h"

@interface PGDOMNodeList()

	-(instancetype)initWithNodes:(NSArray<PGDOMNode *> *)nodes;

	-(void)writeLock;

	-(void)addNode:(PGDOMNode *)node;

@end

@implementation PGDOMNodeList {
		NSMutableArray<PGDOMNode *> *_nodeList;
		PGReadWriteLock             *_rwLock;
		NSString                    *_tlsKey;
	}

	-(instancetype)init {
		self = [super init];

		if(self) {
			_rwLock   = [[PGReadWriteLock alloc] init];
			_nodeList = [NSMutableArray array];
			_tlsKey   = [[NSUUID UUID].UUIDString copy];
		}

		return self;
	}

	-(instancetype)initWithNodes:(NSArray<PGDOMNode *> *)nodes {
		self = [self init];

		if(self) {
			[_nodeList addObjectsFromArray:nodes];
		}

		return self;
	}

	-(void)lock {
		[_rwLock lock];
	}

	-(void)writeLock {
		[_rwLock writeLock];
	}

	-(void)unlock {
		[_rwLock unlock];
	}

	-(void)addNode:(PGDOMNode *)node {
		[self writeLock];

		@try {
			if(node && ![self containsNode:node]) {
				[_nodeList addObject:node];
			}
		}
		@finally {
			[self unlock];
		}
	}

	-(BOOL)containsSimilarNode:(PGDOMNode *)node {
		return (NSUNotFound != [self indexOfSimilarNode:node]);
	}

	-(BOOL)containsNode:(PGDOMNode *)node {
		return (NSUNotFound != [self indexOfNode:node]);
	}

	-(NSUInteger)indexOfSimilarNode:(PGDOMNode *)node {
		if(node) {
			[self lock];

			@try {
				for(NSUInteger i = 0; i < self.length; i++) {
					if([[self item:i] isEqualToNode:node]) {
						return i;
					}
				}
			}
			@finally {
				[self unlock];
			}
		}

		return NSUNotFound;
	}

	-(NSUInteger)indexOfNode:(PGDOMNode *)node {
		if(node) {
			[self lock];

			@try {
				for(NSUInteger i = 0; i < self.length; i++) {
					if([[self item:i] isEqual:node]) {
						return i;
					}
				}
			}
			@finally {
				[self unlock];
			}
		}

		return NSUNotFound;
	}

	-(NSUInteger)length {
		[self lock];

		@try {
			return _nodeList.count;
		}
		@finally {
			[self unlock];
		}
	}

	-(PGDOMNode *)item:(NSUInteger)index {
		[self lock];

		@try {
			return ((index < _nodeList.count) ? _nodeList[index] : nil);
		}
		@finally {
			[self unlock];
		}
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self _isEqualToList:other] : [super isEqual:other])));
	}

	-(BOOL)isEqualToList:(PGDOMNodeList *)list {
		return (list && ((self == list) || [self _isEqualToList:list]));
	}

	-(BOOL)_isEqualToList:(PGDOMNodeList *)list {
		NSUInteger j = _nodeList.count;

		if(j == list->_nodeList.count) {
			for(NSUInteger i = 0; i < j; i++) {
				if(![_nodeList[i] isEqualToNode:list->_nodeList[i]]) {
					return NO;
				}
			}

			return YES;
		}

		return NO;
	}

	-(NSUInteger)hash {
		[self lock];

		@try {
			NSUInteger _hash = 1;

			for(NSUInteger i = 0, j = _nodeList.count; i < MIN(j, 30); i++) {
				_hash = ((_hash * 31u) + [_nodeList[i] hash]);
			}

			return _hash;
		}
		@finally {
			[self unlock];
		}
	}

@end
