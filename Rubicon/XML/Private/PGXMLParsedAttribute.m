/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParsedAttribute.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/26/18
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

#import "PGXMLParsedAttribute.h"

@implementation PGXMLParsedAttribute {
    }

    @synthesize localName = _localName;
    @synthesize URI = _URI;
    @synthesize prefix = _prefix;
    @synthesize value = _value;
    @synthesize isDefaulted = _isDefaulted;

    -(instancetype)initWithLocalName:(NSString *)localName prefix:(NSString *)prefix URI:(NSString *)URI value:(NSString *)value isDefaulted:(BOOL)isDefaulted {
        self = [super init];

        if(self) {
            _localName   = [localName copy];
            _URI         = [URI copy];
            _prefix      = [prefix copy];
            _value       = [value copy];
            _isDefaulted = isDefaulted;
        }

        return self;
    }

    +(instancetype)attributeWithLocalName:(NSString *)localName
                                   prefix:(nullable NSString *)prefix
                                      URI:(nullable NSString *)URI
                                    value:(NSString *)value
                              isDefaulted:(BOOL)isDefaulted {
        return [[self alloc] initWithLocalName:localName prefix:prefix URI:URI value:value isDefaulted:isDefaulted];
    }

    +(instancetype)attributeWithLocalName:(NSString *)name value:(NSString *)value {
        return [[self alloc] initWithLocalName:name prefix:nil URI:nil value:value isDefaulted:NO];
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self isEqualToAttribute:other])));
    }

    -(BOOL)isEqualToAttribute:(PGXMLParsedAttribute *)attr {
        return (attr &&
                ((self == attr) ||
                 (PGStringsEqual(_localName, attr.localName) &&
                  PGStringsEqual(_URI, attr.URI) &&
                  PGStringsEqual(_prefix, attr.prefix) &&
                  PGStringsEqual(_value, attr.value) &&
                  (_isDefaulted == attr.isDefaulted))));
    }

    -(NSUInteger)hash {
        return (((((((((31u + [_localName hash]) * 31u) + [_URI hash]) * 31u) + [_prefix hash]) * 31u) + [_value hash]) * 31u) + _isDefaulted);
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return self;
    }

@end
