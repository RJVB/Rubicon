/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/27/17 7:41 PM
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

#import "PGBinaryTreeNode.h"

@interface PGBinaryTreeNode()

	@property(readwrite) BOOL isRed;

	-(void)setKey:(id<NSCopying>)key;

	-(instancetype)getChild:(BOOL)left;

	-(instancetype)setChild:(PGBinaryTreeNode *)child onLeft:(BOOL)left;

	-(void)makeOrphan;

	-(void)setLeftChild:(PGBinaryTreeNode *)child;

	-(void)setRightChild:(PGBinaryTreeNode *)child;

	-(void)rotate:(BOOL)left;

	-(instancetype)farRight;

@end

@implementation PGBinaryTreeNode {
	}

	@synthesize key = _key;
	@synthesize value = _value;
	@synthesize count = _count;
	@synthesize parent = _parent;
	@synthesize leftChild = _leftChild;
	@synthesize rightChild = _rightChild;
	@synthesize isRed = _isRed;

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value {
		self = [super init];

		if(self) {
			self.key   = key;
			self.value = value;
			self.isRed = YES;
			_count = 1;
		}

		return self;
	}

	-(void)setKey:(id<NSCopying>)key {
		_key = [(id)key copy];
	}

	-(void)recount {
		_count = (1 + self.leftChild.count + self.rightChild.count);
	}

	-(void)setParent:(PGBinaryTreeNode *)node {
		if(self == node) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be its own parent." userInfo:nil];
		}
		else {
			_parent = node;
		}
	}

	-(PGBinaryTreeNode *)rootNode {
		return (self.parent ? self.parent.rootNode : self);
	}

	-(PGBinaryTreeNode *)sibling {
		return [self getChild:(self == self.parent.rightChild)];
	}

	-(PGBinaryTreeNode *)uncle {
		return self.parent.sibling;
	}

	-(PGBinaryTreeNode *)grandparent {
		return self.parent.parent;
	}

	-(instancetype)getChild:(BOOL)left {
		return (left ? self.leftChild : self.rightChild);
	}

	-(instancetype)setChild:(PGBinaryTreeNode *)child onLeft:(BOOL)left {
		return (left ? (self.leftChild = child) : (self.rightChild = child));
	}

	-(void)makeOrphan {
		[self.parent setChild:nil onLeft:(self == self.parent.leftChild)];
	}

	-(void)setLeftChild:(PGBinaryTreeNode *)child {
		if(self == child) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be its own child." userInfo:nil];
		}
		else if(_leftChild != child) {
			[child makeOrphan];
			_leftChild.parent = nil;
			_leftChild = child;
			_leftChild.parent = self;
			[self recount];
		}
	}

	-(void)setRightChild:(PGBinaryTreeNode *)child {
		if(self == child) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be its own child." userInfo:nil];
		}
		else if(_rightChild != child) {
			[child makeOrphan];
			_rightChild.parent = nil;
			_rightChild = child;
			_rightChild.parent = self;
			[self recount];
		}
	}

	-(void)rotate:(BOOL)left {
		PGBinaryTreeNode *child = [self getChild:!left];

		if(child) {
			[self.parent setChild:child onLeft:(self == self.parent.leftChild)];
			[self setChild:[child getChild:left] onLeft:!left];
			[child setChild:self onLeft:left];
			BOOL r = self.isRed;
			self.isRed  = child.isRed;
			child.isRed = r;
		}
		else {
			NSString *reason = PGFormat(@"Node cannot be rotated to the %@ because it has no %@ child.",
										(left ? @"left" : @"right"),
										(left ? @"right" : @"left"));
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
		}
	}

#if NS_BLOCKS_AVAILABLE

	-(instancetype)findNodeForKey:(id)key comparator:(NSComparator)compare {
		if(key) {
			if(compare) {
				switch(compare(key, self.key)) {
					case NSOrderedSame:
						return self;
					case NSOrderedAscending:
						return [self.leftChild findNodeForKey:key comparator:compare];
					case NSOrderedDescending:
						return [self.rightChild findNodeForKey:key comparator:compare];
				}
			}
			else {
				return [self findNodeForKey:key];
			}
		}

		return nil;
	}

