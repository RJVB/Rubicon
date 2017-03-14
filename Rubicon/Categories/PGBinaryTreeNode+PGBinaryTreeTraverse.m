/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode(PGBinaryTreeTraverse).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/14/17 3:19 PM
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

#import "PGBinaryTreeNode+PGBinaryTreeTraverse.h"

@implementation PGKVNodeVisitor

	-(BOOL)visitNodeWithKey:(id)aKey andValue:(id)aValue {
		return NO;
	}

@end

@implementation PGBinaryTreeNode(PGBinaryTreeTraverse)

#if NS_BLOCKS_AVAILABLE

	-(BOOL)travelForwardTreeWithBlock:(PGKVNodeVisitorBlock)visitorBlock {
		BOOL willContinue = NO;

		if(visitorBlock) {
			willContinue = (self.leftChild ? [self.leftChild travelForwardTreeWithBlock:visitorBlock] : YES);
			willContinue = (willContinue && visitorBlock(self.key, self.value));
			willContinue = (willContinue && (self.rightChild ? [self.rightChild travelForwardTreeWithBlock:visitorBlock] : YES));
		}

		return willContinue;
	}

	-(BOOL)travelBackwardTreeWithBlock:(PGKVNodeVisitorBlock)visitorBlock {
		BOOL willContinue = NO;

		if(visitorBlock) {
			willContinue = (self.rightChild ? [self.rightChild travelForwardTreeWithBlock:visitorBlock] : YES);
			willContinue = (willContinue && visitorBlock(self.key, self.value));
			willContinue = (willContinue && (self.leftChild ? [self.leftChild travelForwardTreeWithBlock:visitorBlock] : YES));
		}

		return willContinue;
	}

#endif

	-(BOOL)travelForwardTreeWithVisitor:(PGKVNodeVisitor *)visitor {
		BOOL willContinue = NO;

		if(visitor) {
			willContinue = (self.leftChild ? [self.leftChild travelForwardTreeWithVisitor:visitor] : YES);
			willContinue = (willContinue && [visitor visitNodeWithKey:self.key andValue:self.value]);
			willContinue = (willContinue && (self.rightChild ? [self.rightChild travelForwardTreeWithVisitor:visitor] : YES));
		}

		return willContinue;
	}

	-(BOOL)travelBackwardTreeWithVisitor:(PGKVNodeVisitor *)visitor {
		BOOL willContinue = NO;

		if(visitor) {
			willContinue = (self.rightChild ? [self.rightChild travelForwardTreeWithVisitor:visitor] : YES);
			willContinue = (willContinue && [visitor visitNodeWithKey:self.key andValue:self.value]);
			willContinue = (willContinue && (self.leftChild ? [self.leftChild travelForwardTreeWithVisitor:visitor] : YES));
		}

		return willContinue;
	}

@end
