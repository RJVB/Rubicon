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
 *//************************************************************************/
#ifndef __Rubicon_NSString_PGString__H_
#define __Rubicon_NSString_PGString__H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

#define PG_DEFAULT_SYS_FONT_SIZE  (13)
#define PG_DEFAULT_SYS_FONT_COLOR (NSColor.blackColor)

typedef BOOL (^PGCharEnumBlock)(unichar c, unichar *dc, NSRange range, BOOL composed, NSString *_Nullable before, NSString *_Nullable after);

typedef NSString *_Nullable (^PGRegexFilterBlock)(NSString *str, NSString *sub, NSUInteger num, NSTextCheckingResult *res, NSString *_Nullable last, BOOL *stop);

@interface NSString(PGString)

    -(BOOL)enumerateOverCharactersWithBlock:(NS_NOESCAPE PGCharEnumBlock)enumBlock range:(NSRange)range;

    -(NSString *)stringByFilteringWithRegexPattern:(NSString *)pattern
                                      regexOptions:(NSRegularExpressionOptions)regexOptions
                                      matchOptions:(NSMatchingOptions)matchOptions
                                  replacementBlock:(NS_NOESCAPE PGRegexFilterBlock)replBlock
                                             error:(NSError **)error;

    -(NSStrArray)getCharactersAsArrayOfStrings;

    -(NSString *)stringByEscapingChars:(NSString *)characters withEscapeChar:(unichar)escChar;

    -(NSString *)stringByEscapingChars:(NSString *)characters withEscape:(NSString *)escChar;

    +(instancetype)stringWithCharacter:(unichar)character;

    -(BOOL)isEmpty;

    -(BOOL)notEmpty;

    -(NSRange)range;

    -(NSString *)stringByReplacingControlChars;

    -(NSString *)stringByReplacingControlCharsAndSpcs;

    -(NSString *)stringByFrontPaddingToLength:(NSUInteger)len withString:(NSString *)str startingAtIndex:(NSUInteger)idx;

    -(NSString *)stringByCenteringInPaddingOfLength:(NSUInteger)len withString:(NSString *)str startingAtIndex:(NSUInteger)idx;

    /**
     * If the length of this string is zero (0) then this method returns a NULL value (nil), otherwise
     * this NSString object is returned.
     *
     * @return Either this NSString object or nil if this string is empty.
     */
    -(nullable NSString *)nullIfEmpty;

    /**
     * This method is the equivilent of calling [[self trim] nullIfEmpty]. Either NULL (nil) or a copy
     * of this NSString is always returned.
     *
     * @return Either a copy of this NSString object or nil if this string is empty.
     */
    -(nullable NSString *)nullIfTrimEmpty;

    /**
     * This method accepts only a single UTF-16 code point as input and searchs for the first instance
     * of that code point in this entire string. If you would rather search for a composed character
     * sequence (such as an emoji 🤯) then instead use the rangeOfString: method and pass the composed
     * character sequence as a string.
     *
     * This method simply calls:
     *     [self indexOfCharacter:c inRange:self.range]
     *
     * @param c the UTF-16 unicode code point to search for.
     * @return the index of the first instance of the character in this string or NSNotFound.
     */
    -(NSUInteger)indexOfCharacter:(unichar)c;

    /**
     * This method accepts only a single UTF-16 code point as input and searchs for the first instance
     * of that code point in this string beginning at 'startIndex'. If you would rather search for a
     * composed character sequence (such as an emoji 🤯) then instead use the rangeOfString:from: method
     * and pass the composed character sequence as a string.
     *
     * This method simply calls:
     *     [self indexOfCharacter:c inRange:NSMakeRange(startIndex, self.length - startIndex)]
     *
     * @param c the UTF-16 unicode code point to search for.
     * @param startIndex the position in this string to begin searching at.
     * @return the index of the first instance of the character in this string or NSNotFound.
     */
    -(NSUInteger)indexOfCharacter:(unichar)c from:(NSUInteger)startIndex;

    /**
     * This method accepts only a single UTF-16 code point as input and searchs for the first instance
     * of that code point in this string up to just before 'toIndex'. If you would rather search for a
     * composed character sequence (such as an emoji 🤯) then instead use the rangeOfString:to: method and
     * pass the composed character sequence as a string.
     *
     * This method simply calls:
     *     [self indexOfCharacter:c inRange:NSMakeRange(0, toIndex)]
     *
     * @param c the UTF-16 unicode code point to search for.
     * @param endIndex the position in this string to stop searching before.
     * @return the index of the first instance of the character in this string or NSNotFound.
     */
    -(NSUInteger)indexOfCharacter:(unichar)c to:(NSUInteger)endIndex;

    /**
     * This method accepts only a single UTF-16 code point as input and searchs for the first instance
     * of that code point in this string within the supplied range. If you would rather search for a
     * composed character sequence (such as an emoji 🤯) then instead use the rangeOfString:range: method
     * and pass the composed character sequence as a string.
     *
     * @param c the UTF-16 unicode code point to search for.
     * @param range the range of this string to search over.
     * @return the index of the first instance of the character in this string or NSNotFound.
     */
    -(NSUInteger)indexOfCharacter:(unichar)c inRange:(NSRange)range;

    -(BOOL)isEqualToString:(nullable NSString *)other from:(NSUInteger)fromIndex;

    -(BOOL)isEqualToString:(nullable NSString *)other to:(NSUInteger)toIndex;

    /**
     * This method exists to allow you to compare a substring of this string to another string without
     * having to actually create a separate NSString object to begin with. It replaces a call that would
     * look something like this:
     *     [aString isEqualToString:[otherString substringWithRange:aRange]]
     *
     * Instead you can now do something like the following and not actually create a new object:
     *     [otherString isEqualToString:aString inRange:aRange]
     *
     * @param other the other string.
     * @param range the range within this string to compare the other string to.
     * @return YES if the range of this string equals the other string.
     */
    -(BOOL)isEqualToString:(nullable NSString *)other inRange:(NSRange)range;

    -(BOOL)isEqualToString:(NSString *)other stringRange:(NSRange)stringRange receiverRange:(NSRange)receiverRange;

    -(NSRange)rangeOfString:(NSString *)searchString from:(NSUInteger)fromIndex;

    -(NSRange)rangeOfString:(NSString *)searchString to:(NSUInteger)toIndex;

    -(NSRange)rangeOfString:(NSString *)searchString range:(NSRange)range;

    -(NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)options from:(NSUInteger)from;

    -(NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)options to:(NSUInteger)to;

    -(NSStrArray)componentsSeparatedByString:(NSString *)separator limit:(NSUInteger)limit;

    /**
     * This method functions like the componentsSeparatedByString: method except that it allows you to
     * specify a limit to the number of components that are created. If the limit is zero (0) then no
     * limit is assumed. If the limit is greater than zero (0) then an instance of NSArray will be
     * returned with at most that number of components. The last element in the instance of NSArray will
     * be the remainder of the string.
     *
     * @param separator The separator string.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @return An NSArray object containing substrings from the receiver that have been divided by separator.
     */
    -(NSStrArray)componentsSeparatedByString:(NSString *)separator limit:(NSUInteger)limit keepSeparator:(BOOL)keepSeparator;

    /**
     * If this string's length is greater than the 'maxLength' provided then this method returns a copy
     * of this string truncated to the 'maxLength'. Otherwise this string is returned - not a copy.
     *
     * @param maxLength the max length.
     * @return either this string or a copy that is truncated to the 'maxLength'.
     */
    -(NSString *)limitLength:(NSUInteger)maxLength;

    /**
     * Returns a copy of this string with the leading and trailing whitespace and control characters
     * removed. This method always returns a copy of this string even if nothing had to be removed.
     *
     * @return a copy of this string with any leading or trailing whitespace and control characters removed.
     */
    -(NSString *)trim;

    /**
     * If this string contains any leading or trailing whitespace or control characters then this method
     * returns a copy of this string with the leading and trailing whitespace and control characters
     * removed. This method will return this string (not a copy) if there were no whitespace or control
     * characters to remove.
     *
     * @return this string or a copy of this string if any leading or trailing whitespace and control
     *         characters were removed.
     */
    -(NSString *)trimNoCopy;

    -(void)drawDeadCentered:(NSRect)clipRect fontName:(NSString *)fontName size:(NSFloat)fontSize color:(NSColor *)fontColor;

    -(void)drawDeadCentered:(NSRect)clipRect font:(NSFont *)font color:(NSColor *)fontColor;

    -(void)drawDeadCentered:(NSRect)clipRect fontAttributes:(NSDictionary *)attribs;

    +(instancetype)stringWithArguments:(va_list)args;

    /**
         * This method is similar in function to componentsSeparatedByString:limit:keepSeparator: except that
         * pattern is a string that contains a Regular Expression that will be searched for instead of a
         * simple string. NSRegularExpression is used.
         *
         * @param pattern the regular expression pattern.
         * @param limit The maximum number of elements that the returned NSArray object will contain.
         * @param options The options for the regular expression. These are the same as for NSRegularExpression.
         * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
         * @param error if the regular expression contained an error then it will be returned in this field.
         * @return An NSArray object containing substrings from the receiver that have been divided by
         *         separator. If there was an error in the regular expression then a NULL value will be
         *         returned.
         */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern
                                        limit:(NSUInteger)limit
                                      options:(NSRegularExpressionOptions)options
                                keepSeparator:(BOOL)keepSeparator
                                        error:(NSError **)error;

    -(NSString *)substringFrom:(NSUInteger)idx1 to:(NSUInteger)idx2;

    -(BOOL)enumerateOverCharactersWithBlock:(PGCharEnumBlock)enumBlock;

    /**
         * Convienience method for:
         *           [string componentsSeparatedByPattern:pattern limit:0 options:0 keepSeparator:NO error:nil]
         *
         * @param pattern the regular expression pattern.
         * @return An NSArray object containing substrings from the receiver that have been divided by
         *         separator. If there was an error in the regular expression then a NULL value will be
         *         returned.
         */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:0 options:0 keepSeparator:NO error:error]
     *
     * @param pattern the regular expression pattern.
     * @param error if the regular expression contained an error then it will be returned in this field.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern error:(NSError **)error;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:NO error:nil]
     *
     * @param pattern the regular expression pattern.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:0 options:options keepSeparator:NO error:nil]
     *
     * @param pattern the regular expression pattern.
     * @param options The options for the regular expression. These are the same as for NSRegularExpression.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:0 options:options keepSeparator:NO error:error]
     *
     * @param pattern the regular expression pattern.
     * @param options The options for the regular expression. These are the same as for NSRegularExpression.
     * @param error if the regular expression contained an error then it will be returned in this field.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:limit options:options keepSeparator:NO error:nil]
     *
     * @param pattern the regular expression pattern.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @param options The options for the regular expression. These are the same as for NSRegularExpression.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit options:(NSRegularExpressionOptions)options;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:NO error:error]
     *
     * @param pattern the regular expression pattern.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @param error if the regular expression contained an error then it will be returned in this field.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit error:(NSError **)error;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:0 options:0 keepSeparator:keepSeparator error:nil]
     *
     * @param pattern the regular expression pattern.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern keepSeparator:(BOOL)keepSeparator;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:0 options:0 keepSeparator:keepSeparator error:error]
     *
     * @param pattern the regular expression pattern.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @param error if the regular expression contained an error then it will be returned in this field.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern keepSeparator:(BOOL)keepSeparator error:(NSError **)error;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:keepSeparator error:nil]
     *
     * @param pattern the regular expression pattern.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit keepSeparator:(BOOL)keepSeparator;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:0 options:options keepSeparator:keepSeparator error:nil]
     *
     * @param pattern the regular expression pattern.
     * @param options The options for the regular expression. These are the same as for NSRegularExpression.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options keepSeparator:(BOOL)keepSeparator;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:0 options:options keepSeparator:keepSeparator error:error]
     *
     * @param pattern the regular expression pattern.
     * @param options The options for the regular expression. These are the same as for NSRegularExpression.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @param error if the regular expression contained an error then it will be returned in this field.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options keepSeparator:(BOOL)keepSeparator error:(NSError **)error;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:limit options:options keepSeparator:keepSeparator error:nil]
     *
     * @param pattern the regular expression pattern.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @param options The options for the regular expression. These are the same as for NSRegularExpression.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit options:(NSRegularExpressionOptions)options keepSeparator:(BOOL)keepSeparator;

    /**
     * Convienience method for:
     *      [string componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:keepSeparator error:error]
     *
     * @param pattern the regular expression pattern.
     * @param limit The maximum number of elements that the returned NSArray object will contain.
     * @param keepSeparator if 'YES' then the separator is preserved at the end of each substring.
     * @param error if the regular expression contained an error then it will be returned in this field.
     * @return An NSArray object containing substrings from the receiver that have been divided by
     *         separator. If there was an error in the regular expression then a NULL value will be
     *         returned.
     */
    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit keepSeparator:(BOOL)keepSeparator error:(NSError **)error;

    +(instancetype)stringWithStrings:(NSString *)firstString, ... NS_REQUIRES_NIL_TERMINATION;

    +(instancetype)stringWithBytes:(const NSByte *)bytes length:(NSUInteger)length;

    +(instancetype)stringWithBytes:(const NSByte *)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding;

@end

@interface NSMutableString(PGMutableString)

    -(void)appendCharacter:(unichar)ch;

@end

NS_ASSUME_NONNULL_END

#endif // __Rubicon_NSString_PGString__H_
