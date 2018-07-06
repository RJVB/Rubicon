/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParserAttribute.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/26/18
 *  VISIBILITY: Private
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

#ifndef RUBICON_PGXMLPARSEDATTRIBUTE_H
#define RUBICON_PGXMLPARSEDATTRIBUTE_H

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGXMLParserAttribute : NSObject<NSCopying>

    @property(copy, readonly) /*     */ NSString *localName;
    @property(nullable, copy, readonly) NSString *URI;
    @property(nullable, copy, readonly) NSString *prefix;
    @property(copy, readonly) /*     */ NSString *value;
    @property(readonly) /*           */ BOOL     isDefaulted;

    -(instancetype)initWithLocalName:(NSString *)localName prefix:(nullable NSString *)prefix URI:(nullable NSString *)URI value:(NSString *)value isDefaulted:(BOOL)isDefaulted;

    +(instancetype)attributeWithLocalName:(NSString *)name value:(NSString *)value;

    -(BOOL)isEqual:(nullable id)other;

    -(BOOL)isEqualToAttribute:(nullable PGXMLParserAttribute *)other;

    -(NSUInteger)hash;

    -(id)copyWithZone:(nullable NSZone *)zone;

    +(instancetype)attributeWithLocalName:(NSString *)localName
                                   prefix:(nullable NSString *)prefix
                                      URI:(nullable NSString *)URI
                                    value:(NSString *)value
                              isDefaulted:(BOOL)isDefaulted;


@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGXMLPARSEDATTRIBUTE_H
