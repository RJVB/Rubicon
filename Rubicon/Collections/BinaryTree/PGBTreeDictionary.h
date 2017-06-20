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

#import <Cocoa/Cocoa.h>

@interface PGBTreeDictionary : NSDictionary

    -(instancetype)init;

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt;

    -(instancetype)initWithObject:(const id)object forKey:(const id<NSCopying>)key;

    -(instancetype)initWithCoder:(NSCoder *)coder;

    -(instancetype)initWithContentsOfFile:(NSString *)path;

    -(instancetype)initWithContentsOfURL:(NSURL *)url;

    -(id)objectForKey:(id)aKey;

    -(NSEnumerator *)keyEnumerator;

@end

@interface PGBTreeMutableDictionary : NSMutableDictionary

    -(instancetype)init;

    -(instancetype)initWithCapacity:(NSUInteger)numItems;

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt;

    -(instancetype)initWithObject:(const id)object forKey:(const id<NSCopying>)key;

    -(instancetype)initWithCoder:(NSCoder *)coder;

    -(instancetype)initWithContentsOfFile:(NSString *)path;

    -(instancetype)initWithContentsOfURL:(NSURL *)url;

    -(id)objectForKey:(id)aKey;

    -(NSEnumerator *)keyEnumerator;

    -(void)removeObjectForKey:(id)aKey;

    -(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;

    -(void)removeAllObjects;
@end

#endif //__Rubicon_PGBTreeDictionary_H_
