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

	+(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary *)dictionary {
		PGBinaryTreeDictionary *treeDictionary = (PGBinaryTreeDictionary *)[self binaryTreeDictionary];

		for(id key in dictionary) {
			[treeDictionary setObject:dictionary[key] forKey:key];
		}

		return treeDictionary;
	}

	+(instancetype)binaryTreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey {
		PGBinaryTreeDictionary *treeDictionary = (PGBinaryTreeDictionary *)[self binaryTreeDictionary];
		[treeDictionary setObject:anObject forKey:aKey];
		return treeDictionary;
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)aPath {
		return [self binaryTreeDictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:aPath]];
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)aURL {
		return [self binaryTreeDictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfURL:aURL]];
	}

	+(instancetype)binaryTreeDictionaryWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
		return [[PGBinaryTreeDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
	}

#if NS_BLOCKS_AVAILABLE

	+(instancetype)binaryTreeDictionaryWithComparator:(NSComparator)comparator {
		return [[PGBinaryTreeDictionary alloc] initWithComparator:comparator];
	}

	+(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary *)dictionary andComparator:(NSComparator)comparator {
		PGBinaryTreeDictionary *treeDictionary = [[PGBinaryTreeDictionary alloc] initWithComparator:comparator];

		for(id key in dictionary) {
			[treeDictionary setObject:dictionary[key] forKey:key];
		}

		return treeDictionary;
	}

	+(instancetype)binaryTreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey andComparator:(NSComparator)comparator {
		PGBinaryTreeDictionary *treeDictionary = [[PGBinaryTreeDictionary alloc] initWithComparator:comparator];
		[treeDictionary setObject:anObject forKey:aKey];
		return treeDictionary;
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)aPath andComparator:(NSComparator)comparator {
		NSDictionary *aDictionary = [NSDictionary dictionaryWithContentsOfFile:aPath];
		return [self binaryTreeDictionaryWithDictionary:aDictionary andComparator:comparator];
	}

	+(instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)aURL andComparator:(NSComparator)comparator {
		NSDictionary *aDictionary = [NSDictionary dictionaryWithContentsOfURL:aURL];
		return [self binaryTreeDictionaryWithDictionary:aDictionary andComparator:comparator];
	}

	+(instancetype)binaryTreeDictionaryWithObjects:(const id[])objects
										   forKeys:(const id<NSCopying>[])keys
											 count:(NSUInteger)cnt
										comparator:(NSComparator)comparator {
		return [[PGBinaryTreeDictionary alloc] initWithObjects:objects forKeys:keys count:cnt comparator:comparator];
	}

#endif

@end
