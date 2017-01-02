/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSDividedRectResults.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/2/17 8:40 AM
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

#ifndef __Rubicon_NSDividedRectResults_H_
#define __Rubicon_NSDividedRectResults_H_

#import <Cocoa/Cocoa.h>

@class PGRect;

@interface PGDivideRectResults : NSObject

	@property(nonatomic, copy) PGRect *slice;
	@property(nonatomic, copy) PGRect *remainder;

	-(instancetype)initWithSlice:(PGRect *)slice remainder:(PGRect *)remainder;

	-(BOOL)isEqual:(id)other;

	-(BOOL)isEqualToResults:(PGDivideRectResults *)results;

	-(NSUInteger)hash;

	+(instancetype)resultsWithSlice:(PGRect *)slice remainder:(PGRect *)remainder;

@end

#endif //__Rubicon_NSDividedRectResults_H_
