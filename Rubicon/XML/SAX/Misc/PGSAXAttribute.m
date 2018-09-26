/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXAttribute.m
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

@implementation PGSAXAttribute {
    }

    @synthesize name = _name;
    @synthesize value = _value;
    @synthesize isDefaulted = _isDefaulted;

    -(instancetype)initWithName:(NSString *)name value:(NSString *)value {
        self = [super init];

        if(self) {
            _name  = [name copy];
            _value = [name copy];
        }

        return self;
    }

    +(instancetype)attributeWithName:(NSString *)name value:(NSString *)value {
        return [[self alloc] initWithName:name value:value];
    }

    -(instancetype)initWithLocalname:(NSString *)localname prefix:(nullable NSString *)prefix uri:(NSString *)uri value:(NSString *)value defaulted:(BOOL)defaulted {
        self = [super initWithPrefix:prefix uri:uri];
        if(self) {
            _name        = localname.copy;
            _value       = value.copy;
            _isDefaulted = defaulted;
        }
        return self;
    }

    +(instancetype)attributeWithLocalname:(NSString *)localname prefix:(nullable NSString *)prefix uri:(NSString *)uri value:(NSString *)value defaulted:(BOOL)defaulted {
        return [[self alloc] initWithLocalname:localname prefix:prefix uri:uri value:value defaulted:defaulted];
    }

    +(NSArray<PGSAXAttribute *> *)attributeListFromAttributes:(const xmlChar **)atts {
        if(atts) {
            NSMutableArray<PGSAXAttribute *> *at = [NSMutableArray new];

            for(NSUInteger i = 0; (atts[i] != NULL);) {
                const xmlChar *str    = atts[i++];
                NSString      *aName  = [NSString stringFromXMLString:str];
                const xmlChar *str1   = atts[i++];
                NSString      *aValue = [NSString stringFromXMLString:str1];
                if(aValue) [at addObject:[self attributeWithName:aName value:aValue]];
            }

            return at;
        }
        return @[];
    }

    +(NSArray<PGSAXAttribute *> *)attributeListFromAttributes:(const xmlChar **)atts length:(NSUInteger)length numDefs:(NSUInteger)numDefs {
        if(atts && length) {
            NSMutableArray<PGSAXAttribute *> *at = [NSMutableArray new];
            NSUInteger                       dl  = (length - numDefs);
            NSUInteger                       j   = 0;

            for(NSUInteger i = 0; i < length; ++i) {
                BOOL          d     = (i >= dl);
                const xmlChar *str  = atts[j++];
                NSString      *l    = [NSString stringFromXMLString:str];
                const xmlChar *str1 = atts[j++];
                NSString      *p    = [NSString stringFromXMLString:str1];
                const xmlChar *str2 = atts[j++];
                NSString      *u    = [NSString stringFromXMLString:str2];
                const xmlChar *vs   = atts[j++];
                const xmlChar *ve   = atts[j++];
                NSString      *v    = ((vs && (ve > vs)) ? [NSString stringFromXMLString:vs args:(ve - vs)] : @"");

                [at addObject:[self attributeWithLocalname:l prefix:p uri:u value:v defaulted:d]];
            }

            return at;
        }
        return @[];
    }

@end