#endif

	-(instancetype)findNodeForKey:(id)key {
#if NS_BLOCKS_AVAILABLE
		return [self findNodeForKey:key comparator:^NSComparisonResult(id obj1, id obj2) {
			return PGCompare(obj1, obj2);
		}];
#else
		if(key) {
			switch(PGCompare(key, self.key)) {
				case NSOrderedSame:
					return self;
				case NSOrderedAscending:
					return [self.leftChild findNodeForKey:key];
				case NSOrderedDescending:
					return [self.rightChild findNodeForKey:key];
			}
		}

		return nil;
#endif
	}

	-(instancetype)iRebalance {
		PGBinaryTreeNode *pNode = self.parent;

		if(pNode) {
			if(pNode.isRed) {
				PGBinaryTreeNode *gNode = pNode.parent;
				BOOL             pRight = (pNode == gNode.rightChild);
				PGBinaryTreeNode *uNode = [gNode getChild:pRight];

				if(uNode.isRed) {
					uNode.isRed = pNode.isRed = !(gNode.isRed = YES);
					[gNode iRebalance];
				}
				else {
					BOOL meLeft = (self == self.leftChild);

					if(meLeft == pRight) {
						[pNode rotate:!pRight];
					}

					[gNode rotate:pRight];
				}
			}
		}
		else {
			self.isRed = NO;
		}

		return self;
	}

	-(void)rRebalance {
		PGBinaryTreeNode *pNode = self.parent;

		if(pNode) {
			BOOL             meRight = (self == pNode.rightChild);
			PGBinaryTreeNode *sNode  = [pNode getChild:meRight];

			if(sNode.isRed) {
				[pNode rotate:!meRight];
				sNode = [pNode getChild:meRight];
			}

			if(!(sNode.isRed || sNode.leftChild.isRed || sNode.rightChild.isRed)) {
				sNode.isRed = NO;

				if(pNode.isRed) {
					pNode.isRed = NO;
				}
				else {
					[pNode rRebalance];
				}
			}
			else {
				if(![sNode getChild:meRight].isRed) {
					[sNode rotate:meRight];
					sNode = sNode.parent;
				}

				[pNode rotate:!meRight];
				[sNode getChild:meRight].isRed = NO;
			}
		}
	}

#if NS_BLOCKS_AVAILABLE

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key comparator:(NSComparator)cmp {
		if(key && value) {
			if(cmp) {
				switch(cmp(key, self.key)) {
					case NSOrderedSame:
						self.value = value;
						return self;
					case NSOrderedAscending:
						if(self.leftChild) {
							return [self.leftChild insertValue:value forKey:key comparator:cmp];
						}
						else {
							return [(self.leftChild = [(id)[[self class] alloc] initWithKey:key value:value]) iRebalance];
						}
					case NSOrderedDescending:
						if(self.rightChild) {
							return [self.rightChild insertValue:value forKey:key comparator:cmp];
						}
						else {
							return [(self.rightChild = [(id)[[self class] alloc] initWithKey:key value:value]) iRebalance];
						}
				}
			}
			else {
				return [self insertValue:value forKey:key];
			}
		}
		else {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key and Value cannot be nil." userInfo:nil];
		}

		return nil;
	}

#endif

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
#if NS_BLOCKS_AVAILABLE
		return [self insertValue:value forKey:key comparator:^NSComparisonResult(id obj1, id obj2) {
			return PGCompare(obj1, obj2);
		}];
#else
		if(key && value) {
			switch(cmp(key, self.key)) {
				case NSOrderedSame:
					self.value = value;
					return self;
				case NSOrderedAscending:
					if(self.leftChild) {
						return [self.leftChild insertValue:value forKey:key];
					}
					else {
						return [(self.leftChild = [(id)[[self class] alloc] initWithKey:key value:value]) iRebalance];
					}
				case NSOrderedDescending:
					if(self.rightChild) {
						return [self.rightChild insertValue:value forKey:key];
					}
					else {
						return [(self.rightChild = [(id)[[self class] alloc] initWithKey:key value:value]) iRebalance];
					}
			}
		}
		else {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key and Value cannot be nil." userInfo:nil];
		}

		return nil;
#endif
	}

	-(instancetype)farRight {
		return (self.rightChild ? self.rightChild.farRight : self);
	}

	-(instancetype)remove {
		PGBinaryTreeNode *lNode = self.leftChild;
		PGBinaryTreeNode *rNode = self.rightChild;

		if(lNode && rNode) {
			PGBinaryTreeNode *node = lNode.farRight;
			self.key   = node.key;
			self.value = node.value;
			return [node remove];
		}
		else {
			PGBinaryTreeNode *cNode = (lNode ? lNode : rNode);
			PGBinaryTreeNode *pNode = self.parent;

			if(cNode) {
				cNode.isRed = NO;
				[pNode setChild:cNode onLeft:(self == pNode.leftChild)];
			}
			else if(pNode) {
				if(!self.isRed) {
					[self rRebalance];
				}

				[self makeOrphan];
			}

			self.key   = nil;
			self.value = nil;
			return (pNode ? pNode.rootNode : cNode.rootNode);
		}
	}

	+(instancetype)nodeWithKey:(id<NSCopying>)key value:(id)value {
		return [[self alloc] initWithKey:key value:value];
	}

@end
