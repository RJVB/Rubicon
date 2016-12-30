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

	-(void)drawDeadCentered:(NSRect)textRect fontName:(NSString *)fontName fontSize:(CGFloat)fontSize fontColor:(NSColor *)fontColor {
		NSDictionary *textFontAttributes = @{
				NSFontAttributeName           :(fontName.length ? [NSFont fontWithName:fontName size:fontSize] : [NSFont systemFontOfSize:fontSize]),
				NSForegroundColorAttributeName:(fontColor ? fontColor : [NSColor blackColor]),
		};

		[self drawDeadCentered:textRect fontAttributes:textFontAttributes];
	}

	-(void)drawDeadCentered:(NSRect)textRect fontAttributes:(NSDictionary *)fontAttribs {
		NSMutableParagraphStyle *style = fontAttribs[NSParagraphStyleAttributeName];

		if(style == nil) {
			style = [[NSMutableParagraphStyle alloc] init];

			if(fontAttribs == nil) {
				fontAttribs = @{
						NSFontAttributeName          :[NSFont systemFontOfSize:13], NSForegroundColorAttributeName:[NSColor blackColor],
						NSParagraphStyleAttributeName:style
				};
			}
			else {
				NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:fontAttribs];
				dict[NSParagraphStyleAttributeName] = style;
				fontAttribs = dict;
			}
		}

		style.alignment = NSCenterTextAlignment;

		CGFloat textHeight = NSHeight([self boundingRectWithSize:textRect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttribs]);
		NSRect  textRect2  = NSMakeRect(NSMinX(textRect), NSMinY(textRect) + (NSHeight(textRect) - textHeight) / 2, NSWidth(textRect), textHeight);
		[NSGraphicsContext saveGraphicsState];
		NSRectClip(textRect);
		[self drawInRect:NSOffsetRect(textRect2, 0, 0) withAttributes:fontAttribs];
		[NSGraphicsContext restoreGraphicsState];
	}

@end
