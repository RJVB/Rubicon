/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/29/17 12:08 PM
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

#import "PGBTreeNode.h"
#import "PGBTreeNodePriv.h"

#define PGBTreeChild(p, l) ((l)?((p).left):((p).right))

@implementation PGBTreeNode {
        PGBTreeNode *_parent;
        PGBTreeNode *_left;
        PGBTreeNode *_right;
    }

    @synthesize data = _data;
    @synthesize isRed = _isRed;
    @synthesize count = _count;

    -(instancetype)initWithData:(id)data isRed:(BOOL)isRed {
        self = [super init];

        if(self) {
            if(data && [data respondsToSelector:@selector(compare:)]) {
                _data = data;
                self.isRed = isRed;
            }
            else {
                NSString *reason = (data ? @"data class does not respond to compare: selector." : @"data is nil.");
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
            }
        }

        return self;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

    -(instancetype)initWithData:(id)data { return (self = [self initWithData:data isRed:NO]); }

    +(instancetype)nodeWithData:(id)data isRed:(BOOL)isRed { return [[self alloc] initWithData:data isRed:isRed]; }

    +(instancetype)nodeWithData:(id)data { return [[self alloc] initWithData:data isRed:NO]; }

#pragma clang diagnostic pop

    -(void)recount {
        _count = (1 + self.left.count + self.right.count);
        [self.parent recount];
    }

    -(instancetype)root { return (_parent ? _parent.root : self); }

    -(instancetype)parent { return _parent; }

    -(void)setParent:(PGBTreeNode *)parent { _parent = parent; }

    -(instancetype)left { return _left; }

    -(void)setLeft:(PGBTreeNode *)child {
        if(self == child) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be it's own child." userInfo:nil];
        }

        if(_left != child) {
            if(child) {
                [child replaceMeWith:nil];
                child->_parent = self;
            }
            if(_left) _left->_parent = nil;
            _left = child;
            [self recount];
        }
    }

    -(instancetype)right { return _right; }

    -(void)setRight:(PGBTreeNode *)child {
        if(self == child) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be it's own child." userInfo:nil];
        }

        if(_right != child) {
            if(child) {
                [child replaceMeWith:nil];
                child->_parent = self;
            }
            if(_right) _right->_parent = nil;
            _right = child;
            [self recount];
        }
    }

    -(void)rotateLeft {
        PGBTreeNode *child = self.right;

        if(child) {
            [self replaceMeWith:child];
            self.right = child.left;
            child.left = self;
            [self swapColorsWith:child];
        }
        else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Node cannot be rotated to the left." userInfo:nil];
        }
    }

    -(void)rotateRight {
        PGBTreeNode *child = self.left;

        if(child) {
            [self replaceMeWith:child];
            self.left   = child.right;
            child.right = self;
            [self swapColorsWith:child];
        }
        else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Node cannot be rotated to the right." userInfo:nil];
        }
    }

    -(void)rotate:(BOOL)toTheLeft {
        if(toTheLeft) [self rotateLeft]; else [self rotateRight];
    }

    -(void)swapColorsWith:(PGBTreeNode *)child {
        BOOL r = self.isRed;
        self.isRed  = child.isRed;
        child.isRed = r;
    }

    -(void)replaceMeWith:(PGBTreeNode *)node {
        PGBTreeNode *parent = self.parent;
        if(parent) {
            if(self == parent.left) parent.left = node; else parent.right = node;
        }
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

    -(instancetype)find:(id)data {
        if(data) {
            NSComparisonResult (^compareBlock)(id)=^NSComparisonResult(id nodeData) { return PGCompare(nodeData, data); };
            return [self findWithCompareBlock:compareBlock];
        }

        return nil;
    }

    -(instancetype)findWithCompareBlock:(NSComparisonResult(^)(id nodeData))compareBlock {
        switch(compareBlock(self.data)) {
            case NSOrderedAscending:
                return [self.right findWithCompareBlock:compareBlock];
            case NSOrderedDescending:
                return [self.left findWithCompareBlock:compareBlock];
            default:
                return self;
        }
    }

    -(instancetype)insert:(id)data {
        if(data) {
            NSComparisonResult (^compareBlock)(id)=^NSComparisonResult(id nodeData) { return PGCompare(nodeData, data); };
            return [self insertData:data withCompareBlock:compareBlock];
        }
        else @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Data cannot be null." userInfo:nil];
    }

    -(instancetype)insertData:(id)data withCompareBlock:(NSComparisonResult(^)(id nodeData))compareBlock {
        switch(compareBlock(self.data)) {
            case NSOrderedAscending:
                if(self.right) {
                    return [self.right insertData:data withCompareBlock:compareBlock];
                }
                else {
                    return (self.right = [self.class nodeWithData:data isRed:YES]).ibal;
                }
            case NSOrderedDescending:
                if(self.left) {
                    return [self.left insertData:data withCompareBlock:compareBlock];
                }
                else {
                    return (self.left = [self.class nodeWithData:data isRed:YES]).ibal;
                }
            default:
                _data = data;
                return self;
        }
    }

#pragma clang diagnostic pop

    -(instancetype)ibal {
        PGBTreeNode *pnode = self.parent;

        if(pnode) {
            if(pnode.isRed) {
                PGBTreeNode *gnode = pnode.parent;
                BOOL        pRight = (pnode == gnode.right);
                PGBTreeNode *unode = PGBTreeChild(gnode, pRight);

                if(unode.isRed) {
                    pnode.isRed = unode.isRed = !(gnode.isRed = YES);
                    [gnode ibal];
                }
                else {
                    if(pRight == (self == pnode.left)) [pnode rotate:!pRight];
                    [gnode rotate:pRight];
                }
            }
        }
        else {
            self.isRed = NO;
        }

        return self;
    }

    -(nullable instancetype)remove {
        PGBTreeNode *lc = self.left;
        PGBTreeNode *rc = self.right;

        if(lc && rc) {
            while(rc.left) rc = rc.left;
            _data = rc.data;
            return rc.remove;
        }
        else {
            if(lc) rc = lc;
            lc = self.parent;

            if(!self.isRed) {
                if(rc.isRed) rc.isRed = NO; else [self rbal];
            }
            [self replaceMeWith:rc];
            [self clearFields];
            return (lc ? lc : rc).root;
        }
    }

    -(BOOL)isAllBlack { return !(self.isRed || self.left.isRed || self.right.isRed); }

    -(void)rbal {
        PGBTreeNode *pNode = self.parent;

        if(pNode) {
            BOOL        l      = (self == pNode.left);
            PGBTreeNode *sNode = PGBTreeChild(pNode, !l);

            if(sNode.isRed) {
                [pNode rotate:l];
                sNode = PGBTreeChild(pNode, !l);
            }

            if(sNode.isAllBlack) {
                sNode.isRed = YES;
                if(pNode.isRed) pNode.isRed = NO; else [pNode rbal];
            }
            else {
                if(PGBTreeChild(sNode, l).isRed) {
                    [sNode rotate:!l];
                    sNode = sNode.parent;
                }

                PGBTreeChild(sNode, !l).isRed = NO;
                [pNode rotate:l];
            }
        }
    }

    -(void)clearFields {
        self.left   = nil;
        self.right  = nil;
        self.parent = nil;
        _data = nil;
    }

    -(void)clearTree {
        [self.left clearTree];
        [self.right clearTree];
        [self clearFields];
    }

@end
