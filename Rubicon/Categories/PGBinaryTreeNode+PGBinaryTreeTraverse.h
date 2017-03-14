/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNode(PGBinaryTreeTraverse).h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/14/17 3:19 PM
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

#ifndef __Rubicon_PGBinaryTreeNode_PGBinaryTreeTraverse__H_
#define __Rubicon_PGBinaryTreeNode_PGBinaryTreeTraverse__H_

#import <Cocoa/Cocoa.h>
#import <Rubicon/PGBinaryTreeNode.h>

@interface PGKVNodeVisitor

	-(BOOL)visitNodeWithKey:(id)aKey andValue:(id)aValue;

@end

#if NS_BLOCKS_AVAILABLE

typedef BOOL (^PGKVNodeVisitorBlock)(id aKey, id aValue);

#endif

@interface PGBinaryTreeNode(PGBinaryTreeTraverse)

#if NS_BLOCKS_AVAILABLE

	-(BOOL)travelForwardTreeWithBlock:(PGKVNodeVisitorBlock)visitorBlock;

	-(BOOL)travelBackwardTreeWithBlock:(PGKVNodeVisitorBlock)visitorBlock;

#endif

	-(BOOL)travelForwardTreeWithVisitor:(PGKVNodeVisitor *)visitor;

	-(BOOL)travelBackwardTreeWithVisitor:(PGKVNodeVisitor *)visitor;

@end

#endif // __Rubicon_PGBinaryTreeNode_PGBinaryTreeTraverse__H_
