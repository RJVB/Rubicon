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

const NSUInteger PGUNotFound = NSUIntegerMax;

@implementation NSString(PGString)

    -(NSString *)nullIfEmpty {
        return (self.length ? self : nil);
    }

    -(NSString *)nullIfTrimEmpty {
        return [[self trim] nullIfEmpty];
    }

    -(NSUInteger)indexOfCharacter:(unichar)c {
        for(NSUInteger i = 0, j = self.length; i < j; i++) {
            if(c == [self characterAtIndex:i]) {
                return i;
            }
        }

        return PGUNotFound;
    }

    -(NSString *)limitLength:(NSUInteger)maxLength {
        return ((self.length > maxLength) ? [self substringWithRange:NSMakeRange(0, maxLength)] : self);
    }

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
