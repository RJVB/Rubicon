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

#define orphan(n)        swpnode(n, nil)
#define CN(n, q)         (n).q##ChildNode
#define PN(n)            (n).parentNode

PGRedBlackNode *setchldfld(PGRedBlackNode *s, PGRedBlackNode *f, PGRedBlackNode *n);

PGRedBlackNode *getchld(PGRedBlackNode *p, BOOL r);

void setchld(PGRedBlackNode *p, PGRedBlackNode *n, BOOL r);

void swpnode(PGRedBlackNode *o, PGRedBlackNode *n);

void rotate(PGRedBlackNode *n, BOOL l);

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

    -(PGRedBlackNode *)rootNode {
        PGRedBlackNode *p = PN(self);
        return (p ? p.rootNode : self);
    }

    -(void)setRightChildNode:(PGRedBlackNode *)node {
        _rightChildNode = setchldfld(self, _rightChildNode, node);
        [self recount];
    }

    -(void)setLeftChildNode:(PGRedBlackNode *)node {
        _leftChildNode = setchldfld(self, _leftChildNode, node);
        [self recount];
    }

    -(instancetype)findNodeWithKey:(id)key {
        if(key) {
            if([self.key isEqual:key]) {
                switch(PGCompare(self.key, key)) {
                    case NSOrderedAscending:
                        return [CN(self, right) findNodeWithKey:key];
                    case NSOrderedDescending:
                        return [CN(self, left) findNodeWithKey:key];
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
                        if(CN(self, right)) return [CN(self, right) insertValue:value forKey:key];
                        else {
                            PGRedBlackNode *node = CN(self, right) = [PGRedBlackNode nodeWithValue:value forKey:key isRed:YES];
                            [node insertRebalance];
                            return node;
                        }
                    case NSOrderedDescending:
                        if(CN(self, left)) return [CN(self, left) insertValue:value forKey:key];
                        else {
                            PGRedBlackNode *node = CN(self, left) = [PGRedBlackNode nodeWithValue:value forKey:key isRed:YES];
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
        PGRedBlackNode *lc = CN(self, left);
        PGRedBlackNode *rc = CN(self, right);

        if(lc && rc) {
            while(CN(rc, left)) rc = CN(rc, left);
            self.key   = rc.key;
            self.value = rc.value;
            return [rc delete];
        }
        else {
            PGRedBlackNode *c = (lc ?: rc);
            PGRedBlackNode *p = PN(self);

            if(c) c.isRed = NO; else if(!self.isRed) [self deleteRebalance];
            swpnode(self, c);
            self.key   = nil;
            self.value = nil;
            return (p ?: c).rootNode;
        }
    }

    -(void)recount {
        _count = (1 + CN(self, left).count + CN(self, right).count);
        [PN(self) recount];
    }

    -(void)setIsBlack:(BOOL)isBlack {
        _isRed = !isBlack;
    }

    -(void)insertRebalance {
        PGRedBlackNode *g, *u, *p = PN(self);
        BOOL           pl;

        if(p) {
            if(p.isRed) {
                if((u = getchld(p, (pl = (p == ((g = PN(p)).leftChildNode))))).isRed) {
                    g.isRed = (p.isBlack = (u.isBlack = YES));
                    [g insertRebalance];
                }
                else {
                    if((self == CN(p, left)) != pl) rotate(p, pl);
                    rotate(g, !pl);
                }
            }
        }
        else self.isBlack = YES;
    }

    -(void)deleteRebalance {
        PGRedBlackNode *p = PN(self);

        if(p) {
            BOOL           nl = (self == CN(p, left));
            PGRedBlackNode *s = getchld(p, nl);

            /* @f:0 */ if(s.isRed) { rotate(p, nl); s = getchld(p, nl); } /* @f:1 */
            BOOL a = CN(s, right).isRed, b = CN(s, left).isRed;

            if(a || b) {
                /* @f:0 */ if((a != b) && (nl == b)) { rotate(s, a); s = PN(s); } /* @f:1 */
                rotate(p, nl);
                getchld(s, nl).isBlack = YES;
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
        _key        = nil;
        _value      = nil;
        _parentNode = nil;
        _count      = 0;
        _isRed      = NO;

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

    -(PGRedBlackNode *)clearSubTree {
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

void setchld(PGRedBlackNode *p, PGRedBlackNode *n, BOOL r) {
    if(r) CN(p, right) = n; else CN(p, left) = n;
}

void swpnode(PGRedBlackNode *o, PGRedBlackNode *n) {
    PGRedBlackNode *p = PN(o);
    if(p) setchld(p, n, (o == CN(p, right)));
}

NS_INLINE void swpclr(PGRedBlackNode *a, PGRedBlackNode *b) {
    BOOL c = a.isRed;
    a.isRed = b.isRed;
    b.isRed = c;
}

void rotate(PGRedBlackNode *n, BOOL l) {
    PGRedBlackNode *o = getchld(n, l);
    if(o) {
        swpnode(n, o);
        setchld(n, getchld(o, !l), l);
        setchld(o, n, !l);
        swpclr(n, o);
    }
}

PGRedBlackNode *getchld(PGRedBlackNode *p, BOOL r) {
    return ((r) ? CN(p, right) : CN(p, left));
}

PGRedBlackNode *setchldfld(PGRedBlackNode *s, PGRedBlackNode *f, PGRedBlackNode *n) {
    if(f == n) return f;
    orphan(n);
    PN(f) = nil;
    PN(n) = s;
    return n;
}
