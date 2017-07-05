/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeDictionaryKeyEnumerator.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/3/17 12:37 PM
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

#import "PGBTreeDictionaryKeyEnumerator.h"

@implementation PGBTreeDictionaryKeyEnumerator {
    }

    @synthesize current = _current;
    @synthesize stack = _stack;
    @synthesize dictionary = _dictionary;

    -(instancetype)initWithBTreeDictionary:(PGBTreeDictionary *)dict {
        self = [super init];

        if(self) {
            self.dictionary = dict;
            self.stack      = [[PGStack alloc] init];
            self.current    = [self driveLeft:((PGBTreeDictionary *)self.dictionary).root];
        }

        return self;
    }

    -(instancetype)initWithMutableBTreeDictionary:(PGBTreeMutableDictionary *)dict {
        self = [super init];
        if(self) {
            self.dictionary = dict;
            self.stack      = [[PGStack alloc] init];
            self.current    = [self driveLeft:((PGBTreeMutableDictionary *)self.dictionary).root];
        }
        return self;
    }

    -(PGBTreeNode<PGKeyValueData *> *)driveLeft:(PGBTreeNode<PGKeyValueData *> *)node {
        if(node && node.left) {
            [self.stack push:node];
            return [self driveLeft:node.left];
        }

        return node;
    }

    -(id)nextObject {
        id obj = nil;

        if(self.current) {
            obj = self.current.data.key;
            self.current = (self.current.right ? [self driveLeft:self.current.right] : [self.stack pop]);
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

