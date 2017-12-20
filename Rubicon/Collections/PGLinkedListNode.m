/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGLinkedListNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/19/17 2:20 PM
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
 *********************************************************************************************************************************/

#import "PGLinkedListNode.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@interface PGLinkedListNode<__covariant T>()

    @property(atomic, readwrite) BOOL                        isFirstNode;
    @property(atomic, readwrite, strong) T                   data;
    @property(atomic, readwrite, strong) PGLinkedListNode<T> *previousNode;
    @property(atomic, readwrite, strong) PGLinkedListNode<T> *nextNode;

    -(instancetype)initWithData:(T)data previousNode:(PGLinkedListNode<T> *)prev nextNode:(PGLinkedListNode<T> *)next;

@end

@implementation PGLinkedListNode {
    }

    @synthesize isFirstNode = _isFirstNode;
    @synthesize data = _data;
    @synthesize previousNode = _previousNode;
    @synthesize nextNode = _nextNode;

    -(instancetype)initWithData:(id)data previousNode:(PGLinkedListNode *)prev nextNode:(PGLinkedListNode *)next {
        self = [super init];

        if(self) {
            if(data) {
                if(prev && next) {
                    self.data         = data;
                    self.previousNode = prev;
                    self.nextNode     = next;
                    self.isFirstNode  = NO;

                    next.previousNode = self;
                    prev.nextNode     = self;
                }
                else {
                    NSString *reason = (prev ? @"Next node is null." : (next ? @"Previous node is null." : @"Previous and next nodes are null."));
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                }
            }
            else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Data is null." userInfo:nil];
            }
        }

        return self;
    }

    -(instancetype)initWithData:(id)data {
        self = [super init];

        if(self) {
            if(data) {
                self.data         = data;
                self.previousNode = self;
                self.nextNode     = self;
                self.isFirstNode  = YES;
            }
            else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Data is null." userInfo:nil];
            }
        }

        return self;
    }

    -(BOOL)isLastNode {
        /*
         * This works for a single node because when there is only one node it is both the first and last node.
         */
        return self.nextNode.isFirstNode;
    }

    -(PGLinkedListNode *)firstNode {
        if(!self.isFirstNode) {
            PGLinkedListNode *node = self.nextNode;

            while(node != self) {
                if(node.isFirstNode) return node;
                else node = node.nextNode;
            }

            // Obviously we don't have a first node so make this one the first node by default.
            self.isFirstNode = YES;
        }

        return self;
    }

    -(PGLinkedListNode *)lastNode {
        return self.firstNode.previousNode;
    }

    -(instancetype)append:(id)data {
        return [(PGLinkedListNode *)[[self class] alloc] initWithData:data previousNode:self nextNode:self.nextNode];
    }

    -(instancetype)prepend:(id)data {
        PGLinkedListNode *node = [(PGLinkedListNode *)[[self class] alloc] initWithData:data previousNode:self.previousNode nextNode:self];

        if(self.isFirstNode) {
            node.isFirstNode = YES;
            self.isFirstNode = NO;
        }

        return node;
    }

    -(instancetype)remove {
        PGLinkedListNode *next = self.nextNode;

        if(self == next) {
            next = nil;
        }
        else {
            PGLinkedListNode *prev = self.previousNode;

            next.previousNode = prev;
            prev.nextNode     = next;

            if(self.isFirstNode) next.isFirstNode = YES;
        }

        self.nextNode     = nil;
        self.previousNode = nil;
        self.data         = nil;
        self.isFirstNode  = NO;

        return next;
    }

    -(id)replace:(id)data {
        id org = self.data;
        self.data = data;
        return org;
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((self == other) || ([other isMemberOfClass:[self class]] ? [self isEqualToNode:other] : [super isEqual:other])));
    }

    -(BOOL)isEqualToNode:(PGLinkedListNode *)node {
        return (node && ((self == node) || ((self.isFirstNode == node.isFirstNode) && PGObjectsEqual(self.data, node.data))));
    }

    -(NSUInteger)hash {
        return ((((NSUInteger)self.isFirstNode) * 31u) + [self.data hash]);
    }

@end

#pragma clang diagnostic pop
