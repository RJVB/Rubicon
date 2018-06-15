/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGRedBlackNode.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/13/18
 *  VISIBILITY: Private
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 **********************************************************************************************************************************************************************************/

#ifndef RUBICON_PGREDBLACKNODE_H
#define RUBICON_PGREDBLACKNODE_H

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGRedBlackNode<K, V> : NSObject

    @property(nonatomic, readonly, copy) K                    key;
    @property(nonatomic) /*           */ V                    value;
    @property(nonatomic, readonly) /* */ BOOL                 isRed;
    @property(nonatomic, readonly) /* */ NSUInteger           count;
    @property(nonatomic, readonly) /* */ PGRedBlackNode<K, V> *parentNode;
    @property(nonatomic, readonly) /* */ PGRedBlackNode<K, V> *rightChildNode;
    @property(nonatomic, readonly) /* */ PGRedBlackNode<K, V> *leftChildNode;
    @property(nonatomic, readonly) /* */ PGRedBlackNode<K, V> *rootNode;

    -(instancetype)initWithValue:(V)value forKey:(K<NSCopying>)key;

    -(instancetype)findNodeWithKey:(K)key;

    -(instancetype)insertValue:(V)value forKey:(K<NSCopying>)key;

    -(instancetype)delete;

    /**
     * This action is the total and final destruction of the tree. If enacted on ANY node in the tree,
     * the entire tree from the root node on down is destroyed. There is no coming back from this as
     * all fields of the nodes are zero'd out.
     *
     * What you probably want, instead of this method, is _clearSubTree_.
     */
    -(void)clearTree;

    /**
     * This method will delete this node and all of it's child nodes. The tree will
     * be rebalanced after each node is removed. Given that you are removing an entire
     * branch then rebalancing of the entire tree (all the way to the root) will most
     * likely take place unless the branch you are removing is very small - like only
     * one or two nodes.
     *
     * @return the new root node after rebalancing is done.
     */
    -(PGRedBlackNode *)clearSubTree;

    +(instancetype)nodeWithValue:(V)value forKey:(K<NSCopying>)key;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGREDBLACKNODE_H
