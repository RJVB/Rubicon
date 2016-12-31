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

@implementation NSString(PGString)

	-(NSString *)trim {
		return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
					  stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
	}

	-(NSDictionary *)makeAlignmentCentered:(NSDictionary *)fontAttribs {
		if(fontAttribs) {
			NSMutableParagraphStyle *style = fontAttribs[NSParagraphStyleAttributeName];

			if(style == nil) {
				NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:fontAttribs];
				dict[NSParagraphStyleAttributeName] = (style = [[NSMutableParagraphStyle alloc] init]);
				fontAttribs = [NSDictionary dictionaryWithDictionary:dict];
			}

			style.alignment = NSCenterTextAlignment;
		}
		else {
			NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
			style.alignment = NSCenterTextAlignment;
			fontAttribs = @{
					NSFontAttributeName           :[NSFont systemFontOfSize:13], // Font
					NSForegroundColorAttributeName:[NSColor blackColor],         // Color
					NSParagraphStyleAttributeName :style                         // Style
			};
		}

		return fontAttribs;
	}

	-(void)drawDeadCentered:(NSRect)textRect fontName:(NSString *)fontName fontSize:(CGFloat)fontSize fontColor:(NSColor *)fontColor {
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
		CGFloat textHeight = ceil(NSHeight([self boundingRectWithSize:textRect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttribs]));
		NSRect  textRect2  = NSMakeRect(NSMinX(textRect), ceil(NSMinY(textRect) + (NSHeight(textRect) - textHeight) / 2), NSWidth(textRect), textHeight);
		NSRect  textRect3  = NSOffsetRect(textRect2, 0, ceil(0 - textFont.descender - (textFont.ascender - textFont.capHeight) / 2.0));

		[NSGraphicsContext saveGraphicsState];
		NSRectClip(textRect);
		[self drawInRect:textRect3 withAttributes:fontAttribs];
		[NSGraphicsContext restoreGraphicsState];
	}

@end
