/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSString(PGString).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/29/16 8:17 PM
 * DESCRIPTION:
 *
 * Copyright © 2016 Project Galen. All rights reserved.
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

#import "NSString+PGString.h"

typedef void (^EnumBlock)(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *end);

NS_INLINE NSRange PGRangeFromIndexes(NSUInteger loc1, NSUInteger loc2) {
    NSRange range;
    if(loc1 <= loc2) {
        range.location = loc1;
        range.length   = (loc2 - loc1);
    }
    else {
        range.location = loc2;
        range.length   = (loc1 - loc2);
    }
    return range;
}

NS_INLINE NSException *__nullable PGValidateRange(NSString *string, NSRange range) {
    if(range.location < string.length && NSMaxRange(range) < string.length) return nil;
    NSString *r = PGFormat(@"Range {%lu, %lu} out of bounds; string length %lu", range.location, range.length, string.length);
    return [NSException exceptionWithName:NSRangeException reason:r userInfo:nil];
}

@implementation NSString(PGString)

    /**************************************************************************************************//**
     * If the length of this string is zero (0) then this method returns a NULL value (nil), otherwise
     * this NSString object is returned.
     *
     * @return Either this NSString object or nil if this string is empty.
     */
    -(NSString *)nullIfEmpty {
        return (self.length ? self : nil);
    }

    /**************************************************************************************************//**
     * This method is the equivilent of calling [[self trim] nullIfEmpty]. Either NULL (nil) or a copy
     * of this NSString is always returned.
     *
     * @return Either a copy of this NSString object or nil if this string is empty.
     */
    -(NSString *)nullIfTrimEmpty {
        return [[self trim] nullIfEmpty];
    }

    -(NSUInteger)indexOfCharacter:(unichar)c {
        return [self indexOfCharacter:c inRange:NSMakeRange(0, self.length)];
    }

    -(NSUInteger)indexOfCharacter:(unichar)c from:(NSUInteger)startIndex {
        return [self indexOfCharacter:c inRange:PGRangeFromIndexes(startIndex, self.length)];
    }

    -(NSUInteger)indexOfCharacter:(unichar)c to:(NSUInteger)endIndex {
        return [self indexOfCharacter:c inRange:NSMakeRange(0, endIndex)];
    }

    -(NSUInteger)indexOfCharacter:(unichar)c inRange:(NSRange)range {
        for(NSUInteger i = range.location, j = NSMaxRange(range); i < j; i++) {
            if(c == [self characterAtIndex:i]) return i;
        }

        return NSNotFound;
    }

    -(BOOL)isEqualToString:(nullable NSString *)string from:(NSUInteger)fromIndex {
        return [self isEqualToString:string inRange:PGRangeFromIndexes(fromIndex, self.length)];
    }

    -(BOOL)isEqualToString:(nullable NSString *)string to:(NSUInteger)toIndex {
        return [self isEqualToString:string inRange:NSMakeRange(0, toIndex)];
    }

    -(BOOL)isEqualToString:(nullable NSString *)string inRange:(NSRange)range {
        NSException *e = PGValidateRange(self, range);
        if(e) @throw e;
        if(string == nil) return NO;
        range = [self rangeOfComposedCharacterSequencesForRange:range];
        if(string.length != range.length) return NO;
        for(NSUInteger i = 0; i < range.length; i++) {
            if([self characterAtIndex:range.location++] != [string characterAtIndex:i]) return NO;
        }
        return YES;
    }

    -(BOOL)isEqualToString:(NSString *)string stringRange:(NSRange)stringRange receiverRange:(NSRange)receiverRange {
        NSException *e = PGValidateRange(self, receiverRange);
        if(e) @throw e;
        e = PGValidateRange(string, stringRange);
        if(e) @throw e;

        if(receiverRange.length != stringRange.length) return NO;

        while(receiverRange.length) {
            unichar c1 = [self characterAtIndex:receiverRange.location++];
            unichar c2 = [string characterAtIndex:stringRange.location++];
            if(c1 != c2) return NO;
            receiverRange.length--;
        }

        return YES;
    }

    -(NSRange)rangeOfString:(NSString *)searchString from:(NSUInteger)fromIndex {
        return [self rangeOfString:searchString options:0 range:PGRangeFromIndexes(fromIndex, self.length)];
    }

    -(NSRange)rangeOfString:(NSString *)searchString to:(NSUInteger)toIndex {
        return [self rangeOfString:searchString options:0 range:NSMakeRange(0, toIndex)];
    }

    -(NSRange)rangeOfString:(NSString *)searchString range:(NSRange)range {
        return [self rangeOfString:searchString options:0 range:range];
    }

    -(NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)options from:(NSUInteger)from {
        return [self rangeOfString:searchString options:options range:PGRangeFromIndexes(from, self.length)];
    }

    -(NSRange)rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)options to:(NSUInteger)to {
        return [self rangeOfString:searchString options:options range:NSMakeRange(0, to)];
    }

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
    -(NSArray<NSString *> *)componentsSeparatedByString:(NSString *)separator limit:(NSUInteger)limit {
        /*
         * If the limit is zero then return an empty array.
         */
        if(limit) {
            /*
             * If the limit is only 1, the separator is empty, or the separator is longer
             * than this string then return a copy of this string as the only element in the array.
             */
            if((limit > 1) && (separator.length > 0) && (separator.length < self.length)) {
                NSRange remaining  = NSMakeRange(0, self.length);
                NSRange foundRange = [self rangeOfString:separator options:0 range:remaining];

                /*
                 * If instances of the separator do not exist in the first place then
                 * fall thru and return a copy of this string as the only element in
                 * the array. Otherwise continue into the body of the IF statement.
                 */
                if(foundRange.location != NSNotFound) {
                    /*
                     * At this point we know two things:
                     *
                     * 1) the limit is at least 2
                     * 2) we found at least one instance of the separator
                     *
                     * So we know that the resulting array is going to have at least two elements.
                     */
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:limit];

                    do {
                        [array addObject:[self substringWithRange:PGRangeFromIndexes(remaining.location, foundRange.location)]];
                        remaining = PGRangeFromIndexes(NSMaxRange(foundRange), self.length);
                        /*
                         * See if we're done...
                         */
                        if(limit < 3) break;
                        /*
                         * We're not done so keep going until no more found...
                         */
                        limit--;
                        foundRange = [self rangeOfString:separator options:0 range:remaining];
                    } while(foundRange.location != NSNotFound);

                    [array addObject:[self substringWithRange:remaining]];
                    return array;
                }
            }
            return @[[self copy]];
        }
        return @[];
    }

    /**************************************************************************************************//**
     * If this string's length is greater than the 'maxLength' provided then this method returns a copy
     * of this string truncated to the 'maxLength'. Otherwise this string is returned - not a copy.
     *
     * @param maxLength the max length.
     * @return either this string or a copy that is truncated to the 'maxLength'.
     */
    -(NSString *)limitLength:(NSUInteger)maxLength {
        return ((self.length > maxLength) ? [self substringWithRange:NSMakeRange(0, maxLength)] : self);
    }

    /**************************************************************************************************//**
     * Returns a copy of this string with the leading and trailing whitespace and control characters
     * removed. This method always returns a copy of this string even if nothing had to be removed.
     *
     * @return a copy of this string with any leading or trailing whitespace and control characters removed.
     */
    -(NSString *)trim {
        NSString *re1 = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *re2 = [re1 stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
        return ((self == re2) ? [self copy] : re2);
    }

    -(NSDictionary *)makeAlignmentCentered:(NSDictionary *)fontAttribs {
        if(fontAttribs) {
            NSMutableParagraphStyle *style = fontAttribs[NSParagraphStyleAttributeName];

            if(style == nil) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:fontAttribs];
                dict[NSParagraphStyleAttributeName] = (style = [[NSMutableParagraphStyle alloc] init]);
                fontAttribs = [NSDictionary dictionaryWithDictionary:dict];
            }

#if defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 101200)
            style.alignment = NSCenterTextAlignment;
#else
            style.alignment = NSTextAlignmentCenter;
#endif
        }
        else {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
#if defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 101200)
            style.alignment = NSCenterTextAlignment;
#else
            style.alignment = NSTextAlignmentCenter;
#endif
            fontAttribs = @{
                NSFontAttributeName           :[NSFont systemFontOfSize:13], // Font
                NSForegroundColorAttributeName:[NSColor blackColor],         // Color
                NSParagraphStyleAttributeName :style                         // Style
            };
        }

        return fontAttribs;
    }

    -(void)drawDeadCentered:(NSRect)textRect fontName:(NSString *)fontName fontSize:(NSFloat)fontSize fontColor:(NSColor *)fontColor {
        NSFont *aFont = (fontName.length ? [NSFont fontWithName:fontName size:fontSize] : [NSFont systemFontOfSize:fontSize]);
        [self drawDeadCentered:textRect font:aFont fontColor:fontColor];
    }

    -(void)drawDeadCentered:(NSRect)textRect font:(NSFont *)font fontColor:(NSColor *)fontColor {
        NSDictionary *textFontAttributes = @{
            NSFontAttributeName           :(font ? font : [NSFont systemFontOfSize:13]),  // Draw Font
            NSForegroundColorAttributeName:(fontColor ? fontColor : [NSColor blackColor]) // Draw Color
        };

        [self drawDeadCentered:textRect fontAttributes:textFontAttributes];
    }

    -(void)drawDeadCentered:(NSRect)textRect fontAttributes:(NSDictionary *)fontAttribs {
        [self _drawDeadCentered:textRect fontAttribs:[self makeAlignmentCentered:fontAttribs]];
    }

    -(void)_drawDeadCentered:(NSRect)textRect fontAttribs:(NSDictionary *)fontAttribs {
        NSFont  *textFont  = fontAttribs[NSFontAttributeName];
        NSFloat textHeight = ceil(NSHeight([self boundingRectWithSize:textRect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttribs]));
        NSRect  textRect2  = NSMakeRect(NSMinX(textRect), ceil(NSMinY(textRect) + (NSHeight(textRect) - textHeight) / 2), NSWidth(textRect), textHeight);
        double  offset     = ceil(0 - textFont.descender - (textFont.ascender - textFont.capHeight) / 2.0);

        [NSGraphicsContext saveGraphicsState];

        if([NSGraphicsContext currentContext].isFlipped) {
            offset *= -1;
        }

        NSRectClip(textRect);
        [self drawInRect:NSOffsetRect(textRect2, 0, offset) withAttributes:fontAttribs];
        [NSGraphicsContext restoreGraphicsState];
    }

@end
