/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGIRect.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/1/17 1:32 PM
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

#ifndef __Rubicon_PGIRect_H_
#define __Rubicon_PGIRect_H_

#import <Cocoa/Cocoa.h>

@class PGIPoint;
@class PGISize;

@interface PGIRect : NSObject<NSCopying>

	@property(nonatomic, readonly) PGIPoint  *origin;
	@property(nonatomic, readonly) PGISize   *size;
	@property(nonatomic, readonly) NSInteger maxX;
	@property(nonatomic, readonly) NSInteger midX;
	@property(nonatomic, readonly) NSInteger minX;
	@property(nonatomic, readonly) NSInteger maxY;
	@property(nonatomic, readonly) NSInteger midY;
	@property(nonatomic, readonly) NSInteger minY;
	@property(nonatomic, readonly) NSInteger width;
	@property(nonatomic, readonly) NSInteger height;

	-(instancetype)initWithX:(NSInteger)x Y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height;

	-(instancetype)initWithOrigin:(PGIPoint *)origin size:(PGISize *)size;

	-(id)copyWithZone:(NSZone *)zone;

	-(BOOL)isEqual:(id)other;

	-(BOOL)isEqualToRect:(PGIRect *)other;

	-(NSUInteger)hash;

	-(NSRect)toNSRect;

	-(instancetype)offsetByX:(NSInteger)dx Y:(NSInteger)dy;

	-(instancetype)insetByX:(NSInteger)dx Y:(NSInteger)dy;

	-(instancetype)unionWithRect:(PGIRect *)rect;

	-(instancetype)intersectionWithRect:(PGIRect *)rect;

	-(BOOL)isEmpty;

	-(NSString *)description;

	+(instancetype)rectWithOrigin:(PGIPoint *)origin size:(PGISize *)size;

	+(instancetype)rectWithX:(NSInteger)x Y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height;

	+(instancetype)rectWithNSRect:(NSRect)rect;
@end

#endif //__Rubicon_PGIRect_H_
