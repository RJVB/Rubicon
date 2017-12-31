/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeNodeEnumerator.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/23/17 9:31 PM
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

#ifndef __Rubicon_PGBTreeNodeEnumerator_H_
#define __Rubicon_PGBTreeNodeEnumerator_H_

#import <Rubicon/PGBTreeMutableDictionary.h>
#import <Rubicon/PGBTreeNode.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGBTreeMutableDictionary<__covariant K, V>()

    @property(atomic, retain, nullable) PGBTreeNode<K, V> *rootNode;

@end

@interface PGBTreeNodeKeyEnumerator<__covariant T> : NSEnumerator<T>

    -(instancetype)initWithDictionary:(PGBTreeMutableDictionary<T, id> *)dictionary;

    +(instancetype)enumeratorWithDictionary:(PGBTreeMutableDictionary<T, id> *)dictionary;

    -(T)nextObject;

@end

@interface PGBTreeNodeReverseKeyEnumerator<__covariant T> : PGBTreeNodeKeyEnumerator<T>

    -(T)nextObject;

@end

@interface PGBTreeNodeValueEnumerator<__covariant T> : NSEnumerator<T>

    -(instancetype)initWithDictionary:(PGBTreeMutableDictionary<T, id> *)dictionary;

    +(instancetype)enumeratorWithDictionary:(PGBTreeMutableDictionary<T, id> *)dictionary;

    -(T)nextObject;

@end

@interface PGBTreeNodeReverseValueEnumerator<__covariant T> : PGBTreeNodeValueEnumerator<T>

    -(T)nextObject;

@end

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGBTreeNodeEnumerator_H_
