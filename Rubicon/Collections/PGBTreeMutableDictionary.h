/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeMutableDictionary.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/23/17 9:10 PM
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
 */

#ifndef __Rubicon_PGBTreeMutableDictionary_H_
#define __Rubicon_PGBTreeMutableDictionary_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGBTreeMutableDictionary<__covariant KeyType, __covariant ObjectType> : NSMutableDictionary<KeyType, ObjectType><NSLocking>

    -(instancetype)init;

    -(instancetype)initWithObjects:(const ObjectType _Nonnull[_Nullable])objects forKeys:(const KeyType<NSCopying> _Nonnull[_Nullable])keys count:(NSUInteger)cnt;

    -(void)removeObjectForKey:(KeyType)aKey;

    -(void)setObject:(ObjectType)anObject forKey:(KeyType<NSCopying>)aKey;

    -(ObjectType)objectForKey:(KeyType)aKey;

    -(NSEnumerator<KeyType> *)keyEnumerator;

    -(NSEnumerator<KeyType> *)objectEnumerator;

@end

@interface NSMutableDictionary<KeyType, ObjectType>(PGBTreeMutableDictionary)

    +(PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionary;

    +(PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionaryWithObject:(ObjectType)object forKey:(KeyType<NSCopying>)key;

#if TARGET_OS_WIN32

    +(PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionaryWithObjects:(const ObjectType _Nonnull [_Nullable])objects forKeys:(const KeyType _Nonnull [_Nullable])keys count:(NSUInteger)cnt;

#else

    /*  @formatter:off */
    +(PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionaryWithObjects:(const ObjectType _Nonnull[_Nullable])objects forKeys:(const KeyType<NSCopying> _Nonnull[_Nullable])keys count:(NSUInteger)cnt;
    /* @formatter:on */

#endif

    +(PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionaryWithDictionary:(NSDictionary<KeyType, ObjectType> *)dict;

    +(PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionaryWithObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType<NSCopying>> *)keys;

    /* Reads dictionary stored in NSPropertyList format from the specified url. @formatter:off */
    +(nullable PGBTreeMutableDictionary<NSString *, ObjectType> *)binaryTreeDictionaryWithContentsOfURL:(NSURL *)url error:(NSError **)error API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) NS_SWIFT_UNAVAILABLE("Use initializer instead");
    /* @formatter:on */

    +(nullable PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionaryWithContentsOfFile:(NSString *)path;

    +(nullable PGBTreeMutableDictionary<KeyType, ObjectType> *)binaryTreeDictionaryWithContentsOfURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGBTreeMutableDictionary_H_
