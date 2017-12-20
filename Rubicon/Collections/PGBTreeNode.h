/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeNode.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/18/17 9:19 AM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * "It can hardly be a coincidence that no language on Earth has ever produced the expression 'As pretty as an airport.' Airports
 * are ugly. Some are very ugly. Some attain a degree of ugliness that can only be the result of special effort."
 * - Douglas Adams from "The Long Dark Tea-Time of the Soul"
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *********************************************************************************************************************************/

#ifndef __Rubicon_PGBTreeNode_H_
#define __Rubicon_PGBTreeNode_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGBTreeNode<__covariant K, __covariant V> : NSObject

    @property(nonatomic, readonly, copy) K    nodeKey;
    @property(nonatomic, readonly) V          nodeValue;
    @property(nonatomic, readonly) BOOL       isRed;
    @property(nonatomic, readonly) NSUInteger count;

    @property(nonatomic, readonly) PGBTreeNode<K, V> *parentNode;
    @property(nonatomic, readonly) PGBTreeNode<K, V> *leftNode;
    @property(nonatomic, readonly) PGBTreeNode<K, V> *rightNode;
    @property(nonatomic, readonly) PGBTreeNode<K, V> *rootNode;

    -(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key;

    -(void)deepRemove;

    -(instancetype)findNodeForKey:(K)key;

    -(instancetype)findNodeForKey:(K)key usingComparator:(NSComparator)comp;

    -(instancetype)remove;

    -(instancetype)insertValue:(V)value forKey:(K<NSCopying>)key;

    -(instancetype)insertValue:(V)value forKey:(K<NSCopying>)key usingComparator:(NSComparator)comp;

@end

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGBTreeNode_H_
