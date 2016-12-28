/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTree.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/22/16 1:03 PM
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

#import "PGBinaryTree.h"
#import "PGBinaryTreeNode.h"
#import "PGBinaryTreeKVNode.h"
#import "NSObject+PGObject.h"

@implementation PGBinaryTree {
		PGBinaryTreeLeaf *_root;
	}

	@synthesize comparator = _comparator;

	-(NSUInteger)count {
		return _root.count;
	}

	-(instancetype)init {
		return (self = [self initWithComparator:nil]);
	}

	-(instancetype)initWithComparator:(NSComparator)comparator {
		self = [super init];

		if(self) {
			_root       = nil;
			_comparator = [(comparator ? comparator : [PGBinaryTree defaultComparator]) copy];
		}

		return self;
	}

	-(void)addValue:(id)value forKey:(id<NSCopying>)key {
		_root = (_root ? [_root insertValue:value forKey:key withComparator:^NSComparisonResult(id obj1, id obj2) {
			return NSOrderedSame;
		}].root : [[PGBinaryTreeKVNode alloc] initWithValue:value forKey:key]);
	}

	-(id)valueForKey:(id)key {
		return [_root find:key withComparator:^NSComparisonResult(id obj1, id obj2) {
			return NSOrderedSame;
		}].value;
	}

	-(void)removeValueForKey:(id)key {
		PGBinaryTreeLeaf *node = [_root find:key withComparator:^NSComparisonResult(id obj1, id obj2) {
			return NSOrderedSame;
		}];

		if(node) {
			PGBinaryTreeLeaf *z = (node.parent ? node.parent : (node.left.isLeaf ? node.right : node.left));
			[node remove];
			_root = (z.isLeaf ? nil : [z root]);
		}
	}

@end