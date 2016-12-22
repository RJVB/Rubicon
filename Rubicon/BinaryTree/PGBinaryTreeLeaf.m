/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/21/16 4:57 PM
 * DESCRIPTION:
 *
 * Copyright © 2016 Project Galen. All rights reserved.
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

#import "PGBinaryTreeLeaf.h"
#import "NSObject+PGObject.h"

@implementation PGBinaryTreeLeaf {
		NSComparator _comparator;
	}

	@synthesize parent = _parent;

	-(instancetype)init {
		return (self = [self initWithKey:nil value:nil comparator:[PGBinaryTreeLeaf defaultComparator]]);
	}

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value comparator:(NSComparator)comparator {
		self = [super init];

		if(self) {
			self.key   = key;
			self.value = value;
			_comparator = (comparator ? comparator : [PGBinaryTreeLeaf defaultComparator]);
		}

		return self;
	}

	-(NSComparator)comparator {
		return _comparator;
	}

	-(PGBinaryTreeLeaf *)root {
		return (self.isRoot ? self : self.parent.root);
	}

	-(PGBinaryTreeLeaf *)grandparent {
		return self.parent.parent;
	}

	-(PGBinaryTreeLeaf *)uncle {
		return self.parent.sibling;
	}

	-(PGBinaryTreeLeaf *)sibling {
		return (self.isLeft ? self.parent.right : (self.isRight ? self.parent.left : nil));
	}

	-(BOOL)isRoot {
		return (self.parent == nil);
	}

	-(BOOL)isLeft {
		return (self == self.parent.left);
	}

	-(BOOL)isRight {
		return (self == self.parent.right);
	}

	-(BOOL)isRed {
		return NO;
	}

	-(void)setIsRed:(BOOL)isRed {
	}

	-(BOOL)isBlack {
		return !self.isRed;
	}

	-(void)setIsBlack:(BOOL)isBlack {
		self.isRed = !isBlack;
	}

	-(BOOL)isLeaf {
		return YES;
	}

	-(id)value {
		return nil;
	}

	-(void)setValue:(id)value {}

	-(id)key {
		return nil;
	}

	-(void)setKey:(id)key {}

	-(PGBinaryTreeLeaf *)left {
		return nil;
	}

	-(void)setLeft:(PGBinaryTreeLeaf *)left {}

	-(PGBinaryTreeLeaf *)right {
		return nil;
	}

	-(void)setRight:(PGBinaryTreeLeaf *)right {}

	-(void)setChild:(PGBinaryTreeLeaf *)child onLeft:(BOOL)onLeft {
		if(onLeft) self.left = child; else self.right = child;
	}

	/************************************************************************************************************//**
	 *        (X)              (X)              (X)                 (X)           (X)           (X)         (X)
	 *        /                                                     /             /             /           /
	 *       /                                                     /             /             /           /
	 *     (B)              (B)              (B)             (B) (D)           (D)           (D)         (D)
	 *     / \              / \              /               /   /                                       /
	 *    /   \            /   \            /               /   /                                       /
	 *  (A)   (D)  ===>  (A)   (D)  ===>  (A)   (D)  ===> (A) (C)    ===>   (B)    ===>   (B)   ===>  (B)
	 *        /    148         /                /                    149    /             / \   150   / \
	 *       /                /                /                           /             /   \       /   \
	 *     (C)              (C)              (C)                         (A)   (C)     (A)   (C)   (A)   (C)
	 ****************************************************************************************************************/
	-(void)rotateLeft {
		PGBinaryTreeLeaf *nodeD = self.right;
		[self.parent setChild:nodeD onLeft:self.isLeft];
		[self setRight:nodeD.left];
		[nodeD setLeft:self];
	}

	-(void)rotateRight {
		PGBinaryTreeLeaf *nodeD = self.left;
		[self.parent setChild:nodeD onLeft:self.isLeft];
		[self setLeft:nodeD.right];
		[nodeD setRight:self];
	}

	-(void)rotate:(BOOL)left {
		if(left) [self rotateLeft]; else [self rotateRight];
	}

	-(instancetype)_find:(id)key {
		if(self.isLeaf) {
			return self;
		}
		else {
			switch(self.comparator(self.key, key)) {
				case NSOrderedAscending:
					return [self.right find:key];
				case NSOrderedDescending:
					return [self.left find:key];
				case NSOrderedSame:
				default:
					return self;
			}
		}
	}

	-(instancetype)find:(id)key {
		PGBinaryTreeLeaf *n = [self _find:key];
		return (n.isLeaf ? nil : n);
	}

	-(void)insertStep1 {
		PGBinaryTreeLeaf *nodeP = self.parent;

		if(nodeP) {
			if(nodeP.isRed) {
				PGBinaryTreeLeaf *nodeG = self.grandparent;
				PGBinaryTreeLeaf *nodeU = self.uncle;

				nodeG.isRed = YES;

				if(nodeU.isRed) {
					nodeU.isBlack = nodeP.isBlack = YES;
					[nodeG insertStep1];
				}
				else {
					if(self.isRight == nodeP.isLeft) {
						self.isBlack = YES;
						[nodeP rotate:self.isRight];
					}
					else {
						nodeP.isBlack = YES;
					}

					[nodeG rotate:self.isRight];
				}
			}
		}
		else {
			self.isRed = NO;
		}
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
		PGBinaryTreeLeaf *n = [self _find:key];

		if(n.isLeaf) {
			PGBinaryTreeLeaf *c = [(PGBinaryTreeLeaf *)[[self class] alloc] initWithKey:key value:value comparator:self.comparator];
			[n.parent setChild:c onLeft:n.isLeft];
			[c setIsRed:YES];
			[c insertStep1];
			return c;
		}
		else {
			n.value = value;
			return n;
		}
	}

	-(instancetype)farLeft { return (self.isLeaf ? self.parent : self.left.farLeft); }

	-(instancetype)child:(BOOL)left { return (left ? self.left : self.right); }

	-(void)removeStep1 {
		PGBinaryTreeLeaf *nodeP = self.parent;

		if(nodeP) {
			PGBinaryTreeLeaf *nodeS = self.sibling;
			BOOL             isL    = self.isLeft;

			if(nodeS.isRed) {
				nodeP.isRed = nodeS.isBlack = YES;
				[nodeP rotate:isL];
				nodeS = self.sibling;
			}

			if(nodeS.right.isBlack && nodeS.left.isBlack) {
				nodeS.isRed = YES;

				if(nodeP.isRed) {
					[nodeP removeStep1];
				}
				else {
					nodeP.isBlack = YES;
				}
			}
			else {
				BOOL isR = !isL;

				if([nodeS child:isR].isBlack) {
					nodeS.isRed = [nodeS child:isL].isBlack = YES;
					[nodeS rotate:isR];
					nodeS = nodeS.parent;
				}

				nodeS.isRed   = nodeP.isRed;
				nodeP.isBlack = [nodeS child:isR].isBlack = YES;
				[nodeP rotate:isL];
			}
		}
	}

	-(void)remove {
		if(self.left.isLeaf || self.right.isLeaf) {
			PGBinaryTreeLeaf *nodeP = self.parent;
			PGBinaryTreeLeaf *nodeC = (self.left.isLeaf ? self.right : self.left);

			if(self.isBlack) {
				if(nodeC.isBlack) {
					[self removeStep1];
				}
				else {
					nodeC.isBlack = YES;
				}
			}

			[nodeP setChild:nodeC onLeft:(self == nodeP.left)];
			self.value  = nil;
			self.key    = nil;
			self.parent = nil;
			self.right  = nil;
			self.left   = nil;
		}
		else {
			PGBinaryTreeLeaf *successor = self.right.farLeft;
			self.key   = successor.key;
			self.value = successor.value;
			[successor remove];
		}
	}

	-(void)draw {}

	-(NSUInteger)count {
		return (self.isLeaf ? 0 : (1 + self.left.count + self.right.count));
	}

@end
