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
#import "NSObject+PGObject.h"

@interface PGBinaryTreeNode()

	-(BOOL)isRed;

	-(void)setIsRed:(BOOL)b;

	-(void)recount;

	-(void)setKey:(id<NSCopying>)key;

	-(void)makeOrphan;

	-(instancetype)replaceMeWith:(PGBinaryTreeNode *)cnode;

	-(instancetype)setChild:(PGBinaryTreeNode *)cnode onLeft:(BOOL)left;

	-(void)rotate:(BOOL)left;

	-(void)postInsertRebalance;

	-(instancetype)preRemoveRebalance;

	+(NSComparisonResult)compareKey:(id)key1 toKey:(id)key2;

@end

#define OPN(B, N) ((B)?((N).rightNode):((N).leftNode))
#define ONP(B, N) ((B)?((N).leftNode):((N).rightNode))
#define ALLBLACK(N) (!((N).isRed || (N).leftNode.isRed || (N).rightNode.isRed))
#define ISBLACK(N) (!(N).isRed)

@implementation PGBinaryTreeNode {
		BOOL _isRed;
	}

	@synthesize key = _key;
	@synthesize value = _value;
	@synthesize parentNode = _parentNode;
	@synthesize leftNode = _leftNode;
	@synthesize rightNode = _rightNode;
	@synthesize count = _count;

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value isRed:(BOOL)isRed {
		self = [super init];

		if(self) {
			self.key   = key;
			self.value = value;
			self.isRed = isRed;
			_count = 1;
		}

		return self;
	}

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value {
		return (self = [self initWithKey:key value:value isRed:NO]);
	}

	+(instancetype)nodeWithKey:(id<NSCopying>)key value:(id)value isRed:(BOOL)isRed {
		return [[self alloc] initWithKey:key value:value isRed:isRed];
	}

	+(instancetype)nodeWithKey:(id<NSCopying>)key value:(id)value {
		return [self nodeWithKey:key value:value isRed:NO];
	}

	-(BOOL)isRed {
		return _isRed;
	}

	-(void)setIsRed:(BOOL)b {
		_isRed = b;
	}

	-(void)recount {
		_count = (1 + self.leftNode.count + self.rightNode.count);
		[self.parentNode recount];
	}

	-(void)setKey:(id<NSCopying>)key {
		_key = [(id)key copy];
	}

	-(void)setParentNode:(PGBinaryTreeNode *)parentNode {
		if(self == parentNode) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Node cannot be a parent to itself." userInfo:nil];
		}
		else if(_parentNode != parentNode) {
			PGBinaryTreeNode *oldParent = _parentNode;
			_parentNode = nil;
			[oldParent recount];
			_parentNode = parentNode;
			[_parentNode recount];
		}
	}

	-(void)makeOrphan {
		PGBinaryTreeNode *parent = self.parentNode;

		if(parent) {
			if(self == parent.leftNode) {
				parent.leftNode = nil;
			}
			else if(self == parent.rightNode) {
				parent.rightNode = nil;
			}

			self.parentNode = nil;
		}
	}

	-(instancetype)replaceMeWith:(PGBinaryTreeNode *)cnode {
		PGBinaryTreeNode *parent = self.parentNode;

		if(self != cnode) {
			[cnode makeOrphan];

			if(parent) {
				[parent setChild:cnode onLeft:(self == parent.leftNode)];
				self.parentNode = nil;
			}
		}

		return cnode;
	}

	-(void)setLeftNode:(PGBinaryTreeNode *)leftNode {
		if(self == leftNode) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Node cannot be a child to itself." userInfo:nil];
		}
		else if(_leftNode != leftNode) {
			[leftNode makeOrphan];
			_leftNode.parentNode = nil;
			_leftNode = leftNode;
			_leftNode.parentNode = self;
		}
	}

	-(void)setRightNode:(PGBinaryTreeNode *)rightNode {
		if(self == rightNode) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Node cannot be a child to itself." userInfo:nil];
		}
		else if(_rightNode != rightNode) {
			[rightNode makeOrphan];
			_rightNode.parentNode = nil;
			_rightNode = rightNode;
			_rightNode.parentNode = self;
		}
	}

	-(instancetype)setChild:(PGBinaryTreeNode *)cnode onLeft:(BOOL)left {
		if(left) {
			self.leftNode = cnode;
		}
		else {
			self.rightNode = cnode;
		}

		return cnode;
	}

	-(BOOL)isRootNode {
		return (self.parentNode == nil);
	}

	-(PGBinaryTreeNode *)rootNode {
		return (self.isRootNode ? self : self.parentNode.rootNode);
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
#if NS_BLOCKS_AVAILABLE
		return [self insertValue:value forKey:key comparator:^NSComparisonResult(id obj1, id obj2) {
			return [[self class] compareKey:obj1 toKey:obj2];
		}];
#else
		if(key && value) {
			switch([[self class] compareKey:self.key toKey:key]) {
				case NSOrderedAscending:
					if(self.rightNode) {
						return [self.rightNode insertValue:value forKey:key];
					}
					else {
						PGBinaryTreeNode *node = self.rightNode = [(id)[[self class] alloc] initWithKey:key value:value isRed:YES];
						[node postInsertRebalance];
						return node;
					}
				case NSOrderedDescending:
					if(self.leftNode) {
						return [self.leftNode insertValue:value forKey:key];
					}
					else {
						PGBinaryTreeNode *node = self.leftNode = [(id)[[self class] alloc] initWithKey:key value:value isRed:YES];
						[node postInsertRebalance];
						return node;
					}
				default:
					self.value = value;
					return self;
			}
		}

		return nil;
#endif
	}

	-(instancetype)findNodeForKey:(id)key {
#if NS_BLOCKS_AVAILABLE
		return [self findNodeForKey:key comparator:^NSComparisonResult(id obj1, id obj2) {
			return [[self class] compareKey:obj1 toKey:obj2];
		}];
#else
		if(key) {
			switch([[self class] compareKey:self.key toKey:key]) {
				case NSOrderedAscending:
					return [self.rightNode findNodeForKey:key];
				case NSOrderedDescending:
					return [self.leftNode findNodeForKey:key];
				default:
					return self;
			}
		}

		return nil;
#endif
	}

	-(void)rotate:(BOOL)left {
		PGBinaryTreeNode *node = OPN(left, self);

		if(node) {
			[self replaceMeWith:node];
			[self setChild:ONP(left, node) onLeft:!left];
			[node setChild:self onLeft:left];
		}
		else {
			NSString *reason = [NSString stringWithFormat:@"Node cannot be rotated to the %@.", left ? @"left" : @"right"];
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
		}
	}

	-(void)postInsertRebalance {
		PGBinaryTreeNode *pNode = self.parentNode;

		if(pNode) {
			if(pNode.isRed) {
				PGBinaryTreeNode *gNode = pNode.parentNode;
				BOOL             pRight = (pNode == gNode.rightNode);
				PGBinaryTreeNode *uNode = ONP(pRight, gNode);

				gNode.isRed = YES;

				if(uNode.isRed) {
					pNode.isRed = uNode.isRed = NO;
					[gNode postInsertRebalance];
				}
				else {
					BOOL sLeft = (self == pNode.leftNode);

					if(sLeft == pRight) {
						[pNode rotate:!sLeft];
						[gNode rotate:sLeft];
						self.isRed = NO;
					}
					else {
						[gNode rotate:pRight];
						pNode.isRed = NO;
					}
				}
			}
		}
		else {
			self.isRed = NO;
		}
	}

	-(instancetype)farLeft {
		PGBinaryTreeNode *lNode = self.leftNode;
		return (lNode ? lNode.farLeft : self);
	}

	-(instancetype)remove {
		PGBinaryTreeNode *lnode = self.leftNode;
		PGBinaryTreeNode *rnode = self.rightNode;

		if(lnode && rnode) {
			PGBinaryTreeNode *node = rnode.farLeft;
			self.key   = node.key;
			self.value = node.value;
			return [node remove];
		}
		else {
			PGBinaryTreeNode *parent = self.parentNode;
			PGBinaryTreeNode *node   = (lnode ? lnode : rnode);
			PGBinaryTreeNode *root   = nil;

			if(node) {
				node.isRed = NO;
				root = [[self replaceMeWith:node] rootNode];
			}
			else if(parent) {
				if(ISBLACK(self)) [self preRemoveRebalance:parent];
				[self makeOrphan];
				root = parent.rootNode;
			}

			self.key   = nil;
			self.value = nil;
			return root;
		}
	}

	-(instancetype)preRemoveRebalance {
		PGBinaryTreeNode *parent = self.parentNode;

		if(parent) {
			[self preRemoveRebalance:parent];
		}

		return parent;
	}

	-(void)preRemoveRebalance:(PGBinaryTreeNode *)parent {
		BOOL             sLeft    = (self == parent.leftNode);
		PGBinaryTreeNode *sibling = OPN(sLeft, parent);

		if(sibling.isRed) {
			parent.isRed  = YES;
			sibling.isRed = NO;
			[parent rotate:sLeft];
			sibling = OPN(sLeft, parent);
		}

		if(ALLBLACK(sibling)) {
			sibling.isRed = YES;
			if(parent.isRed) parent.isRed = NO; else [parent preRemoveRebalance];
		}
		else {
			BOOL sRight = !sLeft;

			if(ISBLACK(OPN(sLeft, sibling))) {
				sibling.isRed = YES;
				OPN(sRight, sibling).isRed = NO;
				[sibling rotate:sRight];
				sibling = sibling.parentNode;
			}

			sibling.isRed = parent.isRed;
			parent.isRed  = NO;
			OPN(sLeft, sibling).isRed = NO;
			[parent rotate:sLeft];
		}
	}

	-(BOOL)travelTree:(id<PGBinaryTreeTraveler>)traveler backwards:(BOOL)backwards {
		BOOL willContinue = NO;

		if(traveler) {
			if(backwards) {
				if(self.rightNode) {
					willContinue = [self.rightNode travelTree:traveler backwards:backwards];
				}

				if(willContinue) {
					willContinue = [traveler visitNodeWithKey:self.key andValue:self.value];
				}

				if(willContinue && self.leftNode) {
					willContinue = [self.leftNode travelTree:traveler backwards:backwards];
				}
			}
			else {
				if(self.leftNode) {
					willContinue = [self.leftNode travelTree:traveler backwards:backwards];
				}

				if(willContinue) {
					willContinue = [traveler visitNodeWithKey:self.key andValue:self.value];
				}

				if(willContinue && self.rightNode) {
					willContinue = [self.rightNode travelTree:traveler backwards:backwards];
				}
			}
		}

		return willContinue;
	}

