/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/18/17 9:19 AM
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

#import "PGBTreeNode.h"

@interface PGBTreeNode<__covariant K, __covariant V>()

    @property(nonatomic, copy) K    nodeKey;
    @property(nonatomic, retain) V  nodeValue;
    @property(nonatomic) BOOL       isRed;
    @property(nonatomic) NSUInteger count;

    @property(nonatomic, retain) PGBTreeNode<K, V> *parentNode;
    @property(nonatomic, retain) PGBTreeNode<K, V> *rightNode;
    @property(nonatomic, retain) PGBTreeNode<K, V> *leftNode;

    -(instancetype)farLeft;

    -(instancetype)farRight;

@end

@implementation PGBTreeNode {
        PGBTreeNode *_leftNode;
        PGBTreeNode *_rightNode;
    }

    @synthesize nodeKey = _nodeKey;
    @synthesize nodeValue = _nodeValue;
    @synthesize parentNode = _parentNode;
    @synthesize isRed = _isRed;
    @synthesize count = _count;

    -(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key isRed:(BOOL)isRed {
        self = [super init];

        if(self) {
            self.isRed     = isRed;
            self.nodeKey   = key;
            self.nodeValue = value;
            self.count     = 1;
        }

        return self;
    }

    -(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key {
        return (self = [self initWithValue:value forKey:key isRed:NO]);
    }

    -(void)recount {
        self.count = (1 + self.leftNode.count + self.rightNode.count);
        [self.parentNode recount];
    }

    -(PGBTreeNode *)leftNode {
        return _leftNode;
    }

    -(PGBTreeNode *)rightNode {
        return _rightNode;
    }

    -(void)setLeftNode:(PGBTreeNode *)node {
        if(_leftNode != node) {
            _leftNode.parentNode = nil;
            _leftNode = nil;
            [node removeParent];
            _leftNode = node;
            node.parentNode = self;
        }
    }

    -(void)setRightNode:(PGBTreeNode *)node {
        if(_rightNode != node) {
            [node removeParent];
            _rightNode.parentNode = nil;
            _rightNode = node;
            _rightNode.parentNode = self;
            [self recount];
        }
    }

    -(PGBTreeNode *)rootNode {
        PGBTreeNode *p = self.parentNode;
        return (p ? p.rootNode : self);
    }

    -(void)deepRemove {
        [self.leftNode deepRemove];
        [self.rightNode deepRemove];
        [self clearFields];
    }

    -(void)clearFields {
        _leftNode   = nil;
        _rightNode  = nil;
        _parentNode = nil;
        _nodeKey    = nil;
        _nodeValue  = nil;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

    -(instancetype)findNodeForKey:(id)key {
        return key ? [self _findNodeForKey:key usingComparator:^NSComparisonResult(id obj1, id obj2) { return PGCompare(obj1, obj2); }] : nil;
    }

    -(instancetype)findNodeForKey:(id)key usingComparator:(NSComparator)comp {
        return (key ? [self _findNodeForKey:key usingComparator:comp] : nil);
    }

    -(instancetype)_findNodeForKey:(id)key usingComparator:(NSComparator)comp {
        switch(comp(key, self.nodeKey)) {
            case NSOrderedAscending:
                return [self.leftNode _findNodeForKey:key usingComparator:comp];
            case NSOrderedDescending:
                return [self.rightNode _findNodeForKey:key usingComparator:comp];
            default:
                return self;
        }
    }

    -(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
        if(key && value) return [self _insertValue:value forKey:key usingComparator:^NSComparisonResult(id obj1, id obj2) { return PGCompare(obj1, obj2); }];
        else @throw [self exceptionForValue:value andKey:key];
    }

    -(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key usingComparator:(NSComparator)comp {
        if(key && value) return [self _insertValue:value forKey:key usingComparator:comp];
        else @throw [self exceptionForValue:value andKey:key];
    }

    -(NSException *)exceptionForValue:(id)value andKey:(id)key {
        return [NSException exceptionWithName:NSInvalidArgumentException reason:(key ? @"Value is null" : (value ? @"Key is null" : @"Key and Value are null")) userInfo:nil];
    }

    -(instancetype)_insertValue:(id)value forKey:(id<NSCopying>)key usingComparator:(NSComparator)comp {
        switch(comp(key, self.nodeKey)) {
            case NSOrderedAscending: {
                return (self.leftNode ?
                        [self.leftNode _insertValue:value forKey:key usingComparator:comp] :
                        [(self.leftNode = [self createNodeWithValue:value forKey:key]) insertRebalance]);
            }
            case NSOrderedDescending: {
                return (self.rightNode ?
                        [self.rightNode _insertValue:value forKey:key usingComparator:comp] :
                        [(self.rightNode = [self createNodeWithValue:value forKey:key]) insertRebalance]);
            }
            default: {
                self.nodeValue = value;
                return self.rootNode;
            }
        }
    }

    -(instancetype)createNodeWithValue:(id)value forKey:(id<NSCopying>)key {
        return [(PGBTreeNode *)[[self class] alloc] initWithValue:value forKey:key isRed:YES];
    }

#pragma clang diagnostic pop

    -(instancetype)remove {
        PGBTreeNode *l = self.leftNode;
        PGBTreeNode *r = self.rightNode;

        if(l && r) {
            r = r.farLeft;
            self.nodeKey   = r.nodeKey;
            self.nodeValue = r.nodeValue;
            return [r remove];
        }
        else {
            PGBTreeNode *p = self.parentNode;
            PGBTreeNode *c = (l ? l : r);

            if(!self.isRed) {
                if(c.isRed) c.isRed = NO; else [self removeRebalance];
            }
            [self replaceMeWith:c];
            [self clearFields];
            return (p ? p.rootNode : c.rootNode);
        }
    }

    -(instancetype)insertRebalance {
        PGBTreeNode *p = self.parentNode;

        if(p) {
            if(p.isRed) {
                PGBTreeNode *g = p.parentNode;
                BOOL        pl = (p == g.leftNode);
                PGBTreeNode *u = (pl ? g.rightNode : g.leftNode);

                if(u.isRed) {
                    g.isRed = YES;
                    u.isRed = NO;
                    p.isRed = NO;
                    return [g insertRebalance];
                }
                else {
                    BOOL sr = (self == p.rightNode);

                    if(sr == pl) {
                        [p rotate:pl];
                        [g rotate:!pl];
                    }
                    else {
                        [g rotate:sr];
                    }
                }
            }
        }
        else {
            self.isRed = NO;
        }

        return self.rootNode;
    }

    -(void)removeRebalance {
        PGBTreeNode *p = self.parentNode;

        if(p) {
            BOOL        il = (self == p.leftNode);
            PGBTreeNode *s = (il ? p.rightNode : p.leftNode);

            if(s.isRed) {
                [p rotate:il];
                s = (il ? p.rightNode : p.leftNode);
            }

            PGBTreeNode *a = (il ? s.leftNode : s.rightNode);
            PGBTreeNode *b = (il ? s.rightNode : s.leftNode);

            if(a.isRed || b.isRed) {
                if(a.isRed && !b.isRed) {
                    b = s;
                    [s rotate:!il];
                }

                b.isRed = NO;
                [p rotate:il];
            }
            else {
                s.isRed = YES;
                if(p.isRed) p.isRed = NO; else [p removeRebalance];
            }
        }
    }

    -(void)rotate:(BOOL)left {
        if(left) [self rotateLeft]; else [self rotateRight];
    }

    -(void)rotateLeft {
        PGBTreeNode *r = self.rightNode;

        if(r) {
            [[self replaceMeWith:r] setRightNode:r.leftNode];
            [r setLeftNode:self];
            [self swapColorWith:r];
        }
    }

    -(void)rotateRight {
        PGBTreeNode *l = self.leftNode;

        if(l) {
            [[self replaceMeWith:l] setLeftNode:l.rightNode];
            [l setRightNode:self];
            [self swapColorWith:l];
        }
    }

    -(void)swapColorWith:(PGBTreeNode *)other {
        if(other) {
            BOOL sr = self.isRed;
            self.isRed  = other.isRed;
            other.isRed = sr;
        }
    }

    -(PGBTreeNode *)removeParent {
        return [self replaceMeWith:nil];
    }

    -(PGBTreeNode *)replaceMeWith:(PGBTreeNode *)node {
        PGBTreeNode *p = self.parentNode;
        if(self == p.leftNode) p.leftNode = node; else if(self == p.rightNode) p.rightNode = node;
        return self;
    }

    -(instancetype)farLeft {
        return (self.leftNode ? self.leftNode.farLeft : self);
    }

    -(instancetype)farRight {
        return (self.rightNode ? self.rightNode.farRight : self);
    }

@end
