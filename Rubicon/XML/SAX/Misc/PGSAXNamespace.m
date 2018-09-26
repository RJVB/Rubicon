/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXNamespace.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/21/18
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

@implementation PGSAXNamespace {
    }

    @synthesize prefix = _prefix;
    @synthesize uri = _uri;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _prefix = nil;
            _uri    = nil;
        }

        return self;
    }

    -(instancetype)initWithPrefix:(NSString *)prefix uri:(NSString *)uri {
        self = [super init];

        if(self) {
            _prefix = prefix.copy;
            _uri    = uri.copy;
        }

        return self;
    }

    +(instancetype)namespaceWithPrefix:(NSString *)prefix uri:(NSString *)uri {
        return [[self alloc] initWithPrefix:prefix uri:uri];
    }

    +(NSArray<PGSAXNamespace *> *)namespacesFromArray:(const xmlChar **)arr length:(NSUInteger)length {
        if(arr && length) {
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:length];
            NSUInteger     j     = 0;

            for(NSUInteger i = 0; i < length; ++i) {
                const xmlChar *str    = arr[j++];
                NSString      *prefix = [NSString stringFromXMLString:str];
                const xmlChar *str1   = arr[j++];
                NSString      *uri    = [NSString stringFromXMLString:str1];
                [list addObject:[self namespaceWithPrefix:prefix uri:uri]];
            }

            return list;
        }
        else return @[];
    }

@end
