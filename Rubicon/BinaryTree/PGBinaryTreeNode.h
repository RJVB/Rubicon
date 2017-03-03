/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 2/27/17 7:41 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017  Project Galen. All rights reserved.
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

#ifndef __Rubicon_PGBinaryTreeNode_H_
#define __Rubicon_PGBinaryTreeNode_H_

#import <Cocoa/Cocoa.h>

@interface PGBinaryTreeNode : NSObject

	@property(copy, readonly) id   key;
	@property(retain) id           value;
	@property(readonly) NSUInteger count;
	@property(readonly) BOOL       isRootNode;

	@property(nonatomic, retain) PGBinaryTreeNode *parentNode;
	@property(nonatomic, retain) PGBinaryTreeNode *leftNode;
	@property(nonatomic, retain) PGBinaryTreeNode *rightNode;
	@property(readonly, retain) PGBinaryTreeNode  *rootNode;

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value isRed:(BOOL)isRed;

	+(instancetype)nodeWithKey:(id<NSCopying>)key value:(id)value isRed:(BOOL)isRed;

	-(instancetype)initWithKey:(id<NSCopying>)key value:(id)value;

	+(instancetype)nodeWithKey:(id<NSCopying>)key value:(id)value;

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key comparator:(NSComparator)compare;

	-(instancetype)insertValue:(id)value forKey:(id<NSCopying>)key;

	-(instancetype)findNodeForKey:(id)key comparator:(NSComparator)compare;

	-(instancetype)findNodeForKey:(id)key;

	-(instancetype)remove;

@end

#endif //__Rubicon_PGBinaryTreeNode_H_
