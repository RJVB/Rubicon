/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMLocator.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/12/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 **********************************************************************************************************************************************************************************/

#import "PGDOMPrivate.h"

@implementation PGDOMLocator {
    }

    @synthesize lineNumber = _lineNumber;
    @synthesize columnNumber = _columnNumber;
    @synthesize byteOffset = _byteOffset;
    @synthesize utf16Offset = _utf16Offset;
    @synthesize relatedNode = _relatedNode;
    @synthesize uri = _uri;

    -(instancetype)initWithLineNumber:(NSUInteger)lineNumber
                         columnNumber:(NSUInteger)columnNumber
                           byteOffset:(NSUInteger)byteOffset
                          utf16Offset:(NSUInteger)utf16Offset
                          relatedNode:(PGDOMNode *)relatedNode
                                  uri:(NSString *)uri {
        self = [super init];

        if(self) {
            _lineNumber   = lineNumber;
            _columnNumber = columnNumber;
            _byteOffset   = byteOffset;
            _utf16Offset  = utf16Offset;
            _relatedNode  = relatedNode;
            _uri          = [uri copy];
        }

        return self;
    }

@end
