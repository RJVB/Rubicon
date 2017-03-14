/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTree.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 12/22/16 1:03 PM
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

#ifndef __Rubicon_PGBinaryTree_H_
#define __Rubicon_PGBinaryTree_H_

#import <Rubicon/PGTools.h>

@interface PGBinaryTreeDictionary : NSMutableDictionary

	-(instancetype)init;

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt;

	-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;

	-(id)objectForKey:(id)aKey;

	-(void)removeObjectForKey:(id)aKey;

	-(NSEnumerator *)keyEnumerator;

@end

#if NS_BLOCKS_AVAILABLE

@interface PGBinaryTreeDictionary(NSComparator)

	-(instancetype)initWithComparator:(NSComparator)comparator;

	-(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt comparator:(NSComparator)comparator;

@end

#endif

#endif //__Rubicon_PGBinaryTree_H_
