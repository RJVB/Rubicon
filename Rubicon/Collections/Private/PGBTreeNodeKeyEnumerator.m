/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeNodeEnumerator.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/23/17 9:31 PM
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

#import "PGBTreeNodeKeyEnumerator.h"
#import "PGStack.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@interface PGBTreeNodeKeyEnumerator<T>()

    @property(atomic, retain) PGBTreeMutableDictionary<T, id> *dictionary;
    @property(atomic, retain) PGStack<PGBTreeNode<T, id> *>   *stack;

    -(void)digDown:(PGBTreeNode<T, id> *)node;

@end

@interface PGBTreeNodeValueEnumerator<T>()

    @property(atomic, retain) PGBTreeMutableDictionary<id, T> *dictionary;
    @property(atomic, retain) PGStack<PGBTreeNode<id, T> *>   *stack;

    -(void)digDown:(PGBTreeNode<id, T> *)node;

@end

@implementation PGBTreeNodeKeyEnumerator {
    }

    @synthesize dictionary = _dictionary;
    @synthesize stack = _stack;

    -(instancetype)initWithDictionary:(PGBTreeMutableDictionary *)dictionary {
        self = [super init];

        if(self) {
            self.dictionary = dictionary;
        }

        return self;
    }

    +(instancetype)enumeratorWithDictionary:(PGBTreeMutableDictionary *)dictionary {
        return [[self alloc] initWithDictionary:dictionary];
    }

    -(id)nextObject {
        id obj = nil;

        if(self.dictionary) {
            if(!self.stack) {
                self.stack = [[PGStack alloc] init];
                [self digDown:self.dictionary.rootNode];
            }

            PGBTreeNode *node = [self.stack pop];

            if(node) {
                obj = node.nodeKey;
                [self digDown:node.rightNode];
            }
            else {
                self.dictionary = nil;
                self.stack      = nil;
            }
        }

        return obj;
    }

    -(void)digDown:(PGBTreeNode *)node {
        while(node) {
            [self.stack push:node];
            node = node.leftNode;
        }
    }

@end

@implementation PGBTreeNodeReverseKeyEnumerator {
    }

    -(id)nextObject {
        id obj = nil;

        if(self.dictionary) {
            if(!self.stack) {
                self.stack = [[PGStack alloc] init];
                [self digDown:self.dictionary.rootNode];
            }

            PGBTreeNode *node = [self.stack pop];

            if(node) {
                obj = node.nodeKey;
                [self digDown:node.leftNode];
            }
            else {
                self.dictionary = nil;
                self.stack      = nil;
            }
        }

        return obj;
    }

    -(void)digDown:(PGBTreeNode *)node {
        while(node) {
            [self.stack push:node];
            node = node.rightNode;
        }
    }

@end

@implementation PGBTreeNodeValueEnumerator {
    }

    @synthesize dictionary = _dictionary;
    @synthesize stack = _stack;

    -(instancetype)initWithDictionary:(PGBTreeMutableDictionary *)dictionary {
        self = [super init];

        if(self) {
            self.dictionary = dictionary;
        }

        return self;
    }

    +(instancetype)enumeratorWithDictionary:(PGBTreeMutableDictionary *)dictionary {
        return [[self alloc] initWithDictionary:dictionary];
    }

    -(id)nextObject {
        id obj = nil;

        if(self.dictionary) {
            if(!self.stack) {
                self.stack = [[PGStack alloc] init];
                [self digDown:self.dictionary.rootNode];
            }

            PGBTreeNode *node = [self.stack pop];

            if(node) {
                obj = node.nodeValue;
                [self digDown:node.rightNode];
            }
            else {
                self.dictionary = nil;
                self.stack      = nil;
            }
        }

        return obj;
    }

    -(void)digDown:(PGBTreeNode *)node {
        while(node) {
            [self.stack push:node];
            node = node.leftNode;
        }
    }

@end

@implementation PGBTreeNodeReverseValueEnumerator {
    }

    -(id)nextObject {
        id obj = nil;

        if(self.dictionary) {
            if(!self.stack) {
                self.stack = [[PGStack alloc] init];
                [self digDown:self.dictionary.rootNode];
            }

            PGBTreeNode *node = [self.stack pop];

            if(node) {
                obj = node.nodeValue;
                [self digDown:node.leftNode];
            }
            else {
                self.dictionary = nil;
                self.stack      = nil;
            }
        }

        return obj;
    }

    -(void)digDown:(PGBTreeNode *)node {
        while(node) {
            [self.stack push:node];
            node = node.rightNode;
        }
    }

@end

#pragma clang diagnostic pop
