/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/27/17 7:41 PM
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

#import "PGBinaryTreeNode.h"

@interface PGBinaryTreeNode()

	-(void)setLeftChild:(PGBinaryTreeNode *)cnode;

	-(void)setRightChild:(PGBinaryTreeNode *)cnode;

	-(void)rotate:(BOOL)left;

	-(void)iRebalance;

	-(void)rRebalance;
@end

NS_INLINE PGBinaryTreeNode *PGSuccessor(PGBinaryTreeNode *node) {
	PGBinaryTreeNode *succ = (node ? node.rightChild : nil);

	if(succ) {
		while(succ.leftChild) {
			succ = succ.leftChild;
		}
	}
	return succ;
}

@implementation PGBinaryTreeNode {
		BOOL _isRed;
	}

	@synthesize key = _key;
	@synthesize value = _value;
	@synthesize parent = _parent;
	@synthesize leftChild = _leftChild;
	@synthesize rightChild = _rightChild;

	/*@f:0*/
	NS_INLINE PGBinaryTreeNode *PGNodeGetChild(PGBinaryTreeNode *n, BOOL l)         { return (l ? n->_leftChild : n->_rightChild); }
	NS_INLINE void PGNodeSetChild(PGBinaryTreeNode *n, PGBinaryTreeNode *c, BOOL l) { if(l) n.leftChild = c; else n.rightChild = c; }
	NS_INLINE BOOL PGNodeIsLeft(PGBinaryTreeNode *n)                                { return (n && n->_parent && (n == n->_parent->_leftChild)); }
	NS_INLINE void PGNodeMakeOrphan(PGBinaryTreeNode *n)                            { if(n) PGNodeSetChild(n, nil, PGNodeIsLeft(n)); }
	NS_INLINE void PGNodeSetColor(PGBinaryTreeNode *n, BOOL r)                      { if(n) n->_isRed = r; }
	NS_INLINE BOOL PGNodeIsRed(PGBinaryTreeNode *n)                                 { return (n && n->_isRed); }
	#define PGNodeIsBlack(n)                                                        (!PGNodeIsRed(n))
	#define PGNodeMakeRed(n)                                                        PGNodeSetColor((n), YES)
	#define PGNodeMakeBlack(n)                                                      PGNodeSetColor((n), NO)
	/*@f:1*/

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value {
		self = [super init];

		if(self) {
			_value = value;
			_key   = [(id)key copy];
			_isRed = YES;
		}

		return self;
	}

	-(PGBinaryTreeNode *)rootNode {
		return (self.parent ? self.parent.rootNode : self);
	}

	-(void)setLeftChild:(PGBinaryTreeNode *)cnode {
		if(self == cnode) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be a child to itself." userInfo:nil];
		}
		else if(_leftChild != cnode) {
			PGNodeMakeOrphan(cnode);
			/* @f:0 */ if(_leftChild) _leftChild->_parent = nil; /* @f:1 */
			_leftChild = cnode;
			/* @f:0 */ if(_leftChild) _leftChild->_parent = self; /* @f:1 */
		}
	}

	-(void)setRightChild:(PGBinaryTreeNode *)cnode {
		if(self == cnode) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be a child to itself." userInfo:nil];
		}
		else if(_rightChild != cnode) {
			PGNodeMakeOrphan(cnode);
			/* @f:0 */ if(_rightChild) _rightChild->_parent = nil; /* @f:1 */
			_rightChild = cnode;
			/* @f:0 */ if(_rightChild) _rightChild->_parent = self; /* @f:1 */
		}
	}

	-(void)rotate:(BOOL)left {
		PGBinaryTreeNode *node = PGNodeGetChild(self, !left);
		PGNodeSetChild(self->_parent, node, PGNodeIsLeft(self));
		PGNodeSetChild(self, PGNodeGetChild(node, left), !left);
		PGNodeSetChild(node, self, left);
		BOOL r = _isRed;
		_isRed = PGNodeIsRed(node);
		PGNodeSetColor(node, r);
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key onLeft:(BOOL)left {
		PGBinaryTreeNode *node = [PGBinaryTreeNode nodeWithKey:key value:value];
		PGNodeSetChild(self, node, left);
		[node iRebalance];
		return node;
	}

#if NS_BLOCKS_AVAILABLE

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key comparator:(NSComparator)cmp {
		if(cmp == nil) {
			return [self insertValue:value forKey:key];
		}

		if(key && value) {
			switch(cmp(key, _key)) {
				case NSOrderedSame:
					_value = value;
					return self;
				case NSOrderedAscending:
					return (_leftChild ? [_leftChild insertValue:value forKey:key comparator:cmp] : [self insertValue:value forKey:key onLeft:YES]);
				case NSOrderedDescending:
					return (_rightChild ? [_rightChild insertValue:value forKey:key comparator:cmp] : [self insertValue:value forKey:key onLeft:NO]);
			}
		}

		return nil;
	}

#endif

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
		if(key && value) {
			switch(PGCompare(key, _key)) {
				case NSOrderedSame:
					_value = value;
					return self;
				case NSOrderedAscending:
					return (_leftChild ? [_leftChild insertValue:value forKey:key] : [self insertValue:value forKey:key onLeft:YES]);
				case NSOrderedDescending:
					return (_rightChild ? [_rightChild insertValue:value forKey:key] : [self insertValue:value forKey:key onLeft:NO]);
			}
		}

		return nil;
	}

