/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSMutableDictionary(PGBinaryTreeDictionary).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/6/17 12:27 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
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

#import "NSMutableDictionary+PGBinaryTreeDictionary.h"
#import "PGBinaryTreeDictionary.h"

@implementation NSMutableDictionary(PGBinaryTreeDictionary)

	+(instancetype)binaryTreeDictionary {
		return [[PGBinaryTreeDictionary alloc] init];
	}

	+(instancetype)binaryTreeDictionaryWithComparator:(NSComparator)comparator {
		return [[PGBinaryTreeDictionary alloc] initWithComparator:comparator];
	}

	+(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary *)dictionary andComparator:(NSComparator)comparator {
		PGBinaryTreeDictionary *treeDictionary = [[PGBinaryTreeDictionary alloc] initWithComparator:comparator];

		for(id key in dictionary) {
			treeDictionary[key] = dictionary[key];
		}

		return treeDictionary;
	}

	+(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary *)dictionary {
		return [self binaryTreeDictionaryWithDictionary:dictionary andComparator:nil];
	}

	+(instancetype)binaryTreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey andComparator:(NSComparator)comparator {
		PGBinaryTreeDictionary *treeDictionary = [[PGBinaryTreeDictionary alloc] initWithComparator:comparator];
		[treeDictionary setObject:anObject forKey:aKey];
		return treeDictionary;
	}

	+(instancetype)binaryTreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey {
		return [self binaryTreeDictionaryWithObject:anObject forKey:aKey andComparator:nil];
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)aPath andComparator:(NSComparator)comparator {
		NSDictionary *aDictionary = [NSDictionary dictionaryWithContentsOfFile:aPath];
		return [self binaryTreeDictionaryWithDictionary:aDictionary andComparator:comparator];
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)aPath {
		return [self binaryTreeDictionaryWithContentsOfFile:aPath andComparator:nil];
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)aURL andComparator:(NSComparator)comparator {
		NSDictionary *aDictionary = [NSDictionary dictionaryWithContentsOfURL:aURL];
		return [self binaryTreeDictionaryWithDictionary:aDictionary andComparator:comparator];
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)aURL {
		return [self binaryTreeDictionaryWithContentsOfURL:aURL andComparator:nil];
	}

	+(instancetype)binaryTreeDictionaryWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
		return [self binaryTreeDictionaryWithObjects:objects forKeys:keys count:cnt comparator:nil];
	}

	+(instancetype)binaryTreeDictionaryWithObjects:(const id[])objects
										   forKeys:(const id<NSCopying>[])keys
											 count:(NSUInteger)cnt
										comparator:(NSComparator)comparator {
		return [[PGBinaryTreeDictionary alloc] initWithObjects:objects forKeys:keys count:cnt comparator:comparator];
	}

@end
