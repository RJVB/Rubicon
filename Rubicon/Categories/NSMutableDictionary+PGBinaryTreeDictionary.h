/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSMutableDictionary(PGBinaryTreeDictionary).h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/6/17 12:27 PM
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

#ifndef __Rubicon_NSMutableDictionary_PGBinaryTreeDictionary__H_
#define __Rubicon_NSMutableDictionary_PGBinaryTreeDictionary__H_

#import <Cocoa/Cocoa.h>

@interface NSMutableDictionary(PGBinaryTreeDictionary)

	+(instancetype)binaryTreeDictionary;

	+(instancetype)binaryTreeDictionaryWithComparator:(NSComparator)comparator;

	+(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary *)dictionary andComparator:(NSComparator)comparator;

	+(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary *)dictionary;

	+(instancetype)binaryTreeDictionaryWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt;

	+(instancetype)binaryTreeDictionaryWithObjects:(const id[])objects
										   forKeys:(const id<NSCopying>[])keys
											 count:(NSUInteger)cnt
										comparator:(NSComparator)comparator;

	+(instancetype)binaryTreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey andComparator:(NSComparator)comparator;

	+(instancetype)binaryTreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey;

	+(instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)aPath andComparator:(NSComparator)comparator;

	+(instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)aPath;

	+(instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)aURL andComparator:(NSComparator)comparator;

	+(instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)aURL;

@end

#endif // __Rubicon_NSMutableDictionary_PGBinaryTreeDictionary__H_
