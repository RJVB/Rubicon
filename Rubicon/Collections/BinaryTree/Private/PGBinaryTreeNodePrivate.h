/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeNodePrivate.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/14/17 2:41 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017 Galen Rhodes All rights reserved.
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

#ifndef __Rubicon_PGBinaryTreeNodePrivate_H_
#define __Rubicon_PGBinaryTreeNodePrivate_H_

#import <Rubicon/PGBinaryTreeNode.h>

@interface PGBinaryTreeNode()

	@property(readwrite) BOOL isRed;

	-(void)setKey:(id<NSCopying>)key;

	-(instancetype)getChild:(BOOL)left;

	-(instancetype)setChild:(PGBinaryTreeNode *)child onLeft:(BOOL)left;

	-(void)makeOrphan;

	-(void)setLeftChild:(PGBinaryTreeNode *)child;

	-(void)setRightChild:(PGBinaryTreeNode *)child;

	-(void)rotate:(BOOL)left;

	-(instancetype)farRight;

@end

#endif //__Rubicon_PGBinaryTreeNodePrivate_H_
