/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeNode.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/29/17 12:08 PM
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

#ifndef __Rubicon_PGBTreeNode_H_
#define __Rubicon_PGBTreeNode_H_

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGBTreeNode<__covariant T> : NSObject

	@property(retain) T            data;
	@property(readonly) NSUInteger count;
	@property(readonly) BOOL       isRed;

	-(instancetype)initWithData:(T)data;

	-(nullable instancetype)find:(T)data;

	-(instancetype)insert:(T)data;

	-(nullable instancetype)remove;

	-(nullable instancetype)parent;

	-(nullable instancetype)left;

	-(nullable instancetype)right;

	-(nullable instancetype)root;

	-(nullable instancetype)grandparent;

	-(nullable instancetype)sibling;

	-(nullable instancetype)uncle;

	-(void)clearTree;

	+(instancetype)nodeWithData:(T)data;

@end

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGBTreeNode_H_
