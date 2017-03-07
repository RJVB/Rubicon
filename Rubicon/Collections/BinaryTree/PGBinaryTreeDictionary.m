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

@interface PGBinaryTreeKeyEnumerator : NSEnumerator

	@property(retain) PGBinaryTreeNode       *current;
	@property(retain) PGBinaryTreeDictionary *dict;
	@property(retain) NSMutableArray         *stack;

	-(instancetype)initWithDictionary:(PGBinaryTreeDictionary *)dict;

	-(PGBinaryTreeNode *)pushStack:(PGBinaryTreeNode *)node;

	-(PGBinaryTreeNode *)popStack;

	-(id)nextObject;

	-(NSArray *)allObjects;

@end

@interface PGBinaryTreeValueEnumerator : NSEnumerator

	@property(retain) PGBinaryTreeDictionary    *dict;
	@property(retain) PGBinaryTreeKeyEnumerator *keyEnum;

	-(instancetype)initWithDictionary:(PGBinaryTreeDictionary *)dict;

	-(id)nextObject;

	-(NSArray *)allObjects;

@end

@interface PGBinaryTreeDictionary()

	-(PGBinaryTreeNode *)rootNode;

	-(PGBinaryTreeNode *)nodeForKey:(id)aKey;

@end

@implementation PGBinaryTreeDictionary {
		PGBinaryTreeNode *_rootNode;
	}

	@synthesize comparator = _comparator;

	-(instancetype)init {
		return (self = [self initWithComparator:nil]);
	}

	-(instancetype)initWithComparator:(NSComparator)comparator {
		self = [super init];

		if(self) {
			_comparator = [comparator copy];
		}

		return self;
	}

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
		return (self = [self initWithObjects:objects forKeys:keys count:cnt comparator:nil]);
	}

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt comparator:(NSComparator)comparator {
		self = [self initWithComparator:comparator];

		if(self) {
			if(objects && keys) {
				for(NSUInteger i = 0; i < cnt; i++) {
					[self setObject:objects[i] forKey:keys[i]];
				}
			}
		}

		return self;
	}

	-(PGBinaryTreeNode *)rootNode {
		return _rootNode;
	}

	-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
		if(anObject && aKey) {
			if(self.comparator) {
				_rootNode = [_rootNode insertValue:anObject forKey:aKey comparator:self.comparator].rootNode;
			}
			else {
				_rootNode = [_rootNode insertValue:anObject forKey:aKey].rootNode;
			}
		}
	}

	-(PGBinaryTreeNode *)nodeForKey:(id)aKey {
		if(aKey) {
			if(self.comparator) {
				return [_rootNode findNodeForKey:aKey comparator:self.comparator];
			}
			else {
				return [_rootNode findNodeForKey:aKey];
			}
		}

		return nil;
	}

	-(id)objectForKey:(id)aKey {
		return [self nodeForKey:aKey].value;
	}

	-(void)removeObjectForKey:(id)aKey {
		PGBinaryTreeNode *node = [self nodeForKey:aKey];
		if(node) _rootNode = [node remove];
	}

	-(NSUInteger)count {
		return _rootNode.count;
	}

	-(NSEnumerator *)keyEnumerator {
		return [[PGBinaryTreeKeyEnumerator alloc] initWithDictionary:self];
	}

	-(NSEnumerator *)objectEnumerator {
		return [[PGBinaryTreeValueEnumerator alloc] initWithDictionary:self];
	}

@end

@implementation PGBinaryTreeKeyEnumerator {
	}

	@synthesize current = _current;
	@synthesize dict = _dict;
	@synthesize stack = _stack;

	-(instancetype)initWithDictionary:(PGBinaryTreeDictionary *)dict {
		self = [super init];

		if(self) {
			if(dict.rootNode) {
				self.dict  = dict;
				self.stack = [NSMutableArray array];
				[self pushStack:self.dict.rootNode];
			}
		}

		return self;
	}

	-(PGBinaryTreeNode *)pushStack:(PGBinaryTreeNode *)node {
		if(node.leftNode) {
			[self.stack addObject:node];
			return [self pushStack:node.leftNode];
		}
		else {
			return node;
		}
	}

	-(PGBinaryTreeNode *)popStack {
		PGBinaryTreeNode *node = nil;

		if(self.stack.count) {
			node = [self.stack lastObject];
			[self.stack removeLastObject];
		}

		return node;
	}

	-(id)nextObject {
		id o = nil;

		if(self.current) {
			o = self.current.key;
			self.current = (self.current.rightNode ? [self pushStack:self.current.rightNode] : [self popStack]);
		}
		else {
			self.dict  = nil;
			self.stack = nil;
		}

		return o;
	}

	-(NSArray *)allObjects {
		NSMutableArray *array = [NSMutableArray array];
		id             o      = self.nextObject;

		while(o) {
			[array addObject:o];
			o = self.nextObject;
		}

		return array;
	}

@end

@implementation PGBinaryTreeValueEnumerator {
	}

	@synthesize dict = _dict;
	@synthesize keyEnum = _keyEnum;

	-(instancetype)initWithDictionary:(PGBinaryTreeDictionary *)dict {
		self = [super init];

		if(self) {
			self.dict    = dict;
			self.keyEnum = [[PGBinaryTreeKeyEnumerator alloc] initWithDictionary:dict];
		}

		return self;
	}

	-(id)nextObject {
		id aKey = self.keyEnum.nextObject;
		return (aKey ? [self.dict objectForKey:aKey] : nil);
	}

	-(NSArray *)allObjects {
		NSMutableArray *array = [NSMutableArray array];
		id             o      = self.nextObject;

		while(o) {
			[array addObject:o];
			o = self.nextObject;
		}

		return array;
	}

@end
