/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNodeView.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/1/17 11:17 AM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
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

#import "PGNodeView.h"

@implementation PGNodeView {
    }

    @synthesize rootNode = _rootNode;

    -(NSRect)minimumFrame {
        NSSize size = NSZeroSize; // (_rootNode ? _rootNode.drawSize : NSZeroSize);
        return NSMakeRect(0, 0, (size.width + 20.0), (size.height + 20.0));
    }

    -(NSRect)desiredFrame {
        NSRect nframe = self.minimumFrame;
        NSRect aframe = self.superview.frame;
        NSRect pframe = NSOffsetRect(aframe, 0 - NSMinX(aframe), 0 - NSMinY(aframe));
        return NSMakeRect(0, 0, MAX(NSWidth(nframe), NSWidth(pframe)), MAX(NSHeight(nframe), NSHeight(pframe)));
    }

    -(void)setRootNode:(PGBinaryTreeNode *)rootNode {
        _rootNode = rootNode;
        if(_rootNode) [self setFrame:self.desiredFrame];
        self.needsDisplay = YES;
    }

    -(void)setFrame:(NSRect)frame {
        if(self.rootNode) {
            NSRect dframe = self.desiredFrame;
            if(!NSContainsRect(frame, dframe)) frame = dframe;
        }

        [super setFrame:frame];
    }

    -(BOOL)isFlipped {
        return YES;
    }

    -(void)drawRect:(NSRect)dirtyRect {
        [[NSColor whiteColor] setFill];
        [NSBezierPath fillRect:dirtyRect];

        if(self.rootNode) {
            // [self.rootNode draw:self.frame];
        }
        else {
            [@"Nothing to show" drawDeadCentered:dirtyRect fontName:@"AmericanTypewriter-Light" fontSize:18 fontColor:[NSColor blackColor]];
        }
    }

@end
