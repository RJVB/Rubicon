/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/21/16 4:57 PM
 * DESCRIPTION:
 *
 * Copyright © 2016 Project Galen. All rights reserved.
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

#import "PGBinaryTreeLeaf.h"
#import "NSObject+PGObject.h"
#import "NSString+PGString.h"

#define PGNodeDiameter         ((CGFloat)(60))
#define PGNodeShadowBlurRadius ((CGFloat)(3))
#define PGNodeShadowOffset     ((CGFloat)(2))
#define PGNodeLineWidth        ((CGFloat)(1))
#define PGNodePadding          ((CGFloat)(6))
#define PGNodeFontSize         ((CGFloat)(12))
// #define PGNodeFontName         @"AmericanTypewriter-Light"
#define PGNodeFontName         @"ArialNarrow"

NSColor *_redNodeFillColor     = nil;
NSColor *_redNodeStrokeColor   = nil;
NSColor *_blackNodeFillColor   = nil;
NSColor *_blackNodeStrokeColor = nil;
NSColor *_redNodeFontColor     = nil;
NSColor *_blackNodeFontColor   = nil;
NSColor *_nodeShadowColor      = nil;
NSColor *_childLineColor       = nil;

NSShadow *_nodeShadow = nil;

@implementation PGBinaryTreeLeaf {
	}

	@synthesize parent = _parent;

	-(instancetype)init {
		return (self = [self initWithValue:nil forKey:nil]);
	}

	-(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key {
		self = [super init];

		if(self) {
			self.key   = key;
			self.value = value;
		}

		return self;
	}

	-(instancetype)farLeft {
		return (self.isLeaf ? self.parent : self.left.farLeft);
	}

	-(instancetype)farRight {
		return (self.isLeaf ? self.parent : self.right.farRight);
	}

	-(instancetype)child:(BOOL)left {
		return (left ? self.left : self.right);
	}

	-(instancetype)_find:(id)key withComparator:(NSComparator)comparator {
		if(self.isLeaf) {
			return self;
		}
		else if(self.key == key) {
			return self;
		}
		else if(comparator) {
			switch(comparator(self.key, key)) {
				case NSOrderedAscending:
					return [self.right _find:key withComparator:comparator];
				case NSOrderedDescending:
					return [self.left _find:key withComparator:comparator];
				case NSOrderedSame:
				default:
					return self;
			}
		}
		else {
			return [self _find:key withComparator:[NSObject defaultComparator]];
		}
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key withReferenceNode:(PGBinaryTreeLeaf *)n {
		if(n.isLeaf) {
			PGBinaryTreeLeaf *c = [(PGBinaryTreeLeaf *)[[n.parent class] alloc] initWithValue:value forKey:key];
			[n.parent setChild:c onLeft:n.isLeft];
			[c setIsRed:YES];
			[c insertStep1];
			return c;
		}
		else {
			n.value = value;
			return n;
		}
	}

	-(NSString *)shortDescription {
		return [self description:NO];
	}

	-(NSString *)description {
		return [self description:YES];
	}

	-(NSString *)description:(BOOL)full {
		NSMutableString *str = [NSMutableString stringWithFormat:@"%@ {", NSStringFromClass([self class])];

		if(self.isLeaf) {
			[str appendString:@" leaf = YES;"];
		}
		else {
			[str appendFormat:@" key = \"%@\";", self.key];

			if(full) {
				if(self.parent) {
					[str appendFormat:@" root: NO; parentKey = \"%@\";", self.parent.key];
				}
				else {
					[str appendString:@" root: YES;"];
				}

				[str appendFormat:@" left = %@; right = %@;", self.left.shortDescription, self.right.shortDescription];
			}
		}

		return [str stringByAppendingString:@" }"];
	}

	-(void)insertStep1 {
		PGBinaryTreeLeaf *nodeP = self.parent;

		if(nodeP) {
			if(nodeP.isRed) {
				PGBinaryTreeLeaf *nodeG = self.grandparent;
				PGBinaryTreeLeaf *nodeU = self.uncle;

				nodeG.isRed = YES;

				if(nodeU.isRed) {
					nodeU.isBlack = nodeP.isBlack = YES;
					[nodeG insertStep1];
				}
				else {
					if(self.isRight == nodeP.isLeft) {
						self.isBlack = YES;
						[nodeP rotate:self.isRight];
					}
					else {
						nodeP.isBlack = YES;
					}

					[nodeG rotate:self.isRight];
				}
			}
		}
		else {
			self.isRed = NO;
		}
	}

	-(void)removeStep1 {
		PGBinaryTreeLeaf *nodeP = self.parent;

		if(nodeP) {
			BOOL             isL    = (self == nodeP.left);
			PGBinaryTreeLeaf *nodeS = (isL ? nodeP.right : nodeP.left);

			if(nodeS.isRed) {
				nodeP.isRed   = YES;
				nodeS.isBlack = YES;
				[nodeP rotate:isL];
				nodeS = (isL ? nodeP.right : nodeP.left);
			}

			if(nodeS.isBlack && nodeS.left.isBlack && nodeS.right.isBlack) {
				nodeS.isRed = YES;
				if(nodeP.isBlack) [nodeP removeStep1]; else nodeP.isBlack = YES;
			}
			else {
				if(nodeS.isBlack) {
					if(isL) {
						if(nodeS.right.isBlack) {
							nodeS.isRed = nodeS.left.isBlack = YES;
							[nodeS rotateRight];
							nodeS = nodeP.right;
						}
					}
					else if(nodeS.left.isBlack) {
						nodeS.isRed = nodeS.right.isBlack = YES;
						[nodeS rotateLeft];
						nodeS = nodeP.left;
					}
				}

				nodeS.isBlack = nodeP.isBlack;
				nodeP.isBlack = YES;

				if(isL) {
					nodeS.right.isBlack = YES;
					[nodeP rotateLeft];
				}
				else {
					nodeS.left.isBlack = YES;
					[nodeP rotateRight];
				}
			}
		}
	}

	-(void)recount {
	}

	-(NSUInteger)count {
		return (self.isLeaf ? 0 : (1 + self.left.count + self.right.count));
	}

	-(PGBinaryTreeLeaf *)root {
		return (self.isRoot ? self : self.parent.root);
	}

	-(PGBinaryTreeLeaf *)grandparent {
		return self.parent.parent;
	}

	-(PGBinaryTreeLeaf *)uncle {
		return self.parent.sibling;
	}

	-(PGBinaryTreeLeaf *)sibling {
		return (self.isLeft ? self.parent.right : (self.isRight ? self.parent.left : nil));
	}

	-(BOOL)isRoot {
		return (self.parent == nil);
	}

	-(BOOL)isLeft {
		return (self == self.parent.left);
	}

	-(BOOL)isRight {
		return (self == self.parent.right);
	}

	-(BOOL)isRed {
		return NO;
	}

	-(void)setIsRed:(BOOL)isRed {
	}

	-(BOOL)isBlack {
		return !self.isRed;
	}

	-(void)setIsBlack:(BOOL)isBlack {
		self.isRed = !isBlack;
	}

	-(BOOL)isLeaf {
		return YES;
	}

	-(id)value {
		return nil;
	}

	-(void)setValue:(id)value {
	}

	-(id)key {
		return nil;
	}

	-(void)setKey:(id<NSCopying>)key {
	}

	-(PGBinaryTreeLeaf *)left {
		return nil;
	}

	-(void)setLeft:(PGBinaryTreeLeaf *)left {
	}

	-(PGBinaryTreeLeaf *)right {
		return nil;
	}

	-(void)setRight:(PGBinaryTreeLeaf *)right {
	}

	-(void)setChild:(PGBinaryTreeLeaf *)child onLeft:(BOOL)onLeft {
		if(onLeft) self.left = child; else self.right = child;
	}

	-(void)rotate:(BOOL)left {
		if(left) [self rotateLeft]; else [self rotateRight];
	}

	-(void)rotateLeft {
		PGBinaryTreeLeaf *nodeD = self.right;
		[self.parent setChild:nodeD onLeft:self.isLeft];
		[self setRight:nodeD.left];
		[nodeD setLeft:self];
	}

	-(void)rotateRight {
		PGBinaryTreeLeaf *nodeD = self.left;
		[self.parent setChild:nodeD onLeft:self.isLeft];
		[self setLeft:nodeD.right];
		[nodeD setRight:self];
	}

	-(instancetype)find:(id)key withComparator:(NSComparator)comparator {
		PGBinaryTreeLeaf *n = [self _find:key withComparator:comparator];
		return (n.isLeaf ? nil : n);
	}

	-(instancetype)find:(id)key {
		return [self find:key withComparator:[NSObject defaultComparator]];
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key withComparator:(NSComparator)comparator {
		return [self insertValue:value forKey:key withReferenceNode:[self _find:key withComparator:comparator]];
	}

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key {
		return [self insertValue:value forKey:key withComparator:[NSObject defaultComparator]];
	}

	-(PGBinaryTreeLeaf *)remove {
		PGBinaryTreeLeaf *childL = self.left;
		PGBinaryTreeLeaf *childR = self.right;
		BOOL             leafL   = childL.isLeaf;
		BOOL             leafR   = childR.isLeaf;

		if(leafL || leafR) {
			PGBinaryTreeLeaf *nodeP = self.parent;
			PGBinaryTreeLeaf *nodeC = (leafL ? childR : childL);
			BOOL             isL    = (self == nodeP.left);

			if(self.isBlack) {
				if(nodeC.isBlack) {
					[self removeStep1];
				}
				else {
					nodeC.isBlack = YES;
				}
			}

			[nodeP setChild:nodeC onLeft:isL];
			[self clearNode];
			return (nodeP ? nodeP.root : (nodeC ? (nodeC.isLeaf ? nil : nodeC.root) : nil));
		}
		else {
			NSUInteger       ss         = (self.root.count % 2);
			PGBinaryTreeLeaf *successor = (ss ? childR.farLeft : childL.farRight);
			self.key   = successor.key;
			self.value = successor.value;
			return [successor remove];
		}
	}

	-(void)clearNode {
		self.parent = nil;
		self.value  = nil;
		self.key    = nil;
		self.right  = nil;
		self.left   = nil;
	}

	-(PGBinaryTreeLeaf *)makeOrphan {
		if(self.isRight) self.parent.right = nil; else if(self.isLeft) self.parent.left = nil;
		return self;
	}

	-(PGBinaryTreeLeaf *)adoptMe:(PGBinaryTreeLeaf *)newParent {
		[[self makeOrphan] setParent:newParent];
		return self;
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isInstanceOfObject:self] && [self isEqualToLeaf:(PGBinaryTreeLeaf *)other])));
	}

	-(BOOL)isEqualToLeaf:(PGBinaryTreeLeaf *)leaf {
		return (self == leaf);
	}

	-(NSUInteger)hash {
		return super.hash;
	}

	-(void)resetSize {
		[self.parent resetSize];
	}

	-(void)draw:(NSRect)clipRect {
		if(self.parent) {
			[self.parent draw:clipRect];
		}
		else {
			NSSize neededSize = self.drawSize;
			NSRect neededRect = NSMakeRect(0, 0, neededSize.width, neededSize.height);
			[self draw:neededRect clip:clipRect parentCenter:NSZeroPoint];
		}
	}

	-(void)draw:(NSRect)rect clip:(NSRect)clip parentCenter:(NSPoint)pCenter {
		if(!self.isLeaf) {
			NSSize  lSize = self.left.drawSize;
			NSSize  rSize = self.right.drawSize;
			CGFloat ch    = MAX(lSize.height, rSize.height);
			CGFloat hd    = (PGNodeDiameter * (CGFloat)0.5);
			CGFloat hp    = (PGNodePadding * (CGFloat)0.5);
			CGFloat od    = (PGNodeDiameter - PGNodePadding);
			CGFloat ny    = NSMinY(rect);
			CGFloat cy    = (ny + PGNodeDiameter);

			NSRect  lRect   = NSMakeRect(NSMinX(rect), cy, MAX(lSize.width, hd), ch);
			NSRect  rRect   = NSMakeRect(NSMaxX(lRect), cy, MAX(rSize.width, hd), ch);
			NSRect  nRect   = NSMakeRect(NSMaxX(lRect) - hd + hp, ny + hp, od, od);
			NSPoint nCenter = NSMakePoint(NSMidX(nRect), NSMidY(nRect));

			[self.left draw:lRect clip:clip parentCenter:nCenter];
			[self.right draw:rRect clip:clip parentCenter:nCenter];

			if(self.parent) {
				[self drawChildCurve:pCenter childCenter:nCenter];
			}

			[self drawNodeOval:nRect];
		}
	}

	-(void)drawNodeOval:(NSRect)rect {
		[NSGraphicsContext saveGraphicsState];
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
		[self.nodeShadow set];
		[self.nodeFillColor setFill];
		[self.nodeStrokeColor setStroke];
		[path setLineWidth:PGNodeLineWidth];
		[path fill];
		[path stroke];
		[NSGraphicsContext restoreGraphicsState];
		[self.key drawDeadCentered:rect fontName:PGNodeFontName fontSize:PGNodeFontSize fontColor:self.nodeFontColor];
	}

	-(void)drawChildCurve:(NSPoint)pCenter childCenter:(NSPoint)cCenter {
		if(self.parent) {
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path moveToPoint:pCenter];
			[path curveToPoint:cCenter controlPoint1:pCenter controlPoint2:NSMakePoint(cCenter.x, pCenter.y)];
			[path setLineCapStyle:NSRoundLineCapStyle];
			[path setLineJoinStyle:NSRoundLineJoinStyle];
			[self.childLineColor setStroke];
			[path setLineWidth:PGNodeLineWidth];
			[path stroke];
		}
	}

	-(NSRect)nodeOvalRect:(NSRect)rect {
		CGFloat hp = (PGNodePadding * 0.5);
		CGFloat aw = (PGNodeDiameter - PGNodePadding);
		CGFloat nx = (NSMidX(rect) - (PGNodeDiameter * 0.5) + hp);
		CGFloat ny = (NSMinY(rect) + hp);
		return NSMakeRect(nx, ny, aw, aw);
	}

	-(NSSize)drawSize {
		if(self.isLeaf) {
			return NSZeroSize;
		}
		else {
			NSSize  leftSize  = self.left.drawSize;
			NSSize  rightSize = self.right.drawSize;
			CGFloat width     = PGNodeDiameter;
			CGFloat height    = (PGNodeDiameter + MAX(leftSize.height, rightSize.height));
			CGFloat halfWidth = (PGNodeDiameter * (CGFloat)0.5);

			if(leftSize.width > 0) {
				width = ((width - halfWidth) + leftSize.width);
			}

			if(rightSize.width > 0) {
				width = ((width - halfWidth) + rightSize.width);
			}

			return NSMakeSize(width, height);
		}
	}

	-(NSShadow *)nodeShadow {
		@synchronized([self class]) {
			if(_nodeShadow == nil) {
				_nodeShadow = [[NSShadow alloc] init];
				[_nodeShadow setShadowColor:[self nodeShadowColor]];
				[_nodeShadow setShadowOffset:NSMakeSize(PGNodeShadowOffset, (0 - PGNodeShadowOffset))];
				[_nodeShadow setShadowBlurRadius:PGNodeShadowBlurRadius];
			}

			return _nodeShadow;
		}
	}

	-(NSColor *)nodeShadowColor {
		@synchronized([self class]) {
			if(_nodeShadowColor == nil) {
				_nodeShadowColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
			}

			return _nodeShadowColor;
		}
	}

	-(NSColor *)redNodeFontColor {
		@synchronized([self class]) {
			if(_redNodeFontColor == nil) {
				_redNodeFontColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
			}

			return _redNodeFontColor;
		}
	}

	-(NSColor *)blackNodeFontColor {
		@synchronized([self class]) {
			if(_blackNodeFontColor == nil) {
				_blackNodeFontColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
			}

			return _blackNodeFontColor;
		}
	}

	-(NSColor *)redNodeStrokeColor {
		@synchronized([self class]) {
			if(_redNodeStrokeColor == nil) {
				_redNodeStrokeColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
			}

			return _redNodeStrokeColor;
		}
	}

	-(NSColor *)blackNodeStrokeColor {
		@synchronized([self class]) {
			if(_blackNodeStrokeColor == nil) {
				_blackNodeStrokeColor = [NSColor colorWithCalibratedRed:0.976 green:1 blue:0.016 alpha:1];
			}

			return _blackNodeStrokeColor;
		}
	}

	-(NSColor *)blackNodeFillColor {
		@synchronized([self class]) {
			if(_blackNodeFillColor == nil) {
				_blackNodeFillColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
			}

			return _blackNodeFillColor;
		}
	}

	-(NSColor *)redNodeFillColor {
		@synchronized([self class]) {
			if(_redNodeFillColor == nil) {
				_redNodeFillColor = [NSColor colorWithCalibratedRed:0.8 green:0.32 blue:0.32 alpha:1];
			}

			return _redNodeFillColor;
		}
	}

	-(NSColor *)nodeFontColor {
		return (self.isBlack ? self.blackNodeFontColor : self.redNodeFontColor);
	}

	-(NSColor *)nodeFillColor {
		return (self.isBlack ? self.blackNodeFillColor : self.redNodeFillColor);
	}

	-(NSColor *)nodeStrokeColor {
		return (self.isBlack ? self.blackNodeStrokeColor : self.redNodeStrokeColor);
	}

	-(NSColor *)childLineColor {
		@synchronized([self class]) {
			if(_childLineColor == nil) {
				_childLineColor = [NSColor colorWithCalibratedRed:0.419 green:0.32 blue:0.8 alpha:1];
			}

			return _childLineColor;
		}
	}

@end

