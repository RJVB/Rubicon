/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSize.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/2/17 7:10 AM
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

#ifndef __Rubicon_PGSize_H_
#define __Rubicon_PGSize_H_

#import <Cocoa/Cocoa.h>

@class PGISize;

@interface PGSize : NSObject<NSCopying>

	@property(nonatomic, readonly) CGFloat width;
	@property(nonatomic, readonly) CGFloat height;

	-(instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height;

	-(id)copyWithZone:(NSZone *)zone;

	-(BOOL)isEqualToWidth:(CGFloat)other height:(CGFloat)height;

	-(BOOL)isEqual:(id)other;

	-(BOOL)isEqualToSize:(PGSize *)size;

	-(BOOL)isEqualToNSSize:(NSSize)other;

	-(BOOL)isEqualToPGISize:(PGISize *)other;

	-(NSSize)toNSSize;

	-(PGISize *)toPGISize;

	-(NSUInteger)hash;

	-(NSString *)description;

	+(instancetype)sizeWithWidth:(CGFloat)width height:(CGFloat)height;

	+(instancetype)sizeWithNSSize:(NSSize)size;

	+(instancetype)sizeWithPGISize:(PGISize *)size;

@end

#endif //__Rubicon_PGSize_H_
