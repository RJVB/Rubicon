/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGStack.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/19/17 3:51 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved. *
 * "It can hardly be a coincidence that no language on Earth has ever produced the expression 'As pretty as an airport.' Airports
 * are ugly. Some are very ugly. Some attain a degree of ugliness that can only be the result of special effort."
 * - Douglas Adams from "The Long Dark Tea-Time of the Soul"
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *********************************************************************************************************************************/

#import "PGStack.h"
#import "PGLinkedListNode.h"

@interface PGStack<__covariant T>()

    @property(atomic, readwrite) NSUInteger       count;
    @property(atomic, retain) PGLinkedListNode<T> *stackTop;

    -(T)_pop;

    -(void)_push:(T)item;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@implementation PGStack {
        NSRecursiveLock *_lock;
    }

    @synthesize count = _count;
    @synthesize stackTop = _stackTop;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _lock = [NSRecursiveLock new];
            /*
             * Not needed but I'm OCD.
             */
            self.count    = 0;
            self.stackTop = nil;
        }

        return self;
    }

    -(instancetype)initWithItem:(id)item {
        self = [self init];

        if(self) {
            [self _push:item];
        }

        return self;
    }

    -(instancetype)initWithStack:(PGStack *)stack {
        self = [self init];

        if(self) {
            [self pushAllFromStack:stack];
        }

        return self;
    }

    -(instancetype)initWithNSArray:(NSArray *)array {
        self = [self init];

        if(self) {
            [self pushAllFromNSArray:array];
        }

        return self;
    }

    -(BOOL)isNotEmpty {
        [self lock];
        @try { return (self.stackTop != nil); } @finally { [self unlock]; }
    }

    -(id)peek {
        [self lock];
        @try { return self.stackTop.data; } @finally { [self unlock]; }
    }

    -(id)pop {
        [self lock];
        @try { return [self _pop]; } @finally { [self unlock]; }
    }

    -(id)_pop {
        id item = nil;

        if(self.stackTop) {
            item = self.stackTop.data;
            self.stackTop = [self.stackTop remove];
            self.count    = (self.stackTop ? (self.count - 1) : 0);
        }
        else if(self.count) self.count = 0;

        return item;
    }

    -(void)push:(id)item {
        [self lock];
        @try { [self _push:item]; } @finally { [self unlock]; }
    }

    -(void)_push:(id)item {
        if(item) {
            if(self.stackTop) {
                self.stackTop = [self.stackTop prepend:item];
                self.count    = (self.count + 1);
            }
            else {
                self.stackTop = [[PGLinkedListNode alloc] initWithData:item];
                self.count    = 1;
            }
        }
        else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Item is null." userInfo:nil];
        }
    }

    -(void)pushAllFromNSArray:(NSArray *)array {
        [self lock];
        @try { for(id item in [array reverseObjectEnumerator]) [self _push:item]; } @finally { [self unlock]; }
    }

    -(void)pushAllFromStack:(PGStack *)stack {
        if(stack) {
            [stack lock];

            @try {
                if(stack.stackTop) {
                    [self lock];
                    @try { for(id item in [stack.stackTop.previousNode reverseObjectEnumerator]) [self _push:item]; } @finally { [self unlock]; }
                }
            }
            @finally { [stack unlock]; }
        }
    }

    -(void)clear {
        [self lock];

        @try {
            while(self.stackTop) self.stackTop = [self.stackTop remove];
            self.count = 0;
        }
        @finally { [self unlock]; }
    }

    -(NSArray *)popAll {
        [self lock];

        @try {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
            id             item   = [self _pop];

            while(item) {
                [array addObject:item];
                item = [self _pop];
            }

            return array;
        }
        @finally { [self unlock]; }
    }

    -(NSArray *)peekAll {
        [self lock];

        @try {
            NSMutableArray   *array = [NSMutableArray arrayWithCapacity:self.count];
            PGLinkedListNode *st    = self.stackTop;

            if(st) {
                PGLinkedListNode *nd = st;

                do {
                    [array addObject:nd.data];
                    nd = nd.nextNode;
                } while(nd != st);
            }

            return array;
        }
        @finally { [self unlock]; }
    }

    -(void)lock {
        [_lock lock];
    }

    -(void)unlock {
        [_lock unlock];
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return [(PGStack *)[[self class] allocWithZone:zone] initWithStack:self];
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToStack:other] : [super isEqual:other])));
    }

    -(BOOL)isEqualToStack:(PGStack *)stack {
        if(stack) {
            if(self == stack) return YES;
            [self lock];

            @try {
                if(self.count == stack.count) {
                    PGLinkedListNode *selfNode  = self.stackTop;
                    PGLinkedListNode *stackNode = stack.stackTop;

                    if(selfNode && stackNode) {
                        while(PGCompare(selfNode, stackNode)) {
                            selfNode  = selfNode.nextNode;
                            stackNode = stackNode.nextNode;

                            if(selfNode == self.stackTop) return (stackNode == stack.stackTop);
                            if(stackNode == stack.stackTop) return NO;
                        }
                    }
                    else {
                        return (selfNode == stackNode);
                    }
                }
            }
            @finally { [self unlock]; }
        }

        return NO;
    }

    -(NSUInteger)hash {
        [self lock];

        @try {
            NSUInteger       hash  = (31u + self.count);
            PGLinkedListNode *node = self.stackTop;

            if(node) {
                do {
                    hash = ((hash * 31u) + [node hash]);
                    node = node.nextNode;
                } while(node != self.stackTop);
            }

            return hash;
        }
        @finally { [self unlock]; }
    }

@end

#pragma clang diagnostic pop
