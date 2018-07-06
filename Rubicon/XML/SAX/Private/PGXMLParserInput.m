/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParserInput.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/21/18
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

#import "PGXMLParserInput.h"

@implementation PGXMLParserInput {
        char *_buffer;
    }

    @synthesize length = _length;

    -(instancetype)initWithData:(NSData *)data {
        self = [super init];

        if(self) {
            _length = data.length;
            _buffer = PGMalloc(MAX(_length, 1));
            if(_length) [data getBytes:_buffer length:_length];
        }

        return self;
    }

    -(instancetype)initWithBuffer:(void *)buffer length:(NSUInteger)length {
        self = [super init];

        if(self) {
            _length = (buffer ? length : 0);
            _buffer = PGMalloc(MAX(_length, 1));
            if(_length) PGMemCopy(_buffer, buffer, _length);
        }

        return self;
    }

    +(instancetype)inputWithData:(NSData *)data {
        return [[self alloc] initWithData:data];
    }

    -(xmlParserInputPtr)getNewParserInputForContext:(xmlParserCtxtPtr)ctx {
        xmlParserInputBufferPtr pib = xmlParserInputBufferCreateMem(_buffer, (int)_length, XML_CHAR_ENCODING_UTF8);
        return (pib ? xmlNewIOInputStream(ctx, pib, XML_CHAR_ENCODING_UTF8) : NULL);
    }

    -(void)dealloc {
        if(_buffer) {
            free(_buffer);
            _buffer = NULL;
        }

        _length = 0;
    }

@end
