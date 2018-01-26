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

NS_ASSUME_NONNULL_BEGIN

@interface NSString(PGString)

    /**************************************************************************************************//**
     * If the length of this string is zero (0) then this method returns a NULL value (nil), otherwise
     * this NSString object is returned.
     *
     * @return Either this NSString object or nil if this string is empty.
     */
    -(nullable NSString *)nullIfEmpty;

    /**************************************************************************************************//**
     * This method is the equivilent of calling [[self trim] nullIfEmpty]. Either NULL (nil) or a copy
     * of this NSString is always returned.
     *
     * @return Either a copy of this NSString object or nil if this string is empty.
     */
    -(nullable NSString *)nullIfTrimEmpty;

    -(NSUInteger)indexOfCharacter:(unichar)c;

    -(NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)options from:(NSUInteger)from;

    /**************************************************************************************************//**
     * This method functions like the componentsSeparatedByString: method except that it allows you to
     * specify a limit to the number of components that are created. If the limit is zero (0) then an
     * instance of an empty NSArray will be returned. If the limit is greater than zero (0) then an
     * instance of NSArray will be returned with at most that number of components. The last element
     * in the instance of NSArray will be the remainder of the string.
     *
     * @param separator The separator string.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @return An NSArray object containing substrings from the receiver that have been divided by separator.
     */
    -(NSArray<NSString *> *)componentsSeparatedByString:(NSString *)separator limit:(NSUInteger)limit;

    /**************************************************************************************************//**
     * If this string's length is greater than the 'maxLength' provided then this method returns a copy
     * of this string truncated to the 'maxLength'. Otherwise this string is returned - not a copy.
     *
     * @param maxLength the max length.
     * @return either this string or a copy that is truncated to the 'maxLength'.
     */
    -(NSString *)limitLength:(NSUInteger)maxLength;

    /**************************************************************************************************//**
     * Returns a copy of this string with the leading and trailing whitespace and control characters
     * removed. This method always returns a copy of this string even if nothing had to be removed.
     *
     * @return a copy of this string with any leading or trailing whitespace and control characters removed.
     */
    -(NSString *)trim;

    -(void)drawDeadCentered:(NSRect)textRect fontName:(NSString *)fontName fontSize:(NSFloat)fontSize fontColor:(NSColor *)fontColor;

    -(void)drawDeadCentered:(NSRect)textRect font:(NSFont *)font fontColor:(NSColor *)fontColor;

    -(void)drawDeadCentered:(NSRect)textRect fontAttributes:(NSDictionary *)fontAttribs;

@end

NS_ASSUME_NONNULL_END

#endif // __Rubicon_NSString_PGString__H_
