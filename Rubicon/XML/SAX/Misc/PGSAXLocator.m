/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXLocator.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/20/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
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

#import "PGSAXParserTools.h"

@implementation PGSAXLocator {
        xmlSAXLocatorPtr _locator;
        void             *_ctx;
    }

    -(instancetype)init {
        self = [super init];

        if(self) {
            _locator = NULL;
            _ctx     = NULL;
        }

        return self;
    }

    -(instancetype)initWithLocator:(xmlSAXLocatorPtr)locator context:(voidp)ctx {
        self = [super init];

        if(self) {
            _locator = locator;
            _ctx     = ctx;
            PGLog(@"Instance of %@ created: publicId: \"%@\"; systemId: \"%@\"; lineNumber: %lu; columnNumber: %lu;",
                  NSStringFromClass([self class]),
                  self.publicId,
                  self.systemId,
                  self.lineNumber,
                  self.columnNumber);
        }

        return self;
    }

    -(NSString *)publicId {
        const xmlChar *str = _locator->getPublicId(_ctx);
        return ((_locator && _locator->getPublicId) ? [NSString stringFromXMLString:str] : nil);
    }

    -(NSString *)systemId {
        const xmlChar *str = _locator->getSystemId(_ctx);
        return ((_locator && _locator->getSystemId) ? [NSString stringFromXMLString:str] : nil);
    }

    -(NSUInteger)lineNumber {
        return (NSUInteger)((_locator && _locator->getLineNumber) ? abs(_locator->getLineNumber(_ctx)) : 0);
    }

    -(NSUInteger)columnNumber {
        return (NSUInteger)((_locator && _locator->getColumnNumber) ? abs(_locator->getColumnNumber(_ctx)) : 0);
    }

@end
