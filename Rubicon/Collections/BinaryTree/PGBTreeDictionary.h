/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeDictionary.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/31/17 2:10 PM
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

#ifndef __Rubicon_PGBTreeDictionary_H_
#define __Rubicon_PGBTreeDictionary_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGBTreeDictionary<__covariant K, __covariant V> : NSDictionary<K, V>

    -(instancetype)init;

    -(instancetype)initWithDictionary:(NSDictionary<K, V> *)otherDictionary;

    -(instancetype)initWithDictionary:(NSDictionary<K, V> *)otherDictionary copyItems:(BOOL)flag;

    -(instancetype)initWithObjects:(const V _Nonnull[_Nullable])objects forKeys:(const K<NSCopying> _Nonnull[_Nullable])keys count:(NSUInteger)cnt;

    -(instancetype)initWithObject:(const V)object forKey:(const K<NSCopying>)key;

    -(instancetype)initWithCoder:(NSCoder *)coder;

    -(instancetype)initWithContentsOfFile:(NSString *)path;

    -(instancetype)initWithContentsOfURL:(NSURL *)url;

    -(nullable V)objectForKey:(K)aKey;

    -(NSEnumerator<K> *)keyEnumerator;

    -(id)mutableCopyWithZone:(nullable NSZone *)zone;

    -(id)copyWithZone:(nullable NSZone *)zone;

@end

@interface PGBTreeMutableDictionary<__covariant K, __covariant V> : NSMutableDictionary<K, V>

    -(instancetype)init;

    -(instancetype)initWithCapacity:(NSUInteger)numItems;

    -(instancetype)initWithDictionary:(NSDictionary<K, V> *)otherDictionary;

    -(instancetype)initWithDictionary:(NSDictionary<K, V> *)otherDictionary copyItems:(BOOL)flag;

    -(instancetype)initWithObjects:(const V _Nonnull[_Nullable])objects forKeys:(const K<NSCopying> _Nonnull[_Nullable])keys count:(NSUInteger)cnt;

    -(instancetype)initWithObject:(const V)object forKey:(const K<NSCopying>)key;

    -(instancetype)initWithCoder:(NSCoder *)coder;

    -(instancetype)initWithContentsOfFile:(NSString *)path;

    -(instancetype)initWithContentsOfURL:(NSURL *)url;

    -(nullable V)objectForKey:(K)aKey;

    -(NSEnumerator<K> *)keyEnumerator;

    -(void)removeObjectForKey:(K)aKey;

    -(void)setObject:(V)anObject forKey:(K<NSCopying>)aKey;

    -(void)removeAllObjects;

    -(void)dealloc;

    -(id)mutableCopyWithZone:(nullable NSZone *)zone;

    -(id)copyWithZone:(nullable NSZone *)zone;

@end

NS_ASSUME_NONNULL_END
#endif //__Rubicon_PGBTreeDictionary_H_
