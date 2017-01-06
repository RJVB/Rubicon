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

#import "PGBinaryTreeDictionary.h"
#import "PGBinaryTreeNode.h"
#import "PGBinaryTreeKVNode.h"
#import "NSObject+PGObject.h"

@interface PGBinaryTreeEnumerator : NSEnumerator

	@property(nonatomic, weak) PGBinaryTreeLeaf *root;
	@property(nonatomic, weak) PGBinaryTreeLeaf *currentNode;

	-(instancetype)initWithRoot:(PGBinaryTreeLeaf *)aRoot;

@end

@interface PGBinaryTreeLeaf()

	-(instancetype)farLeft;

	-(instancetype)nextNode;

	-(instancetype)prevNode;

@end

@implementation PGBinaryTreeDictionary {
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
			_comparator = [(comparator ? comparator : [PGBinaryTreeDictionary defaultComparator]) copy];
		}

		return self;
	}

	-(NSEnumerator *)keyEnumerator {
		return [super keyEnumerator];
	}

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
		return (self = [self initWithObjects:objects forKeys:keys count:cnt comparator:nil]);
	}

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt comparator:(NSComparator)comparator {
		self = [self initWithComparator:comparator];

		if(self) {
			for(NSUInteger i = 0; i < cnt; ++i) {
				if(objects[i] && keys[i]) {
					[self setObject:objects[i] forKey:keys[i]];
				}
				else {
					[self removeAllObjects];
					@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Non-nil object or key passed to dictionary." userInfo:nil];
				}
			}
		}

		return self;
	}

	-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
		_root = (_root ? [_root insertValue:anObject forKey:aKey withComparator:^NSComparisonResult(id obj1, id obj2) {
			return NSOrderedSame;
		}].root : [[PGBinaryTreeKVNode alloc] initWithValue:anObject forKey:aKey]);
	}

	-(id)objectForKey:(id)aKey {
		return [_root find:aKey withComparator:^NSComparisonResult(id obj1, id obj2) {
			return NSOrderedSame;
		}].value;
	}

	-(void)removeObjectForKey:(id)aKey {
		PGBinaryTreeLeaf *node = [_root find:aKey withComparator:^NSComparisonResult(id obj1, id obj2) {
			return NSOrderedSame;
		}];

		if(node && node.isNode) {
			_root = [node remove];
		}
	}

@end

@implementation PGBinaryTreeEnumerator {
	}

	@synthesize root = _root;
	@synthesize currentNode = _currentNode;

	-(instancetype)initWithRoot:(PGBinaryTreeLeaf *)aRoot {
		self = [super init];

		if(self) {
			self.root = aRoot.root;

			if(self.root.isLeaf) {
				self.root        = nil;
				self.currentNode = nil;
			}
			else {
				self.currentNode = self.root.farLeft;
			}
		}

		return self;
	}

	-(id)nextObject {
		if(self.currentNode && self.currentNode.isNode) {
			PGBinaryTreeLeaf *node = self.currentNode;
			self.currentNode = self.currentNode.nextNode;
			return node.value;
		}
		else {
			return nil;
		}
	}

@end
