/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGLinkedListNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/3/17 10:33 AM
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

#import "PGLinkedListNode.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@interface PGLinkedListNode()

    -(instancetype)initWithValue:(id)value isFirst:(BOOL)isFirst;

@end

@implementation PGLinkedListNode {
    }

    @synthesize nextNode = _nextNode;
    @synthesize prevNode = _prevNode;
    @synthesize value = _value;
    @synthesize isFirst = _isFirst;

    -(instancetype)initWithValue:(id)value {
        return (self = [self initWithValue:value isFirst:YES]);
    }

    -(instancetype)initWithValue:(id)value isFirst:(BOOL)isFirst {
        self = [super init];

        if(self) {
            self.value    = value;
            self.isFirst  = isFirst;
            self.nextNode = self;
            self.prevNode = self;
        }

        return self;
    }

    +(instancetype)nodeWithValue:(id)value {
        return [[self alloc] initWithValue:value];
    }

    -(instancetype)firstNode {
        PGLinkedListNode *node = self;

        while(!node.isFirst) {
            node = node.nextNode;

            if(self == node) {
                /*
                 * We went around the world and didn't find the first node so let's make ourselves the first node just so we have
                 * some consistency.
                 */
                node.isFirst = YES;
                break;
            }
        }

        return node;
    }

    -(instancetype)lastNode {
        return self.firstNode.prevNode;
    }

    -(instancetype)insertAfter:(id)value {
        PGLinkedListNode *newNode = [(id)[[self class] alloc] initWithValue:value isFirst:NO];

        newNode.nextNode          = self.nextNode;
        self.nextNode             = newNode;
        newNode.prevNode          = newNode.nextNode.prevNode;
        newNode.nextNode.prevNode = newNode;

        return newNode;
    }

    -(instancetype)insertBefore:(id)value {
        PGLinkedListNode *newNode = [self.prevNode insertAfter:value];

        /*
         * Inserting before the first node causes the new node to be the new first node.  This models the behaviour of an array.
         */
        if(self.isFirst) {
            self.isFirst    = NO;
            newNode.isFirst = YES;
        }

        return newNode;
    }

    -(instancetype)remove {
        PGLinkedListNode *next = self.nextNode;
        id               v     = self.value;

        if(next != self) {
            PGLinkedListNode *prev = self.prevNode;

            prev.nextNode = next;
            next.prevNode = prev;

            if(self.isFirst) {
                next.isFirst = YES;
            }
        }

        self.isFirst  = NO;
        self.value    = nil;
        self.nextNode = nil;
        self.prevNode = nil;

        return v;
    }

@end

#pragma clang diagnostic pop
