/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSMutableDictionary(PGBTreeMutableDictionary).h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 4/3/17 12:37 PM
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

#ifndef __Rubicon_NSMutableDictionary_PGBTreeMutableDictionary__H_
#define __Rubicon_NSMutableDictionary_PGBTreeMutableDictionary__H_

#import <Cocoa/Cocoa.h>

@class PGBTreeMutableDictionary;

@interface NSMutableDictionary(PGBTreeMutableDictionary)

    +(PGBTreeMutableDictionary *)btreeDictionary;

    +(PGBTreeMutableDictionary *)btreeDictionaryWithDictionary:(NSDictionary *)dict;

    +(PGBTreeMutableDictionary *)btreeDictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey;

    +(PGBTreeMutableDictionary *)btreeDictionaryWithCoder:(NSCoder *)coder;

    +(PGBTreeMutableDictionary *)btreeDictionaryWithContentsOfFile:(NSString *)path;

    +(PGBTreeMutableDictionary *)btreeDictionaryWithContentsOfURL:(NSURL *)url;

@end

#endif // __Rubicon_NSMutableDictionary_PGBTreeMutableDictionary__H_