#if NS_BLOCKS_AVAILABLE

	-(instancetype)findNodeForKey:(id)key comparator:(NSComparator)compare {
		if(compare) {
			if(key) {
				switch(compare(key, _key)) {
					case NSOrderedSame:
						return self;
					case NSOrderedAscending:
						return [_leftChild findNodeForKey:key comparator:compare];
					case NSOrderedDescending:
						return [_rightChild findNodeForKey:key comparator:compare];
				}
			}

			return nil;
		}
		else {
			return [self findNodeForKey:key];
		}
	}

#endif

	-(instancetype)findNodeForKey:(id)key {
		if(key) {
			switch(PGCompare(key, _key)) {
				case NSOrderedSame:
					return self;
				case NSOrderedAscending:
					return [_leftChild findNodeForKey:key];
				case NSOrderedDescending:
					return [_rightChild findNodeForKey:key];
			}
		}

		return nil;
	}

	NS_INLINE void PGInsRebalance(PGBinaryTreeNode *p, PGBinaryTreeNode *g, BOOL ml) {
		/* @f:0 */
		BOOL pr = (p == g->_rightChild);
		PGBinaryTreeNode *u = PGNodeGetChild(g, pr);
		if(PGNodeIsRed(u)) { p->_isRed = u->_isRed = !(g->_isRed = YES); [g iRebalance]; }
		else { if(ml == pr) { [p rotate:!pr]; } [g rotate:pr]; }
		/* @f:1 */
	}

	-(void)iRebalance {
		/* @f:0 */
		PGBinaryTreeNode *p = _parent;
		if(p) { if(p->_isRed) PGInsRebalance(p, p->_parent, (self == p->_leftChild)); } else _isRed = NO;
		/* @f:1 */
	}

	-(instancetype)remove {
		/*@f:0*/
		if(_leftChild && _rightChild) {
			PGBinaryTreeNode *node = PGSuccessor(self); _key = [node->_key copy]; _value = node->_value; return [node remove];
		}
		else {
			PGBinaryTreeNode *p = _parent;
			PGBinaryTreeNode *c = (_leftChild ? _leftChild : _rightChild);
			if(c) { c->_isRed = NO; if(p) PGNodeSetChild(p, c, (self == p->_leftChild)); }
			else if(p) { if(!_isRed) { [self rRebalance]; } PGNodeMakeOrphan(self); }
			_key = nil; _value = nil; return (p ? p.rootNode : (c ? c.rootNode : nil));
		}
		/*@f:1*/
	}

	-(void)rRebalance {
		/*@f:0*/
		if(_parent) {
			BOOL mr = (self == _parent->_rightChild);
			PGBinaryTreeNode *sibling = PGNodeGetChild(_parent, mr);
			if(PGNodeIsRed(sibling)) { [_parent rotate:!mr]; sibling = PGNodeGetChild(_parent, mr); }
			if(PGNodeIsBlack(sibling) && PGNodeIsBlack(sibling->_leftChild) && PGNodeIsBlack(sibling->_rightChild)) {
				PGNodeMakeRed(sibling);
				if(PGNodeIsRed(_parent)) PGNodeMakeBlack(_parent); else [_parent rRebalance];
			}
			else {
				if(PGNodeIsBlack(PGNodeGetChild(sibling, mr))) [sibling rotate:mr];
				[_parent rotate:!mr];
				PGNodeMakeBlack(PGNodeGetChild(_parent->_parent, mr));
			}
		}
		/*@f:1*/
	}

	+(instancetype)nodeWithKey:(id<NSCopying>)key value:(id)value {
		return [[self alloc] initWithKey:key value:value];
	}

@end
