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
#import "PGBinaryTreeNodePrivate.h"
#import "PGStack.h"
#import "PGEmptyEnumerator.h"

@interface PGBinaryTreeDictionary()

#if NS_BLOCKS_AVAILABLE
	@property(copy) NSComparator comparator;
#endif
	@property(retain) PGBinaryTreeNode *rootNode;

	-(void)loadWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt;

@end

@interface PGBinaryTreeKeyEnumerator : NSEnumerator

	@property(retain) PGBinaryTreeDictionary *dict;
	@property(retain) PGStack                *stack;

	-(instancetype)initWithTreeDictionary:(PGBinaryTreeDictionary *)dict;

	+(instancetype)enumWithTreeDictionary:(PGBinaryTreeDictionary *)dict;

	-(void)descendLeft:(PGBinaryTreeNode *)node;

	-(id)nextObject;

	-(NSArray *)allObjects;

@end

@implementation PGBinaryTreeDictionary {
	}

	@synthesize rootNode = _rootNode;

	-(instancetype)init {
		return (self = [super init]);
	}

	-(void)loadWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
		if(cnt) {
			if(objects) {
				if(keys) {
					for(NSUInteger i = 0; i < cnt; i++) {
						[self setObject:objects[i] forKey:keys[i]];
					}
				}
				else {
					@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Keys array cannot be nil." userInfo:nil];
				}
			}
			else {
				@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Values array cannot be nil." userInfo:nil];
			}
		}
	}

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
		self = [self init];

		if(self) {
			[self loadWithObjects:objects forKeys:keys count:cnt];
		}

		return self;
	}

	-(NSUInteger)count {
		return self.rootNode.count;
	}

#if NS_BLOCKS_AVAILABLE

	@synthesize comparator = _comparator;

	-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
		if(aKey && anObject) {
			if(self.rootNode) {
				self.rootNode = (self.comparator ?
								 [self.rootNode insertValue:anObject forKey:aKey comparator:self.comparator] :
								 [self.rootNode insertValue:anObject forKey:aKey]).rootNode;
			}
			else {
				self.rootNode       = [PGBinaryTreeNode nodeWithKey:aKey value:anObject];
				self.rootNode.isRed = NO;
			}
		}
		else {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Neither Key nor Value can be nil." userInfo:nil];
		}
	}

	-(id)objectForKey:(id)aKey {
		return (aKey ? (self.comparator ? [self.rootNode findNodeForKey:aKey comparator:self.comparator] : [self.rootNode findNodeForKey:aKey]).value : nil);
	}

	-(void)removeObjectForKey:(id)aKey {
		if(aKey) {
			self.rootNode = [(self.comparator ? [self.rootNode findNodeForKey:aKey comparator:self.comparator] : [self.rootNode findNodeForKey:aKey]) remove];
		}
	}

#else
/*@f:0*/
	 -(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
		 if(aKey && anObject) {
			 if(self.rootNode) {
				 self.rootNode = [self.rootNode insertValue:anObject forKey:aKey].rootNode;
			 }
			 else {
				 self.rootNode       = [PGBinaryTreeNode nodeWithKey:aKey value:anObject];
				 self.rootNode.isRed = NO;
			 }
		 }
		 else {
			 @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Neither Key nor Value can be nil." userInfo:nil];
		 }
	 }

	 -(id)objectForKey:(id)aKey {
		 return (aKey ? [self.rootNode findNodeForKey:aKey].value : nil);
	 }

	 -(void)removeObjectForKey:(id)aKey {
		 if(aKey) {
			 self.rootNode = [[self.rootNode findNodeForKey:aKey] remove];
		 }
	 }
 /*@f:1*/
#endif

	-(NSEnumerator *)keyEnumerator {
		return (self.rootNode ? [PGBinaryTreeKeyEnumerator enumWithTreeDictionary:self] : [PGEmptyEnumerator emptyEnumerator]);
	}

@end

@implementation PGBinaryTreeKeyEnumerator {
	}

	@synthesize dict = _dict;
	@synthesize stack = _stack;

	-(instancetype)initWithTreeDictionary:(PGBinaryTreeDictionary *)dict {
		self = [super init];

		if(self) {
			PGBinaryTreeNode *node = dict.rootNode;

			if(node) {
				self.dict  = dict;
				self.stack = [PGStack stack];
				[self descendLeft:node];
			}
		}

		return self;
	}

	+(instancetype)enumWithTreeDictionary:(PGBinaryTreeDictionary *)dict {
		return [[self alloc] initWithTreeDictionary:dict];
	}

	-(void)descendLeft:(PGBinaryTreeNode *)node {
		while(node) {
			[self.stack push:node];
			node = node.leftChild;
		}
	}

	-(id)nextObject {
		id obj = nil;

		if(self.stack) {
			PGBinaryTreeNode *node = self.stack.pop;
			[self descendLeft:node.rightChild];

			if(self.stack.isEmpty) {
				self.dict  = nil;
				self.stack = nil;
			}

			obj = node.value;
		}

		return obj;
	}

	-(NSArray *)allObjects {
		NSMutableArray *array = [NSMutableArray array];
		id             obj    = self.nextObject;

		while(obj) {
			[array addObject:obj];
			obj = self.nextObject;
		}

		return array;
	}

@end

#if NS_BLOCKS_AVAILABLE

@implementation PGBinaryTreeDictionary(NSComparator)

	-(instancetype)initWithComparator:(NSComparator)comparator {
		self = [self init];

		if(self) {
			self.comparator = comparator;
		}

		return self;
	}

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt comparator:(NSComparator)comparator {
		self = [self initWithComparator:comparator];

		if(self) {
			[self loadWithObjects:objects forKeys:keys count:cnt];
		}

		return self;
	}

@end

#endif
