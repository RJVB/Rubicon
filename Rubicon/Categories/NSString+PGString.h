/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSString(PGString).h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 12/29/16 8:17 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2016  Project Galen. All rights reserved.
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

#ifndef __Rubicon_NSString_PGString__H_
#define __Rubicon_NSString_PGString__H_

#import <Rubicon/PGTools.h>

FOUNDATION_EXPORT const NSUInteger PGUNotFound;

NS_ASSUME_NONNULL_BEGIN

@interface NSString(PGString)

    -(nullable NSString *)nullIfEmpty;

    -(nullable NSString *)nullIfTrimEmpty;

    -(NSUInteger)indexOfCharacter:(unichar)c;

    -(NSString *)limitLength:(NSUInteger)maxLength;

    -(NSString *)trim;

    -(void)drawDeadCentered:(NSRect)textRect fontName:(NSString *)fontName fontSize:(NSFloat)fontSize fontColor:(NSColor *)fontColor;

    -(void)drawDeadCentered:(NSRect)textRect font:(NSFont *)font fontColor:(NSColor *)fontColor;

    -(void)drawDeadCentered:(NSRect)textRect fontAttributes:(NSDictionary *)fontAttribs;

@end

NS_ASSUME_NONNULL_END

#endif // __Rubicon_NSString_PGString__H_
