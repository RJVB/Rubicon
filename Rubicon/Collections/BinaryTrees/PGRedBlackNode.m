/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGRedBlackNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/13/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 **********************************************************************************************************************************************************************************/

#import "PGRedBlackNodePrivate.h"

typedef PGRedBlackNode *RBNp;

RBNp rotate(RBNp n, BOOL l);

// @f:0
NS_INLINE void SC(RBNp a, RBNp b)                 { BOOL c = a.isRed; a.isRed = b.isRed; b.isRed = c; }
NS_INLINE void SWP(RBNp a, RBNp b)                { RBNp p = a.parentNode; if(p) { if(a == p.leftChildNode) p.leftChildNode = b; else p.rightChildNode = b; }}
NS_INLINE RBNp setchldfld(RBNp s, RBNp f, RBNp n) { if(f == n) return f; SWP(n, nil); f.parentNode = nil; n.parentNode = s; return n; }
// @f:1

@implementation PGRedBlackNode {
    }

    @synthesize key = _key;
    @synthesize value = _value;
    @synthesize isRed = _isRed;
    @synthesize parentNode = _parentNode;
    @synthesize rightChildNode = _rightChildNode;
    @synthesize leftChildNode = _leftChildNode;
    @synthesize count = _count;

    -(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key isRed:(BOOL)isRed {
        self = [super init];

        if(self) {
            self.key   = key;
            self.value = value;
            self.isRed = isRed;
            _count = 1;
        }

        return self;
    }

    -(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key {
        return (self = [self initWithValue:value forKey:key isRed:NO]);
    }

    -(RBNp)grandParentNode {
        return self.parentNode.parentNode;
    }

    -(RBNp)siblingNode {
        RBNp p = self.parentNode;
        return (p ? ((self == p.leftChildNode) ? p.rightChildNode : p.leftChildNode) : nil);
    }

    -(RBNp)uncleNode {
        return self.parentNode.siblingNode;
    }

    -(RBNp)rootNode {
        RBNp p = self.parentNode;
        return (p ? p.rootNode : self);
    }

    -(void)setRightChildNode:(RBNp)node {
        _rightChildNode = setchldfld(self, self.rightChildNode, node);
        [self recount];
    }

    -(void)setLeftChildNode:(RBNp)node {
        _leftChildNode = setchldfld(self, self.leftChildNode, node);
        [self recount];
    }

    -(instancetype)findNodeWithKey:(id)key {
        if(key) {
            if([self.key isEqual:key]) {
                switch(PGCompare(self.key, key)) {
                    case NSOrderedAscending:
                        return [self.rightChildNode findNodeWithKey:key];
                    case NSOrderedDescending:
                        return [self.leftChildNode findNodeWithKey:key];
                    default:
                        break;
                }
            }
            return self;
        }
        return nil;
    }

    -(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
        if(key && value) {
            if(![self.key isEqual:key]) {
                switch(PGCompare(self.key, key)) {
                    case NSOrderedAscending:
                        if(self.rightChildNode) return [self.rightChildNode insertValue:value forKey:key];
                        else {
                            RBNp node = self.rightChildNode = [PGRedBlackNode nodeWithValue:value forKey:key isRed:YES];
                            [node insertRebalance];
                            return node;
                        }
                    case NSOrderedDescending:
                        if(self.leftChildNode) return [self.leftChildNode insertValue:value forKey:key];
                        else {
                            RBNp node = self.leftChildNode = [PGRedBlackNode nodeWithValue:value forKey:key isRed:YES];
                            [node insertRebalance];
                            return node;
                        }
                    default:
                        break;
                }
            }
            self.value = value;
            return self;
        }
        if(key) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Value is NULL."];
        if(value) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key is NULL."];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key and Value are NULL."];
    }

    -(instancetype)delete {
        RBNp lc = self.leftChildNode;
        RBNp rc = self.rightChildNode;

        if(lc && rc) {
            while(rc.leftChildNode) rc = rc.leftChildNode;
            self.key   = rc.key;
            self.value = rc.value;
            return [rc delete];
        }
        else {
            RBNp c = (lc ?: rc);
            RBNp p = self.parentNode;

            if(c) c.isRed = NO; else if(!self.isRed) [self deleteRebalance];
            SWP(self, c);
            _isRed          = NO;
            _count          = 0;
            _parentNode     = nil;
            _leftChildNode  = nil;
            _rightChildNode = nil;
            return (p ?: c).rootNode;
        }
    }

    -(void)recount {
        _count = (1 + self.leftChildNode.count + self.rightChildNode.count);
        [self.parentNode recount];
    }

    -(void)setIsBlack:(BOOL)isBlack {
        _isRed = !isBlack;
    }

    -(void)insertRebalance {
        RBNp p = self.parentNode;

        if(p) {
            if(p.isRed) {
                RBNp u  = self.uncleNode;
                RBNp g  = self.grandParentNode;
                BOOL pl = (p == (g.leftChildNode));

                if(self.uncleNode.isRed) {
                    g.isRed = (p.isBlack = (u.isBlack = YES));
                    [g insertRebalance];
                }
                else {
                    if((self == p.leftChildNode) != pl) rotate(p, pl);
                    rotate(g, !pl);
                }
            }
        }
        else self.isBlack = YES;
    }

    -(void)deleteRebalance {
        RBNp p = self.parentNode;

        if(p) {
            BOOL nl = (self == p.leftChildNode);
            RBNp s  = ((nl) ? p.rightChildNode : p.leftChildNode);

            /* @f:0 */ if(s.isRed) { rotate(p, nl); s = ((nl) ? p.rightChildNode : p.leftChildNode); } /* @f:1 */
            BOOL a = s.rightChildNode.isRed, b = s.leftChildNode.isRed;

            if(a || b) {
                /* @f:0 */ if((a != b) && (nl == b)) { rotate(s, a); s = s.parentNode; } /* @f:1 */
                rotate(p, nl);
                ((nl) ? s.rightChildNode : s.leftChildNode).isBlack = YES;
            }
            else {
                s.isRed = YES;
                if(p.isRed) p.isBlack = YES; else [p deleteRebalance];
            }
        }
    }

    -(void)_clear {
        /*
         * This is total destruction of the tree so we're going to use the fields rather
         * than the getters and setters so we don't have any side effects slowing us down.
         * In other words we don't need to be worrying about recounting or rebalancing the
         * tree since everything is simply going to be wiped out.
         */
        _count      = 0;
        _isRed      = NO;
        _parentNode = nil;

        if(_leftChildNode) {
            [_leftChildNode _clear];
            _leftChildNode = nil;
        }

        if(_rightChildNode) {
            [_rightChildNode _clear];
            _rightChildNode = nil;
        }
    }

    -(void)clearTree {
        /*
         * Doing a clear on ANY node means clearing the entire tree so let's make sure
         * we're starting at the root node and working our way down.
         */
        [self.rootNode _clear];
    }

    -(RBNp)clearSubTree {
        [self.leftChildNode clearSubTree];
        [self.rightChildNode clearSubTree];
        return [self delete];
    }

    +(instancetype)nodeWithValue:(id)value forKey:(id<NSCopying>)key {
        return [[self alloc] initWithValue:value forKey:key];
    }

    +(instancetype)nodeWithValue:(id)value forKey:(id<NSCopying>)key isRed:(BOOL)isRed {
        return [[self alloc] initWithValue:value forKey:key isRed:isRed];
    }

@end

#define LR(l) ((l)?@"left":@"right")

RBNp rotate(RBNp n, BOOL l) {
    RBNp o = nil;
    if(l) {
        if((o = n.rightChildNode)) {
            SWP(n, o);
            n.rightChildNode = o.leftChildNode;
            o.leftChildNode  = n;
            SC(n, o);
            return o;
        }
    }
    else if((o = n.leftChildNode)) {
        SWP(n, o);
        n.leftChildNode  = o.rightChildNode;
        o.rightChildNode = n;
        SC(n, o);
        return o;
    }

    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(PGErrorMsgCannotRotateNode, LR(l), LR(!l))];
}

