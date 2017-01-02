/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGISize.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/1/17 1:26 PM
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

#ifndef __Rubicon_PGISize_H_
#define __Rubicon_PGISize_H_

#import <Cocoa/Cocoa.h>

@interface PGISize : NSObject<NSCopying>

	@property(nonatomic, readonly) NSInteger width;
	@property(nonatomic, readonly) NSInteger height;

	-(instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height;

	+(instancetype)sizeWithNSSize:(NSSize)size;

	-(id)copyWithZone:(NSZone *)zone;

	-(NSString *)description;

	-(BOOL)isEqual:(id)other;

	-(BOOL)isEqualToSize:(PGISize *)size;

	-(NSUInteger)hash;

	-(NSSize)toNSSize;

	+(instancetype)sizeWithWidth:(NSInteger)width height:(NSInteger)height;

@end

#endif //__Rubicon_PGISize_H_
