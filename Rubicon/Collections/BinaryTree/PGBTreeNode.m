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
#import "PGTools.h"

PGBTreeNode *farLeft(PGBTreeNode *node) { return (node.left ? farLeft(node.left) : node); }

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
				self.data  = data;
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

#pragma clang diagnostic pop

	-(instancetype)root { return (_parent ? _parent.root : self); }

	-(nullable instancetype)grandparent { return (_parent ? _parent->_parent : nil); }

	-(nullable instancetype)sibling { return (_parent ? ((self == _parent->_left) ? _right : _left) : nil); }

	-(nullable instancetype)uncle { return (_parent.sibling); }

	-(nullable instancetype)child:(BOOL)onLeft { return (onLeft ? _left : _right); }

	-(nullable instancetype)parent { return _parent; }

	-(nullable instancetype)left { return _left; }

	-(nullable instancetype)right { return _right; }

	-(BOOL)allBlack { return !(self.isRed || self.left.isRed || self.right.isRed); }

	-(BOOL)isLeft { return (_parent && (self == _parent->_left)); }

	-(BOOL)isRight { return (_parent && (self == _parent->_right)); }

	-(void)setIsRed:(BOOL)b { _isRed = b; }

	-(void)setParent:(nullable PGBTreeNode *)node { _parent = node; }

	-(void)recount {
		_count = (1 + _left.count + _right.count);
		[_parent recount];
	}

	-(instancetype)makeOrphan {
		[self.parent setChild:nil onLeft:self.isLeft];
		return self;
	}

	-(nullable instancetype)setChild:(nullable PGBTreeNode *)child onLeft:(BOOL)onLeft {
		if(self == child) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A node cannot be it's own child." userInfo:nil];
		}
		else {
			child.makeOrphan.parent = self;
			if(onLeft) {
				_left.parent = nil;
				_left = child;
			}
			else {
				_right.parent = nil;
				_right = child;
			}
			[self recount];
			return child;
		}
	}

	-(void)rotate:(BOOL)toTheLeft {
		PGBTreeNode *child = [self child:!toTheLeft];

		if(child) {
			[self.parent setChild:child onLeft:self.isLeft];
			[self setChild:[child child:toTheLeft] onLeft:!toTheLeft];
			[child setChild:self onLeft:toTheLeft];
			// Swap colors.
			BOOL r = self.isRed;
			self.isRed  = child.isRed;
			child.isRed = r;
		}
		else {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(@"Node cannot be rotated to the %@.", (toTheLeft ? @"left" : @"right")) userInfo:nil];
		}
	}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

	-(nullable instancetype)find:(id)data {
		if(data) {
			switch(PGCompare(self.data, data)) {
				case NSOrderedAscending:
					return [self.right find:data];
				case NSOrderedDescending:
					return [self.left find:data];
				case NSOrderedSame:
					return self;
			}
		}

		return nil;
	}

	-(instancetype)insert:(id)data {
		if(data) {
			switch(PGCompare(self.data, data)) {
				case NSOrderedAscending:
					return [self foobar:data child:self.right onLeft:NO];
				case NSOrderedDescending:
					return [self foobar:data child:self.left onLeft:YES];
				case NSOrderedSame:
					self.data = data;
					return self;
			}
		}
		else {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Data cannot be null." userInfo:nil];
		}

		return nil;
	}

#pragma clang diagnostic pop

	-(instancetype)foobar:(id)data child:(nullable PGBTreeNode *)child onLeft:(BOOL)onLeft {
		return (child ? [child insert:data] : [self setChild:[[self class] nodeWithData:data isRed:YES] onLeft:onLeft].ibal);
	}

	-(instancetype)ibal {
		PGBTreeNode *pnode = self.parent;

		if(pnode) {
			if(pnode.isRed) {
				PGBTreeNode *gnode = self.grandparent;
				PGBTreeNode *unode = self.uncle;

				if(unode.isRed) {
					pnode.isRed = unode.isRed = !(gnode.isRed = YES);
					[gnode ibal];
				}
				else {
					if(pnode.isRight == self.isLeft) [pnode rotate:pnode.isLeft];
					[gnode rotate:pnode.isRight];
				}
			}
		}
		else self.isRed = NO;

		return self;
	}

	-(nullable instancetype)remove {
		PGBTreeNode *lc = self.left;
		PGBTreeNode *rc = self.right;

		if(lc && rc) {
			PGBTreeNode *ch = farLeft(rc);
			self.data = ch.data;
			return ch.remove;
		}
		else {
			PGBTreeNode *rt = nil;
			PGBTreeNode *ch = (lc ? lc : rc);
			PGBTreeNode *pn = self.parent;

			if(ch) {
				ch.isRed = NO;
				rt = (pn ? [pn setChild:ch onLeft:self.isLeft].root : [ch makeOrphan]);
			}
			else if(pn) {
				if(!self.isRed) [self rbal];
				rt = pn.root;
				[self makeOrphan];
			}

			_parent = nil;
			_right  = nil;
			_left   = nil;
			_data   = nil;
			return rt;
		}
	}

	-(instancetype)rbal {
		PGBTreeNode *pnode = self.parent; // My parent will not change.

		if(pnode) {
			BOOL nleft = self.isLeft; // I will always be on the same side of my parent.
			if(self.sibling.isRed) [pnode rotate:nleft];

			if(self.sibling.allBlack) {
				self.sibling.isRed = YES;
				if(pnode.isRed) pnode.isRed = NO; else [pnode rbal];
			}
			else {
				BOOL nright = !nleft;
				if(![self.sibling child:nright].isRed) [self.sibling rotate:nright];
				[self.sibling child:nright].isRed = NO;
				[pnode rotate:nleft];
			}
		}
		return self;
	}

@end
