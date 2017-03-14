/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGStack.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/4/17 9:44 PM
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

#import "PGStack.h"
#import "PGLinkedListNode.h"

@interface PGStackEnumerator : NSEnumerator

	-(instancetype)initWithStack:(PGStack *)stack;

@end

@interface PGStack()

	-(PGLinkedListNode *)linkedList;

@end

@implementation PGStack {
		PGLinkedListNode *_firstNode;
	}

	@synthesize count = _count;

	-(instancetype)init {
		self = [super init];

		if(self) {
			_count = 0;
		}

		return self;
	}

	-(instancetype)initWithNSArray:(NSArray *)objs {
		self = [self init];

		if(self) {
			[self pushAll:objs];
		}

		return self;
	}

	-(instancetype)initWithObjects:(const id[])objects count:(NSUInteger)cnt {
		self = [self init];

		if(self) {
			if(objects) {
				for(NSUInteger i = 0; i < cnt; ++cnt) {
					[self push:objects[i]];
				}
			}
		}

		return self;
	}

	-(PGLinkedListNode *)linkedList {
		return _firstNode;
	}

	-(void)dealloc {
		[self removeAll];
	}

	-(void)push:(id)obj {
		if(obj) {
			_firstNode = [_firstNode insertBefore:obj];
			_count++;
		}
	}

	-(id)pop {
		id value = nil;

		if(_firstNode) {
			value      = _firstNode.value;
			_firstNode = [_firstNode remove];
			_count--;
		}

		return value;
	}

	-(id)peek {
		return _firstNode.value;
	}

	-(NSArray *)popAll {
		if(self.isEmpty) {
			return [NSArray array];
		}
		else {
			NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
			[array addObject:self.pop];

			while(!self.isEmpty) {
				[array insertObject:self.pop atIndex:0];
			}

			return array;
		}
	}

	-(NSArray *)peekAll {
		if(self.isEmpty) {
			return [NSArray array];
		}
		else {
			NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
			NSEnumerator   *en    = self.objectEnumerator;
			id             o      = en.nextObject;

			while(o) {
				[array addObject:o];
				o = en.nextObject;
			}

			return array;
		}
	}

	-(void)pushAll:(NSArray *)objs {
		for(id o in objs) {
			[self push:o];
		}
	}

	-(BOOL)isEmpty {
		return (_firstNode == nil);
	}

	-(void)removeAll {
		while(self.count) {
			[self pop];
		}
	}

	-(NSEnumerator *)objectEnumerator {
		return [[PGStackEnumerator alloc] initWithStack:self];
	}

	+(instancetype)stack {
		return [[self alloc] init];
	}

	+(instancetype)stackWithArray:(NSArray *)array {
		return [[self alloc] initWithNSArray:array];
	}

	+(instancetype)stackWithObjects:(const id[])objects count:(NSUInteger)cnt {
		return [[self alloc] initWithObjects:objects count:cnt];
	}

@end

@implementation PGStackEnumerator {
		PGStack          *_stack;
		PGLinkedListNode *_curr;
	}

	-(instancetype)initWithStack:(PGStack *)stack {
		self = [super init];

		if(self) {
			_stack = stack;
			_curr  = _stack.linkedList.prevNode;
		}

		return self;
	}

	-(id)nextObject {
		if(_stack) {
			id value = _curr.value;

			if(_curr.isFirst) {
				_curr  = nil;
				_stack = nil;
			}

			return value;
		}
		else {
			return nil;
		}
	}

	-(NSArray *)allObjects {
		NSMutableArray *array = [NSMutableArray array];
		id             value  = self.nextObject;

		while(value) {
			[array addObject:value];
			value = self.nextObject;
		}

		return array;
	}

@end
