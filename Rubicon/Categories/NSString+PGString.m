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
 *//***************************************************************************/

#import "PGInternal.h"

#if defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 101200)
    #define PGTextAlignmentCenter NSCenterTextAlignment
#else
    #define PGTextAlignmentCenter NSTextAlignmentCenter
#endif

#define UNICHAR_CHLEN ((size_t)(4))

typedef void (^RegexEnumBlock)(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *stop);

typedef union {
    uint64_t foo;
    unichar  ch[UNICHAR_CHLEN];
}            UNICHAR_UNION;

NS_INLINE void fillCharBuffer(UNICHAR_UNION *buffer, NSString *string, NSRange range) {
    buffer->foo      = 0;
    for(NSUInteger k = 0, l = MIN(range.length, UNICHAR_CHLEN); k < l; k++) {
        buffer->ch[k] = [string characterAtIndex:(range.location + k)];
    }
}

NS_INLINE NSString *substringBetween(NSString *string, NSUInteger idxFrom, NSUInteger idxTo) {
    return ((idxFrom < idxTo) ? [string substringFrom:idxFrom to:idxTo] : nil);
}

@implementation NSString(PGString)

    -(BOOL)isEmpty {
        return (self.length == 0);
    }

    -(BOOL)notEmpty {
        return (self.length > 0);
    }

    -(NSRange)range {
        NSRange r = { .location = 0, .length = self.length };
        return r;
    }

    -(NSString *)_stringByReplacingControlChars:(BOOL)includeSpaces {
        if(self.notEmpty) {
            char *xstr = PGCleanStr(self.UTF8String ?: "", includeSpaces);
            if(xstr) return [[NSString alloc] initWithBytesNoCopy:xstr length:strlen(xstr) encoding:NSUTF8StringEncoding freeWhenDone:YES];
        }

        return @"";
    }

    -(NSString *)stringByReplacingControlChars {
        return [self _stringByReplacingControlChars:NO];
    }

    -(NSString *)stringByReplacingControlCharsAndSpcs {
        return [self _stringByReplacingControlChars:YES];
    }

    -(NSString *)stringByFrontPaddingToLength:(NSUInteger)len withString:(NSString *)str startingAtIndex:(NSUInteger)idx {
        NSUInteger slflen = self.length;

        if(slflen == len) return self;
        if(slflen > len) return [self substringWithRange:NSMakeRange(slflen - len, len)];

        NSUInteger      needed = (len - slflen);
        NSUInteger      slen   = str.length;
        NSMutableString *pad   = [NSMutableString stringWithCapacity:len];
        NSRange         r      = NSMakeRange(idx, MIN((slen - idx), needed));

        [pad appendString:[str substringWithRange:r]];
        NSUInteger padlen = pad.length;

        while((padlen + slen) < needed) {
            [pad appendString:str];
            padlen = pad.length;
        }

        if(padlen < needed) [pad appendString:[str substringWithRange:NSMakeRange(0, (needed - padlen))]];
        [pad appendString:self];
        return pad;
    }

    -(NSString *)stringByCenteringInPaddingOfLength:(NSUInteger)len withString:(NSString *)str startingAtIndex:(NSUInteger)idx {
        if(len == 0) return @"";

        NSUInteger slflen = self.length;
        NSUInteger padlen = str.length;

        if(slflen == len) return self;
        if(slflen > len) return [self substringWithRange:NSMakeRange(((slflen - len) / 2), len)];

        NSMutableString *res = [NSMutableString stringWithCapacity:len];
        NSRange         rng  = NSMakeRange(idx, MIN(len, (padlen - idx)));

        [res appendString:[str substringWithRange:rng]];
        NSUInteger reslen = res.length;

        while((reslen + padlen) < len) {
            [res appendString:str];
            reslen = res.length;
        }

        if(reslen < len) [res appendString:[str substringWithRange:NSMakeRange(0, (len - reslen))]];

        [res replaceCharactersInRange:NSMakeRange(((len - slflen) / 2), slflen) withString:self];
        return res;
    }

    /**
     * If the length of this string is zero (0) then this method returns a NULL value (nil), otherwise
     * this NSString object is returned.
     *
     * @return Either this NSString object or nil if this string is empty.
     */
    -(NSString *)nullIfEmpty {
        return (self.length ? self : nil);
    }

    /**
     * This method is the equivilent of calling [[self trim] nullIfEmpty]. Either NULL (nil) or a copy
     * of this NSString is always returned.
     *
     * @return Either a copy of this NSString object or nil if this string is empty.
     */
    -(NSString *)nullIfTrimEmpty {
        return [[self trimNoCopy] nullIfEmpty];
    }

    -(NSUInteger)indexOfCharacter:(unichar)c {
        return [self indexOfCharacter:c inRange:self.range];
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

    -(NSStrArray)componentsSeparatedByString:(NSString *)separator limit:(NSUInteger)limit {
        return [self componentsSeparatedByString:separator limit:limit keepSeparator:NO];
    }

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
    -(NSStrArray)componentsSeparatedByString:(NSString *)separator limit:(NSUInteger)limit keepSeparator:(BOOL)keepSeparator {
        if(limit == 0) limit = NSUIntegerMax; // zero means no limit.
        /*
         * If the limit is only one, the separator is empty, or the separator is longer
         * than this string then return a copy of this string as the only element in the array.
         */
        if((limit > 1) && (separator.notEmpty) && (separator.length < self.length)) {
            NSRange remaining  = self.range;
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
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:MIN(limit, 100)]; // Let's not get carried away...

                do {
                    NSUInteger endOfMatch = NSMaxRange(foundRange);
                    NSRange    itemRange  = PGRangeFromIndexes(remaining.location, (keepSeparator ? endOfMatch : foundRange.location));

                    [array addObject:[self substringWithRange:itemRange]];
                    remaining = PGRangeFromIndexes(endOfMatch, self.length);
                    /*
                     * See if we're done...
                     */
                    if(limit < 3) break;
                    /*
                     * We're not done so keep going until no more found...
                     */
                    limit--;
                    foundRange = [self rangeOfString:separator options:0 range:remaining];
                }
                while(foundRange.location != NSNotFound);

                [array addObject:[self substringWithRange:remaining]];
                return array;
            }
        }

        return @[ self.copy ];
    }

    /**
     * If this string's length is greater than the 'maxLength' provided then this method returns a copy
     * of this string truncated to the 'maxLength'. Otherwise this string is returned - not a copy.
     *
     * @param maxLength the max length.
     * @return either this string or a copy that is truncated to the 'maxLength'.
     */
    -(NSString *)limitLength:(NSUInteger)maxLength {
        return ((self.length > maxLength) ? [self substringWithRange:NSMakeRange(0, maxLength)] : self);
    }

    /**
     * Returns a copy of this string with the leading and trailing whitespace and control characters
     * removed. This method always returns a copy of this string even if nothing had to be removed.
     *
     * @return a copy of this string with any leading or trailing whitespace and control characters removed.
     */
    -(NSString *)trim {
        NSString *trimmed = self.trimNoCopy;
        return ((self == trimmed) ? [self copy] : trimmed);
    }

    /**
     * If this string contains any leading or trailing whitespace or control characters then this method
     * returns a copy of this string with the leading and trailing whitespace and control characters
     * removed. This method will return this string (not a copy) if there were no whitespace or control
     * characters to remove.
     *
     * @return this string or a copy of this string if any leading or trailing whitespace and control
     *         characters were removed.
     */
    -(NSString *)trimNoCopy {
        return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
    }

    -(NSDictionary *)makeAlignmentCentered:(NSDictionary *)fontAttribs {
        if(fontAttribs) {
            NSMutableParagraphStyle *style = fontAttribs[NSParagraphStyleAttributeName];

            if(style == nil) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:fontAttribs];
                dict[NSParagraphStyleAttributeName] = style = [NSMutableParagraphStyle new];
                fontAttribs = [NSDictionary dictionaryWithDictionary:dict];
            }

            style.alignment = PGTextAlignmentCenter;
        }
        else {
            fontAttribs = [self fontAttribsWithFont:nil color:nil alignment:PGTextAlignmentCenter];
        }

        return fontAttribs;
    }

    -(NSDictionary *)fontAttribsWithFont:(NSFont *)font color:(NSColor *)fontColor alignment:(NSTextAlignment)textAlignment {
        NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
        style.alignment = textAlignment;
        return @{
                NSFontAttributeName           : (font ? font : [NSFont systemFontOfSize:PG_DEFAULT_SYS_FONT_SIZE]), // Font
                NSForegroundColorAttributeName: (fontColor ? fontColor : PG_DEFAULT_SYS_FONT_COLOR),                // Color
                NSParagraphStyleAttributeName : style                                                               // Style
        };
    }

    -(NSFloat)calcYOffest:(NSDictionary *)attrs {
        NSFont *fnt = attrs[NSFontAttributeName];
        return (ceil(0 - fnt.descender - (fnt.ascender - fnt.capHeight) / 2.0) * (NSGraphicsContext.currentContext.isFlipped ? -1 : 1));
    }

    -(void)_drawDeadCentered:(NSRect)clipRect fontAttribs:(NSDictionary *)attribs {
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin;
        [NSGraphicsContext saveGraphicsState];

        CGSize  txsz = clipRect.size;
        NSFloat hght = ceil(NSHeight([self boundingRectWithSize:txsz options:opts attributes:attribs]));
        NSFloat posy = ceil(NSMinY(clipRect) + (NSHeight(clipRect) - hght) / 2);
        NSFloat offs = [self calcYOffest:attribs];

        NSRectClip(clipRect);
        [self drawInRect:NSOffsetRect(NSMakeRect(NSMinX(clipRect), posy, NSWidth(clipRect), hght), 0, offs) withAttributes:attribs];

        [NSGraphicsContext restoreGraphicsState];
    }

    -(void)drawDeadCentered:(NSRect)clipRect fontName:(NSString *)fontName size:(NSFloat)fontSize color:(NSColor *)fontColor {
        [self drawDeadCentered:clipRect font:(fontName.length ? [NSFont fontWithName:fontName size:fontSize] : [NSFont systemFontOfSize:fontSize]) color:fontColor];
    }

    -(void)drawDeadCentered:(NSRect)clipRect font:(NSFont *)font color:(NSColor *)fontColor {
        [self _drawDeadCentered:clipRect fontAttribs:[self fontAttribsWithFont:font color:fontColor alignment:PGTextAlignmentCenter]];
    }

    -(void)drawDeadCentered:(NSRect)clipRect fontAttributes:(NSDictionary *)attribs {
        [self _drawDeadCentered:clipRect fontAttribs:[self makeAlignmentCentered:attribs]];
    }

    +(instancetype)stringWithArguments:(va_list)args {
        NSMutableString *str = [NSMutableString new];
        NSObject        *obj = va_arg(args, NSObject *);

        while(obj) {
            [str appendString:[obj description]];
            obj = va_arg(args, NSObject *);
        }

        return [(NSString *)[[self class] alloc] initWithString:str];
    }

    +(instancetype)stringWithStrings:(NSString *)firstString, ... {
        NSString *secondString = @"";

        if(firstString) {
            va_list args;
            va_start(args, firstString);
            secondString = [self stringWithArguments:args];
            va_end(args);
        }

        return [(NSString *)[[self class] alloc] initWithFormat:@"%@%@", (firstString ?: @""), secondString];
    }

    +(instancetype)stringWithBytes:(const NSByte *)bytes length:(NSUInteger)length {
        return [self stringWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
    }

    +(instancetype)stringWithBytes:(const NSByte *)bytes length:(NSUInteger)length encoding:(NSStringEncoding)encoding {
        return ((bytes && length) ? [(NSString *)[[self class] alloc] initWithBytes:bytes length:length encoding:encoding] : [(NSString *)[[self class] alloc] init]);
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:0 keepSeparator:NO error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern error:(NSError **)error {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:0 keepSeparator:NO error:error];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit {
        return [self componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:NO error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:options keepSeparator:NO error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:options keepSeparator:NO error:error];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit options:(NSRegularExpressionOptions)options {
        return [self componentsSeparatedByPattern:pattern limit:limit options:options keepSeparator:NO error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit error:(NSError **)error {
        return [self componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:NO error:error];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern keepSeparator:(BOOL)keepSeparator {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:0 keepSeparator:keepSeparator error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern keepSeparator:(BOOL)keepSeparator error:(NSError **)error {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:0 keepSeparator:keepSeparator error:error];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit keepSeparator:(BOOL)keepSeparator {
        return [self componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:keepSeparator error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options keepSeparator:(BOOL)keepSeparator {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:options keepSeparator:keepSeparator error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options keepSeparator:(BOOL)keepSeparator error:(NSError **)error {
        return [self componentsSeparatedByPattern:pattern limit:NSUIntegerMax options:options keepSeparator:keepSeparator error:error];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit options:(NSRegularExpressionOptions)options keepSeparator:(BOOL)keepSeparator {
        return [self componentsSeparatedByPattern:pattern limit:limit options:options keepSeparator:keepSeparator error:nil];
    }

    -(NSStrArray)componentsSeparatedByPattern:(NSString *)pattern limit:(NSUInteger)limit keepSeparator:(BOOL)keepSeparator error:(NSError **)error {
        return [self componentsSeparatedByPattern:pattern limit:limit options:0 keepSeparator:keepSeparator error:error];
    }

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
                                        error:(NSError **)error {

        // If limit is zero then that means no limit.
        if(limit == 0) limit = NSUIntegerMax;

        // Make sure we actually have a pattern.
        if(self.notEmpty && pattern.notEmpty && (limit > 1)) {
            NSError             *err   = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&err];

            // Return any error set by the NSRegularExpression class.
            if(error) *error = err;

            // If the regex is null then return null to indicate there was an error.
            if(regex) {
                __block NSUInteger startingPoint = 0;
                NSUInteger         subLimit      = (limit - 1);
                NSMutableStrArray  array         = [NSMutableArray arrayWithCapacity:MIN(limit, 100)]; // Let's not get crazy!

                [regex enumerateMatchesInString:self options:0 range:self.range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    if(array.count < subLimit) { // Safety Check
                        NSRange    rng    = result.range;
                        NSUInteger rngend = NSMaxRange(rng);
                        NSRange    subrng = NSMakeRange(startingPoint, ((keepSeparator ? rngend : rng.location) - startingPoint));

                        [array addObject:[self substringWithRange:subrng]];
                        startingPoint = rngend;
                        if(array.count == subLimit) *stop = YES;
                    }
                    else {
                        *stop = YES;
                    }
                }];

                if(array.count < limit) {
                    NSUInteger loc = MIN(startingPoint, self.length);
                    NSUInteger len = (self.length - loc);
                    [array addObject:(len ? [self substringWithRange:NSMakeRange(loc, len)] : @"")];
                }

                return array;
            }

            return nil;
        }

        // If the limit is 1, there is no pattern, or our string is empty then just return a copy of ourselves.
        return @[ self.copy ];
    }

    -(NSString *)substringFrom:(NSUInteger)idx1 to:(NSUInteger)idx2 {
        return [self substringWithRange:PGRangeFromIndexes(idx1, idx2)];
    }

    -(BOOL)enumerateOverCharactersWithBlock:(PGCharEnumBlock)enumBlock {
        return [self enumerateOverCharactersWithBlock:enumBlock range:self.range];
    }

    -(BOOL)enumerateOverCharactersWithBlock:(PGCharEnumBlock __attribute__((noescape)))enumBlock range:(NSRange)range {
        if(range.length) {
            NSRange       i = [self rangeOfComposedCharacterSequencesForRange:range]; // Make sure we're not slicing composed character sequences.
            NSUInteger    j = i.location;
            NSUInteger    k = j;
            NSUInteger    l = NSMaxRange(i);
            UNICHAR_UNION m;

            while(k < l) {
                NSRange    n = [self rangeOfComposedCharacterSequenceAtIndex:k];
                NSUInteger o = n.location;
                NSUInteger p = n.length;

                k = (o + p);
                fillCharBuffer(&m, self, n);
                if(enumBlock(m.ch[0], m.ch, n, (p > 1), substringBetween(self, j, o), substringBetween(self, k, l))) return YES;
            }
        }

        return NO;
    }

    -(NSString *)stringByFilteringWithRegexPattern:(NSString *)pattern
                                      regexOptions:(NSRegularExpressionOptions)regexOptions
                                      matchOptions:(NSMatchingOptions)matchOptions replacementBlock:(PGRegexFilterBlock __attribute__((noescape)))replBlock
                                             error:(NSError **)error {
        NSError             *err   = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&err];

        PGSetReference(error, err);

        if(regex) {
            __block NSMutableString *str             = nil;
            __block NSString        *lastReplacement = nil;
            __block NSUInteger      prefixStartIndex = 0;
            __block NSUInteger      matchNumber      = 0;

            RegexEnumBlock enumBlock = ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                if((result != nil) && (result.resultType == NSTextCheckingTypeRegularExpression)) {
                    NSRange  range = result.range;
                    NSString *mstr = [self substringWithRange:range];

                    lastReplacement = replBlock(self, mstr, ++matchNumber, result, lastReplacement, stop);

                    if((lastReplacement != nil) && ![lastReplacement isEqualToString:mstr]) {
                        if(str == nil) str = [NSMutableString new];
                        [str appendString:[self substringFrom:prefixStartIndex to:range.location]];
                        [str appendString:lastReplacement];
                        prefixStartIndex = NSMaxRange(range);
                    }
                }
            };

            [regex enumerateMatchesInString:self options:matchOptions range:self.range usingBlock:enumBlock];

            if(str) {
                if(prefixStartIndex < self.length) [str appendString:[self substringFromIndex:prefixStartIndex]];
                return str;
            }
            else {
                return self;
            }
        }

        return nil;
    }

    -(NSStrArray)getCharactersAsArrayOfStrings {
        if(self.notEmpty) {
            NSMutableArray<NSString *> *array = [NSMutableArray new];

            for(NSUInteger i = 0, j = self.length; i < j;) {
                NSRange r = [self rangeOfComposedCharacterSequenceAtIndex:i];
                [array addObject:[self substringWithRange:r]];
                i = MAX(NSMaxRange(r), (i + 1)); // Make sure we're progressing...
            }

            return array;
        }

        return @[];
    }

    -(NSString *)stringByEscapingChars:(NSString *)characters withEscapeChar:(unichar)escChar {
        return [self stringByEscapingChars:characters withEscape:[NSString stringWithCharacter:escChar]];
    }

    NS_INLINE NSUInteger foo(NSMutableString *pattern, NSString *characters, NSString *prefix, NSUInteger index) {
        NSRange r = [characters rangeOfComposedCharacterSequenceAtIndex:index];
        [pattern appendString:prefix];
        [pattern appendString:[NSRegularExpression escapedPatternForString:[characters substringWithRange:r]]];
        return MAX(NSMaxRange(r), (index + 1));
    }

    -(NSString *)stringByEscapingChars:(NSString *)characters withEscape:(NSString *)escChar {
        NSUInteger cl = characters.length;

        if(cl && escChar.notEmpty) {
            NSString        *tempEscChar = [NSRegularExpression escapedTemplateForString:[escChar substringWithRange:[escChar rangeOfComposedCharacterSequenceAtIndex:0]]];
            NSString        *template    = [NSString stringWithFormat:@"%@$1", tempEscChar];
            NSMutableString *pattern     = [NSMutableString new];

            for(NSUInteger i = 0; i < cl;) {
                i = foo(pattern, characters, @"(", i);
                while(i < cl) i = foo(pattern, characters, @"|", i);
                [pattern appendString:@")"];
            }

            [[PGLogger sharedInstanceWithClass:self.class] debug:@" Pattern: \"%@\"", pattern];
            [[PGLogger sharedInstanceWithClass:self.class] debug:@"Template: \"%@\"", template];
            return [[NSRegularExpression regularExpressionWithPattern:pattern] stringByReplacingMatchesInString:self withTemplate:template];
        }

        return self;
    }

    +(instancetype)stringWithCharacter:(unichar)character {
        return [(NSString *)[[self class] alloc] initWithCharacters:&character length:1];
    }

@end

@implementation NSMutableString(PGMutableString)

    -(void)appendCharacter:(unichar)ch {
        [self appendString:[NSString stringWithCharacter:ch]];
    }

@end
