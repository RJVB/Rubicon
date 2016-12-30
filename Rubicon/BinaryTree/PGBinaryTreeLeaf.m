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

PGBinaryTreeLeaf *removeStep2(PGBinaryTreeLeaf *nodeP, PGBinaryTreeLeaf *nodeS, BOOL isL);

void removeStep3(PGBinaryTreeLeaf *nodeP, PGBinaryTreeLeaf *nodeS, BOOL isL);

@implementation PGBinaryTreeLeaf {
	}

	@synthesize parent = _parent;

	-(instancetype)init { return (self = [self initWithValue:nil forKey:nil]); }

	-(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key {
		self = [super init];

		if(self) {
			self.key   = key;
			self.value = value;
		}

		return self;
	}

	-(instancetype)farLeft { return (self.isLeaf ? self.parent : self.left.farLeft); }

	-(instancetype)child:(BOOL)left { return (left ? self.left : self.right); }

	-(instancetype)_find:(id)key withComparator:(NSComparator)comparator {
		if(self.isLeaf || self.key == key) {
			return self;
		}
		else if(comparator) {
			switch(comparator(self.key, key)) {
				case NSOrderedAscending:
					return [self.right _find:key withComparator:comparator];
				case NSOrderedDescending:
					return [self.left _find:key withComparator:comparator];
				case NSOrderedSame:
				default:
					return self;
			}
		}
		else {
			return [self _find:key withComparator:[NSObject defaultComparator]];
		}
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key withReferenceNode:(PGBinaryTreeLeaf *)n {
		if(n.isLeaf) {
			PGBinaryTreeLeaf *c = [(PGBinaryTreeLeaf *)[[self class] alloc] initWithValue:value forKey:key];
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

	-(void)removeStep1 {
		PGBinaryTreeLeaf *nodeP = self.parent;

		if(nodeP) {
			BOOL isL = self.isLeft;
			removeStep3(nodeP, removeStep2(nodeP, self.sibling, isL), isL);
		}
	}

	-(NSUInteger)count { return (self.isLeaf ? 0 : (1 + self.left.count + self.right.count)); }

	-(PGBinaryTreeLeaf *)root { return (self.isRoot ? self : self.parent.root); }

	-(PGBinaryTreeLeaf *)grandparent { return self.parent.parent; }

	-(PGBinaryTreeLeaf *)uncle { return self.parent.sibling; }

	-(PGBinaryTreeLeaf *)sibling { return (self.isLeft ? self.parent.right : (self.isRight ? self.parent.left : nil)); }

	-(BOOL)isRoot { return (self.parent == nil); }

	-(BOOL)isLeft { return (self == self.parent.left); }

	-(BOOL)isRight { return (self == self.parent.right); }

	-(BOOL)isRed { return NO; }

	-(void)setIsRed:(BOOL)isRed {}

	-(BOOL)isBlack { return !self.isRed; }

	-(void)setIsBlack:(BOOL)isBlack { self.isRed = !isBlack; }

	-(BOOL)isLeaf { return YES; }

	-(id)value { return nil; }

	-(void)setValue:(id)value {}

	-(id)key { return nil; }

	-(void)setKey:(id<NSCopying>)key {}

	-(PGBinaryTreeLeaf *)left { return nil; }

	-(void)setLeft:(PGBinaryTreeLeaf *)left {}

	-(PGBinaryTreeLeaf *)right { return nil; }

	-(void)setRight:(PGBinaryTreeLeaf *)right {}

	-(void)setChild:(PGBinaryTreeLeaf *)child onLeft:(BOOL)onLeft { if(onLeft) self.left = child; else self.right = child; }

	-(void)rotate:(BOOL)left { if(left) [self rotateLeft]; else [self rotateRight]; }

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

	-(instancetype)find:(id)key withComparator:(NSComparator)comparator {
		PGBinaryTreeLeaf *n = [self _find:key withComparator:comparator];
		return (n.isLeaf ? nil : n);
	}

	-(instancetype)find:(id)key {
		return [self find:key withComparator:[NSObject defaultComparator]];
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key withComparator:(NSComparator)comparator {
		return [self insertValue:value forKey:key withReferenceNode:[self _find:key withComparator:comparator]];
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
		return [self insertValue:value forKey:key withComparator:[NSObject defaultComparator]];
	}

	-(void)remove {
		PGBinaryTreeLeaf *childL = self.left;
		PGBinaryTreeLeaf *childR = self.right;
		BOOL             leafL   = childL.isLeaf;
		BOOL             leafR   = childR.isLeaf;

		if(leafL || leafR) {
			PGBinaryTreeLeaf *nodeP = self.parent;
			PGBinaryTreeLeaf *nodeC = (leafL ? childR : childL);
			BOOL             isL    = (self == nodeP.left);

			if(self.isBlack) { if(nodeC.isBlack) [self removeStep1]; else nodeC.isBlack = YES; }
			[nodeP setChild:nodeC onLeft:isL];
			[self clearNode];
		}
		else {
			PGBinaryTreeLeaf *successor = childR.farLeft;
			self.key   = successor.key;
			self.value = successor.value;
			[successor remove];
		}
	}

	-(void)clearNode {
		self.parent = nil;
		self.value  = nil;
		self.key    = nil;
		self.right  = nil;
		self.left   = nil;
	}

	-(void)draw {}

	-(PGBinaryTreeLeaf *)makeOrphan {
		if(self.isRight) self.parent.right = nil; else if(self.isLeft) self.parent.left = nil;
		return self;
	}

	-(PGBinaryTreeLeaf *)adoptMe:(PGBinaryTreeLeaf *)newParent {
		[[self makeOrphan] setParent:newParent];
		return self;
	}

	-(BOOL)isEqual:(id)other { return (other && ((self == other) || ([other isInstanceOfObject:self] && [self isEqualToLeaf:(PGBinaryTreeLeaf *)other]))); }

	-(BOOL)isEqualToLeaf:(PGBinaryTreeLeaf *)leaf { return (self == leaf); }

	-(NSUInteger)hash { return super.hash; }

@end

void removeStep5(PGBinaryTreeLeaf *nodeP, PGBinaryTreeLeaf *nodeS, BOOL isL, BOOL isR) {
	nodeS.isRed   = nodeP.isRed;
	nodeP.isBlack = [nodeS child:isR].isBlack = YES;
	[nodeP rotate:isL];
}

PGBinaryTreeLeaf *removeStep4(PGBinaryTreeLeaf *nodeS, BOOL isL, BOOL isR) {
	if([nodeS child:isR].isBlack) {
		nodeS.isRed = [nodeS child:isL].isBlack = YES;
		[nodeS rotate:isR];
		return nodeS.parent;
	}
	else {
		return nodeS;
	}
}

void removeStep3(PGBinaryTreeLeaf *nodeP, PGBinaryTreeLeaf *nodeS, BOOL isL) {
	if(nodeS.right.isBlack && nodeS.left.isBlack) {
		nodeS.isRed = YES;
		if(nodeP.isRed) [nodeP removeStep1]; else nodeP.isBlack = YES;
	}
	else {
		BOOL isR = !isL;
		removeStep5(nodeP, removeStep4(nodeS, isL, isR), isL, isR);
	}
}

PGBinaryTreeLeaf *removeStep2(PGBinaryTreeLeaf *nodeP, PGBinaryTreeLeaf *nodeS, BOOL isL) {
	if(nodeS.isRed) {
		nodeP.isRed = nodeS.isBlack = YES;
		[nodeP rotate:isL];
		return (isL ? nodeP.right : nodeP.left);
	}
	else {
		return nodeS;
	}
}
