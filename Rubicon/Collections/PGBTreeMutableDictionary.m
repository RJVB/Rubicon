/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeMutableDictionary.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/23/17 9:10 PM
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@implementation PGBTreeMutableDictionary {
        NSRecursiveLock *_lock;
    }

    @synthesize rootNode = _rootNode;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _lock = [NSRecursiveLock new];
            self.rootNode = nil;
        }

        return self;
    }

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
        self = [super init];

        if(self) {
            _lock = [NSRecursiveLock new];
            self.rootNode = nil;
        }

        return self;
    }

    -(void)removeObjectForKey:(id)aKey {
        [self lock];

        @try {
            PGBTreeNode *node = [self.rootNode findNodeForKey:aKey];
            if(node) self.rootNode = [node remove];
        }
        @finally { [self unlock]; }
    }

    -(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
        [self lock];
        @try { self.rootNode = (self.rootNode ? [self.rootNode insertValue:anObject forKey:aKey] : [[PGBTreeNode alloc] initWithValue:anObject forKey:aKey]); }
        @finally { [self unlock]; }
    }

    -(NSUInteger)count {
        [self lock];
        @try { return self.rootNode.count; } @finally { [self unlock]; }
    }

    -(id)objectForKey:(id)aKey {
        [self lock];
        @try { return [self.rootNode findNodeForKey:aKey].nodeValue; } @finally { [self unlock]; }
    }

    -(NSEnumerator<id> *)keyEnumerator {
        [self lock];
        @try { return [PGBTreeNodeKeyEnumerator enumeratorWithDictionary:self]; } @finally { [self unlock]; }
    }

    -(NSEnumerator<id> *)objectEnumerator {
        [self lock];
        @try { return [PGBTreeNodeValueEnumerator enumeratorWithDictionary:self]; } @finally { [self unlock]; }
    }

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {
        NSUInteger count = 0;

        return count;
    }

    -(void)lock {
        [self lock];
    }

    -(void)unlock {
        [self unlock];
    }

@end

#pragma clang diagnostic pop
