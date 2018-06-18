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
 */

#import "PGInternal.h"

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
        unsigned long   _modifiedCount;
    }

    @synthesize count = _count;
    @synthesize stackTop = _stackTop;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _lock          = [NSRecursiveLock new];
            _modifiedCount = 0;
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
            _modifiedCount++;
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

            _modifiedCount++;
        }
        else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Item is null." userInfo:nil];
        }
    }

    -(void)pushAllFromNSEnumerator:(NSEnumerator *)enumerator {
        if(enumerator) {
            [self lock];

            @try {
                id item = enumerator.nextObject;

                while(item) {
                    [self _push:item];
                    item = enumerator.nextObject;
                }
            }
            @finally { [self unlock]; }
        }
    }

    -(void)pushAllFromNSArray:(NSArray *)array {
        [self pushAllFromNSEnumerator:[array reverseObjectEnumerator]];
    }

    -(void)pushAllFromStack:(PGStack *)stack {
        if(stack) {
            [stack lock];
            @try { [self pushAllFromNSEnumerator:[stack reverseObjectEnumerator]]; } @finally { [stack unlock]; }
        }
    }

    -(void)clear {
        [self lock];

        @try {
            NSUInteger cc = self.count;
            while(self.stackTop) self.stackTop = [self.stackTop remove];
            self.count = 0;
            _modifiedCount += (unsigned long)cc;
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
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];

            for(id item in self) [array addObject:item];
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
            [stack lock];

            @try {
                if(self.count == stack.count) {
                    NSEnumerator *enum1 = self.objectEnumerator;
                    NSEnumerator *enum2 = stack.objectEnumerator;
                    id           i1     = enum1.nextObject;
                    id           i2     = enum2.nextObject;

                    while(i1 && i2 && PGObjectsEqual(i1, i2)) {
                        i1 = enum1.nextObject;
                        i2 = enum2.nextObject;
                    }

                    return ((i1 == nil) && (i2 == nil));
                }
            }
            @finally {
                [stack unlock];
                [self unlock];
            }
        }

        return NO;
    }

    -(NSUInteger)hash {
        NSUInteger hash = 1;
        [self lock];

        @try {
            hash = ((hash * 31u) + self.count);
            for(id item in self) hash = ((hash * 31u) + [item hash]);
        }
        @finally { [self unlock]; }

        return hash;
    }

    -(NSEnumerator *)objectEnumerator {
        [self lock];
        @try {
            return (self.stackTop ?
                    (NSEnumerator *)[PGNestedEnumerator enumeratorWithOwner:self andEnumerator:self.stackTop.objectEnumerator] :
                    (NSEnumerator *)[PGEmptyEnumerator emptyEnumerator]);
        }
        @finally { [self unlock]; }
    }

    -(NSEnumerator *)reverseObjectEnumerator {
        [self lock];
        @try {
            return (self.stackTop ?
                    (NSEnumerator *)[PGNestedEnumerator enumeratorWithOwner:self andEnumerator:self.stackTop.previousNode.reverseObjectEnumerator] :
                    (NSEnumerator *)[PGEmptyEnumerator emptyEnumerator]);
        }
        @finally { [self unlock]; }
    }

    -(void)dealloc {
        [self clear];
    }

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {
        NSUInteger count = 0;
        [self lock];

        @try {
            PGLinkedListNode *__unsafe_unretained nextNode = nil;

            switch(state->state) {
                case 0:
                    state->state        = 1;
                    state->mutationsPtr = &_modifiedCount;
                    state->extra[0] = ((unsigned long)(__bridge voidp)self.stackTop);
                    // Fall through to the case 1....
                case 1:
                    nextNode = (__bridge PGLinkedListNode *)(voidp)state->extra[0];

                    while((state->state == 1) && (count < len)) {
                        buffer[count++] = nextNode.data;
                        nextNode = nextNode.nextNode;
                        if(nextNode == self.stackTop) state->state = 2;
                    }

                    // Probably don't have to do this but OCD.
                    state->extra[0] = ((state->state == 1) ? ((unsigned long)(__bridge voidp)nextNode) : 0);
                    break;
                default:
                    break;
            }
        }
        @finally { [self unlock]; }

        return count;
    }

@end

#pragma clang diagnostic pop
