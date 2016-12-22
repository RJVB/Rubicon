/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/22/16 9:42 AM
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

#import "PGBinaryTreeNode.h"

@implementation PGBinaryTreeNode {
		BOOL             _isRed;
		PGBinaryTreeLeaf *_left;
		PGBinaryTreeLeaf *_right;
	}

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value comparator:(NSComparator)comparator {
		self = [super initWithKey:key value:value comparator:comparator];

		if(self) {
			self.isRed = NO;
			self.left  = [[PGBinaryTreeLeaf alloc] init];
			self.right = [[PGBinaryTreeLeaf alloc] init];
		}

		return self;
	}

	-(BOOL)isLeaf {
		return NO;
	}

	-(BOOL)isRed {
		return _isRed;
	}

	-(void)setIsRed:(BOOL)isRed {
		_isRed = isRed;
	}

	-(PGBinaryTreeLeaf *)left {
		return _left;
	}

	-(PGBinaryTreeLeaf *)right {
		return _right;
	}

	-(void)setLeft:(PGBinaryTreeLeaf *)left {
		/*
		 * Don't bother if nothing is changing.
		 */
		if(_left != left) {
			if(_left) {
				/*
				 * Unlink the existing left child.
				 */
				_left.parent = nil;
				_left = nil;
			}

			if(left) {
				PGBinaryTreeLeaf *lparent = left.parent;

				/*
				 * Unlink the new left child from it's existing parent if it has one.
				 */
				if(lparent) {
					if(left == lparent.right) {
						lparent.right = nil;
					}
					else if(left == lparent.left) {
						lparent.left = nil;
					}
					else {
						left.parent = nil;
					}
				}

				_left = left;
				_left.parent = self;
			}
		}
	}

	-(void)setRight:(PGBinaryTreeLeaf *)right {
		/*
		 * Don't bother if nothing is changing.
		 */
		if(_right != right) {
			if(_right) {
				/*
				 * Unlink the existing right child.
				 */
				_right.parent = nil;
				_right = nil;
			}

			if(right) {
				PGBinaryTreeLeaf *rparent = right.parent;

				/*
				 * Unlink the new right child from it's existing parent if it has one.
				 */
				if(rparent) {
					if(right == rparent.right) {
						rparent.right = nil;
					}
					else if(right == rparent.left) {
						rparent.left = nil;
					}
					else {
						right.parent = nil;
					}
				}

				_right = right;
				_right.parent = self;
			}
		}
	}

@end
