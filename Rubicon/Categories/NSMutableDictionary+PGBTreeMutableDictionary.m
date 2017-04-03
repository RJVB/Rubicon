/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSMutableDictionary(PGBTreeMutableDictionary).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/3/17 12:37 PM
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

#import "NSMutableDictionary+PGBTreeMutableDictionary.h"
#import "PGBTreeDictionary.h"

@implementation NSMutableDictionary(PGBTreeMutableDictionary)

	+(PGBTreeMutableDictionary *)btreeDictionary {
		return [[PGBTreeMutableDictionary alloc] init];
	}

	+(PGBTreeMutableDictionary *)btreeDictionaryWithDictionary:(NSDictionary *)dict {
		return [[PGBTreeMutableDictionary alloc] initWithDictionary:dict];
	}

	+(PGBTreeMutableDictionary *)btreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey {
		return [[PGBTreeMutableDictionary alloc] initWithObject:anObject forKey:aKey];
	}

	+(PGBTreeMutableDictionary *)btreeDictionaryWithCoder:(NSCoder *)coder {
		return [[PGBTreeMutableDictionary alloc] initWithCoder:coder];
	}

	+(PGBTreeMutableDictionary *)btreeDictionaryWithContentsOfFile:(NSString *)path {
		return [[PGBTreeMutableDictionary alloc] initWithContentsOfFile:path];
	}

	+(PGBTreeMutableDictionary *)btreeDictionaryWithContentsOfURL:(NSURL *)url {
		return [[PGBTreeMutableDictionary alloc] initWithContentsOfURL:url];
	}

@end
