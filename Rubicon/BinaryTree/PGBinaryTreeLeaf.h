/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 12/21/16 4:57 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2016  Project Galen. All rights reserved.
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

#ifndef __Rubicon_PGBinaryTreeLeaf_H_
#define __Rubicon_PGBinaryTreeLeaf_H_

#import <Rubicon/GNUstep.h>

@class PGSize;
@class PGRect;

@interface PGBinaryTreeLeaf : NSObject

	@property(nonatomic, retain) id               value;
	@property(nonatomic, copy) id key;
	@property(nonatomic, assign) BOOL             isRed;
	@property(nonatomic, assign) BOOL             isBlack;
	@property(nonatomic, retain) PGBinaryTreeLeaf *parent;
	@property(nonatomic, retain) PGBinaryTreeLeaf *left;
	@property(nonatomic, retain) PGBinaryTreeLeaf *right;

	@property(nonatomic, readonly) PGBinaryTreeLeaf *root;
	@property(nonatomic, readonly) PGBinaryTreeLeaf *grandparent;
	@property(nonatomic, readonly) PGBinaryTreeLeaf *uncle;
	@property(nonatomic, readonly) PGBinaryTreeLeaf *sibling;
	@property(nonatomic, readonly) BOOL             isRoot;
	@property(nonatomic, readonly) BOOL             isLeft;
	@property(nonatomic, readonly) BOOL             isRight;
	@property(nonatomic, readonly) BOOL             isLeaf;
	@property(nonatomic, readonly) NSUInteger       count;

	-(instancetype)init;

	-(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key;

	-(NSString *)shortDescription;

	-(NSString *)description;

	-(void)rotateLeft;

	-(void)rotateRight;

	-(void)rotate:(BOOL)left;

	-(instancetype)find:(id)key;

	-(instancetype)find:(id)key withComparator:(NSComparator)comparator;

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key;

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key withComparator:(NSComparator)comparator;

	-(PGBinaryTreeLeaf *)remove;

	-(void)clearNode;

	-(void)draw:(NSRect)clipRect;

	-(NSSize)drawSize;

	-(BOOL)isEqual:(id)other;

	-(BOOL)isEqualToLeaf:(PGBinaryTreeLeaf *)leaf;

	-(NSUInteger)hash;

@end

#endif //__Rubicon_PGBinaryTreeLeaf_H_
