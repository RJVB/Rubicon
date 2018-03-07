/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGQueue.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/20/17 11:11 AM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
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
#import "PGQueue.h"
#import "PGLinkedListNode.h"
#import "PGEmptyEnumerator.h"
#import "PGNestedEnumerator.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@interface PGQueue<__covariant T>()

    @property(atomic, readwrite) NSUInteger            count;
    @property(atomic, readwrite) PGLinkedListNode<T>   *queueHead;
    @property(nonatomic, readonly) PGLinkedListNode<T> *queueTail;

    -(void)_queue:(id)item;

    -(id)_dequeue;

@end

@implementation PGQueue {
        NSRecursiveLock *_lock;
        unsigned long   _modifiedCount;
    }

    @synthesize count = _count;
    @synthesize queueHead = _queueHead;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _lock          = [NSRecursiveLock new];
            _modifiedCount = 0;
            self.count     = 0;
            self.queueHead = nil;
        }

        return self;
    }

    -(instancetype)initWithItem:(id)item {
        self = [self init];

        if(self) {
            [self queue:item];
        }

        return self;
    }

    -(instancetype)initWithNSArray:(NSArray *)array {
        self = [self init];

        if(self) {
            [self queueAllFromNSArray:array];
        }

        return self;
    }

    -(instancetype)initWithQueue:(PGQueue *)queue {
        self = [self init];

        if(self) {
            [self queueAllFromQueue:queue];
        }

        return self;
    }

    -(PGLinkedListNode *)queueTail {
        [self lock];
        @try { return self.queueHead.previousNode; } @finally { [self unlock]; }
    }

    -(void)queue:(id)item {
        [self lock];
        @try { [self _queue:item]; } @finally { [self unlock]; }
    }

    -(void)requeue:(id)item {
        [self lock];
        @try {
            if(item) {
                if(self.queueHead) {
                    self.queueHead = [self.queueHead prepend:item];
                    self.count++;
                    _modifiedCount++;
                }
                else {
                    [self _queue:item];
                }
            }
            else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Item is null." userInfo:nil];
            }
        }
        @finally { [self unlock]; }
    }

    -(void)_queue:(id)item {
        if(item) {
            if(self.queueHead) {
                [self.queueTail append:item];
                self.count++;
            }
            else {
                self.queueHead = [[PGLinkedListNode alloc] initWithData:item];
                self.count     = 1;
            }

            _modifiedCount++;
        }
        else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Item is null." userInfo:nil];
        }
    }

    -(id)peekQueue {
        [self lock];
        @try { return self.queueHead.data; } @finally { [self unlock]; }
    }

    -(id)dequeue {
        [self lock];
        @try { return [self _dequeue]; } @finally { [self unlock]; }
    }

    -(id)_dequeue {
        id item = self.queueHead.data;

        if(item) {
            self.queueHead = [self.queueHead remove];
            self.count     = (self.queueHead ? (self.count - 1) : 0);
            _modifiedCount++;
        }
        else self.count = 0;

        return item;
    }

    -(void)queueAllFromEnumerator:(NSEnumerator *)enumerator {
        if(enumerator) {
            [self lock];

            @try {
                id item = enumerator.nextObject;

                while(item) {
                    [self _queue:item];
                    item = enumerator.nextObject;
                }
            }
            @finally { [self unlock]; }
        }
    }

    -(void)queueAllFromNSArray:(NSArray *)array {
        if(array.count) {
            [self lock];
            @try { [self queueAllFromEnumerator:array.objectEnumerator]; } @finally { [self unlock]; }
        }
    }

    -(void)queueAllFromQueue:(PGQueue *)queue {
        if(queue) {
            [queue lock];
            @try { [self queueAllFromEnumerator:queue.objectEnumerator]; } @finally { [queue unlock]; }
        }
    }

    -(NSArray *)dequeueAll {
        [self lock];

        @try {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
            id             item   = [self _dequeue];

            while(item) {
                [array addObject:item];
                item = [self _dequeue];
            }

            return array;
        }
        @finally { [self unlock]; }
    }

    -(NSArray *)peekQueueAll {
        [self lock];

        @try {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];

            for(id item in self) [array addObject:item];
            return array;
        }
        @finally { [self unlock]; }
    }

    -(NSEnumerator *)objectEnumerator {
        [self lock];
        @try { return (self.queueHead ? [PGNestedEnumerator enumeratorWithOwner:self andEnumerator:self.queueHead.objectEnumerator] : [PGEmptyEnumerator emptyEnumerator]); }
        @finally { [self unlock]; }
    }

    -(NSEnumerator *)reverseObjectEnumerator {
        [self lock];
        @try {
            return (self.queueHead ?
                    [PGNestedEnumerator enumeratorWithOwner:self andEnumerator:self.queueHead.previousNode.reverseObjectEnumerator] :
                    [PGEmptyEnumerator emptyEnumerator]);
        }
        @finally { [self unlock]; }
    }

    -(void)clear {
        [self lock];

        @try {
            NSUInteger cc = self.count;
            while(self.queueHead) self.queueHead = [self.queueHead remove];
            self.count = 0;
            _modifiedCount += (unsigned long)cc;
        }
        @finally { [self unlock]; }
    }

    -(void)lock {
        [self lock];
    }

    -(void)unlock {
        [self unlock];
    }

    -(void)dealloc {
        [self clear];
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return [(PGQueue *)[[self class] allocWithZone:zone] initWithQueue:self];
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToQueue:other] : [super isEqual:other])));
    }

    -(BOOL)isEqualToQueue:(PGQueue *)queue {
        if(queue) {
            if(self == queue) return YES;
            [queue lock];
            [self lock];

            @try {
                if(self.count == queue.count) {
                    NSEnumerator *e1 = self.objectEnumerator;
                    NSEnumerator *e2 = queue.objectEnumerator;
                    id           i1  = e1.nextObject;
                    id           i2  = e2.nextObject;

                    while(i1 && i2 && PGObjectsEqual(i1, i2)) {
                        i1 = e1.nextObject;
                        i2 = e2.nextObject;
                    }

                    return ((i1 == nil) && (i2 == nil));
                }
            }
            @finally {
                [self unlock];
                [queue unlock];
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

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {
        NSUInteger count = 0;
        [self lock];

        @try {
            PGLinkedListNode *__unsafe_unretained nextNode = nil;

            switch(state->state) {
                case 0:
                    state->state        = 1;
                    state->mutationsPtr = &_modifiedCount;
                    state->extra[0] = ((unsigned long)(__bridge void *)self.queueHead);
                    // Fall through to case 1...
                case 1:
                    nextNode = (__bridge PGLinkedListNode *)(void *)state->extra[0];

                    while((state->state == 1) && (count < len)) {
                        buffer[count++] = nextNode.data;
                        nextNode = nextNode.nextNode;
                        if(nextNode == self.queueHead) state->state = 2;
                    }

                    // Probably don't have to do this but OCD.
                    state->extra[0] = ((state->state == 1) ? ((unsigned long)(__bridge void *)nextNode) : 0);
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
