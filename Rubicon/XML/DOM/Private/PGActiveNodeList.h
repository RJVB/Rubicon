/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGActiveNodeList.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/31/17 9:39 PM
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

#ifndef __Rubicon_PGActiveNodeList_H_
#define __Rubicon_PGActiveNodeList_H_

#import <Cocoa/Cocoa.h>
#import <Rubicon/PGNodeList.h>

FOUNDATION_EXPORT NSString *const PGDOMChildListDidChangeNotification;

@interface PGActiveNodeList : PGNodeList

	@property(nonatomic, readonly) NSMutableArray *nodeList;

	-(instancetype)initWithParentNode:(PGNode *)parentNode;

	-(NSUInteger)count;

	-(PGNode *)item:(NSUInteger)index;

	-(void)childListChangeNotification:(NSNotification *)notification;

@end

#endif //__Rubicon_PGActiveNodeList_H_
