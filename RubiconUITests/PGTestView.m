/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTestView.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/30/16 1:35 PM
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

#import "PGTestView.h"
#import <Rubicon/Rubicon.h>

@implementation PGTestView {
	}

	@synthesize fontSize = _fontSize;

	-(instancetype)initWithFrame:(NSRect)frameRect {
		self = [super initWithFrame:frameRect];

		if(self) {
			self.fontSize = 40;
		}

		return self;
	}

	-(instancetype)initWithCoder:(NSCoder *)coder {
		self = [super initWithCoder:coder];

		if(self) {
			self.fontSize = 40;
		}

		return self;
	}

	-(void)displayRect:(NSRect)rect {
		[super displayRect:rect];
	}

	-(void)drawRect:(NSRect)dirtyRect {
		[super drawRect:dirtyRect];

		[NSGraphicsContext saveGraphicsState];
		NSBezierPath *bp       = [NSBezierPath bezierPath];
		CGFloat      midHeight = ceil((dirtyRect.size.height / 2.0) - 0.5);

		[bp moveToPoint:NSMakePoint(0, midHeight)];
		[bp lineToPoint:NSMakePoint(dirtyRect.size.width, midHeight)];
		[bp closePath];
		[bp setLineWidth:1.0];
		[NSColor.redColor setStroke];
		[NSColor.redColor setFill];
		[bp fill];
		[bp stroke];
		[NSGraphicsContext restoreGraphicsState];

		NSString *aString = @"Galen Rhodes gyjqp";
		[aString drawDeadCentered:dirtyRect fontName:@".HelveticaNeueDeskInterface-MediumP4" fontSize:self.fontSize fontColor:NSColor.blackColor];
	}

@end
