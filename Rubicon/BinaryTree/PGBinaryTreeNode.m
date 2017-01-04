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

@interface PGBinaryTreeLeaf()

	-(PGBinaryTreeLeaf *)makeOrphan;

	-(PGBinaryTreeLeaf *)adoptMe:(PGBinaryTreeLeaf *)newParent;

	-(void)resetSize;

@end

@implementation PGBinaryTreeNode {
		BOOL             _isRed;
		NSUInteger _count;
		PGBinaryTreeLeaf *_left;
		PGBinaryTreeLeaf *_right;
		NSSize     _desiredSize;
		BOOL       _desiredSizeDirty;
	}

	-(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key {
		self = [super initWithValue:value forKey:key];

		if(self) {
			self.isRed = NO;
			self.left  = [[PGBinaryTreeLeaf alloc] init];
			self.right = [[PGBinaryTreeLeaf alloc] init];
			_count            = 0;
			_desiredSize      = NSZeroSize;
			_desiredSizeDirty = YES;
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

	-(NSSize)drawSize {
		@synchronized(self) {
			if(_desiredSizeDirty) {
				_desiredSize      = [super drawSize];
				_desiredSizeDirty = NO;
			}

			return _desiredSize;
		}
	}

	-(void)resetSize {
		_desiredSizeDirty = YES;
		_desiredSize      = NSZeroSize;
		[super resetSize];
	}

	-(void)setLeft:(PGBinaryTreeLeaf *)child {
		if(_left != child) {
			_count -= _left.count;
			_left.parent = nil;
			_left = [child adoptMe:self];
			_count += _left.count;
			[self resetSize];
		}
	}

	-(void)setRight:(PGBinaryTreeLeaf *)child {
		if(_right != child) {
			_count -= _right.count;
			_right.parent = nil;
			_right = [child adoptMe:self];
			_count += _right.count;
			[self resetSize];
		}
	}

	-(NSUInteger)count {
		return (1 + _count);
	}

@end