#if NS_BLOCKS_AVAILABLE

	-(BOOL)travelTreeWithBlock:(PGBinaryTreeTravelBlock)travelBlock backwards:(BOOL)backwards {
		BOOL willContinue = NO;

		if(travelBlock) {
			if(backwards) {
				if(self.rightNode) {
					willContinue = [self.rightNode travelTreeWithBlock:travelBlock backwards:backwards];
				}

				if(willContinue) {
					willContinue = travelBlock(self.key, self.value);
				}

				if(willContinue && self.leftNode) {
					willContinue = [self.leftNode travelTreeWithBlock:travelBlock backwards:backwards];
				}
			}
			else {
				if(self.leftNode) {
					willContinue = [self.leftNode travelTreeWithBlock:travelBlock backwards:backwards];
				}

				if(willContinue) {
					willContinue = travelBlock(self.key, self.value);
				}

				if(willContinue && self.rightNode) {
					willContinue = [self.rightNode travelTreeWithBlock:travelBlock backwards:backwards];
				}
			}
		}

		return willContinue;
	}

	-(instancetype)findNodeForKey:(id)key comparator:(NSComparator)compare {
		if(key) {
			if(compare == nil) {
				return [self findNodeForKey:key];
			}
			else {
				switch(compare(self.key, key)) {
					case NSOrderedAscending:
						return [self.rightNode findNodeForKey:key comparator:compare];
					case NSOrderedDescending:
						return [self.leftNode findNodeForKey:key comparator:compare];
					default:
						return self;
				}
			}
		}

		return nil;
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key comparator:(NSComparator)compare {
		if(compare == nil) {
			return [self insertValue:value forKey:key];
		}
		else if(key && value) {
			switch(compare(self.key, key)) {
				case NSOrderedAscending:
					if(self.rightNode) {
						return [self.rightNode insertValue:value forKey:key comparator:compare];
					}
					else {
						PGBinaryTreeNode *node = self.rightNode = [(id)[[self class] alloc] initWithKey:key value:value isRed:YES];
						[node postInsertRebalance];
						return node;
					}
				case NSOrderedDescending:
					if(self.leftNode) {
						return [self.leftNode insertValue:value forKey:key comparator:compare];
					}
					else {
						PGBinaryTreeNode *node = self.leftNode = [(id)[[self class] alloc] initWithKey:key value:value isRed:YES];
						[node postInsertRebalance];
						return node;
					}
				default:
					self.value = value;
					return self;
			}
		}

		return nil;
	}

#endif

	+(NSComparisonResult)compareKey:(id)key1 toKey:(id)key2 {
		if(key1 && key2) {
			if([[key1 baseClassInCommonWith:key2] instancesRespondToSelector:@selector(compare:)]) {
				return [key1 compare:key2];
			}
			else {
				@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Keys cannot be compared." userInfo:nil];
			}
		}
		else {
			return (key1 ? NSOrderedDescending : (key2 ? NSOrderedAscending : NSOrderedSame));
		}
	}

@end
