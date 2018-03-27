/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMutableBinaryTreeDictionary.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/26/18
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

#ifndef RUBICON_PGMUTABLEBINARYTREEDICTIONARY_H
#define RUBICON_PGMUTABLEBINARYTREEDICTIONARY_H

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGMutableBinaryTreeDictionary<K, V> : NSMutableDictionary<K, V>

    -(instancetype)init NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;

    -(nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

#ifdef DEBUG

    -(instancetype)initWithObject:(V)anObject forKey:(id<NSCopying>)aKey;

#else

    -(instancetype)initWithObject:(V)anObject forKey:(K<NSCopying>)aKey;

#endif

    -(void)addEntriesFromDictionary:(NSDictionary<K, V> *)otherDictionary copyItems:(BOOL)flag;

@end

@interface NSMutableDictionary<K, V>(PGMutableBinaryTreeDictionary)

    +(instancetype)binaryTreeDictionary;

#ifdef DEBUG

    +(instancetype)binaryTreeDictionaryWithObject:(V)anObject forKey:(id<NSCopying>)aKey;

#else

    +(instancetype)binaryTreeDictionaryWithObject:(V)anObject forKey:(K<NSCopying>)aKey;

#endif

#if TARGET_OS_WIN32

    + (instancetype)binaryTreeDictionaryWithObjects:(const V _Nonnull [_Nullable])objects forKeys:(const K _Nonnull [_Nullable])keys count:(NSUInteger)cnt;

#else

    +(instancetype)binaryTreeDictionaryWithObjects:(const V _Nonnull[_Nullable])objects forKeys:(const K<NSCopying> _Nonnull[_Nullable])keys count:(NSUInteger)cnt;

#endif

    +(instancetype)binaryTreeDictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead");

    +(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary<K, V> *)dict;

    +(instancetype)binaryTreeDictionaryWithObjects:(NSArray<V> *)objects forKeys:(NSArray<K<NSCopying>> *)keys;

    +(nullable instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)path;

    +(nullable instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGMUTABLEBINARYTREEDICTIONARY_H
