/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXAttribute.h
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

#ifndef __RUBICON_PGSAXATTRIBUTE_H__
#define __RUBICON_PGSAXATTRIBUTE_H__

#import <Rubicon/PGSAXNamespace.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PGSAXAttributeType) {
    PGSAX_ATTR_CDATA = 1,
    PGSAX_ATTR_ID,
    PGSAX_ATTR_IDREF,
    PGSAX_ATTR_IDREFS,
    PGSAX_ATTR_ENTITY,
    PGSAX_ATTR_ENTITIES,
    PGSAX_ATTR_NMTOKEN,
    PGSAX_ATTR_NMTOKENS,
    PGSAX_ATTR_ENUMERATION,
    PGSAX_ATTR_NOTATION
};

typedef NS_ENUM(NSInteger, PGSAXAttributeDefault) {
    PGSAX_ATTR_NONE = 1, PGSAX_ATTR_REQUIRED, PGSAX_ATTR_IMPLIED, PGSAX_ATTR_FIXED
};

@interface PGSAXAttribute : PGSAXNamespace

    @property(readonly) NSString *name;
    @property(readonly) NSString *value;
    @property(readonly) BOOL     isDefaulted;

    -(instancetype)initWithName:(NSString *)name value:(NSString *)value;

    +(instancetype)attributeWithName:(NSString *)name value:(NSString *)value;

    -(instancetype)initWithLocalname:(NSString *)localname prefix:(nullable NSString *)prefix uri:(NSString *)uri value:(NSString *)value defaulted:(BOOL)defaulted;

    +(instancetype)attributeWithLocalname:(NSString *)localname prefix:(nullable NSString *)prefix uri:(NSString *)uri value:(NSString *)value defaulted:(BOOL)defaulted;

@end

@interface PGSAXAttributeDecl : NSObject

    @property(readonly) /*     */ NSString              *element;
    @property(readonly) /*     */ NSString              *fullname;
    @property(readonly) /*     */ PGSAXAttributeType    attrType;
    @property(readonly) /*     */ PGSAXAttributeDefault attrDefault;
    @property(readonly, nullable) NSString              *defaultValue;
    @property(readonly) /*     */ NSArray<NSString *>   *valueList;

    -(instancetype)initWithElement:(NSString *)element
                          fullname:(NSString *)fullname
                          attrType:(PGSAXAttributeType)attrType
                       attrDefault:(PGSAXAttributeDefault)attrDefault
                      defaultValue:(nullable NSString *)defaultValue
                         valueList:(NSArray<NSString *> *)valueList;

    +(instancetype)declWithElement:(NSString *)element
                          fullname:(NSString *)fullname
                          attrType:(PGSAXAttributeType)attrType
                       attrDefault:(PGSAXAttributeDefault)attrDefault
                      defaultValue:(nullable NSString *)defaultValue
                         valueList:(NSArray<NSString *> *)valueList;


@end

NS_INLINE NSString *PGSAXAttributeDefaultName(PGSAXAttributeDefault d) {
    switch(d) { /* @f:0 */
        case PGSAX_ATTR_REQUIRED: return @"Required";
        case PGSAX_ATTR_IMPLIED:  return @"Implied";
        case PGSAX_ATTR_FIXED:    return @"Fixed";
        case PGSAX_ATTR_NONE:
        default:                  return @"None";
    /* @f:1 */ }
}

NS_INLINE NSString *PGSAXAttributeTypeName(PGSAXAttributeType t) {
    switch(t) { /* @f:0 */
        case PGSAX_ATTR_ID:          return @"ID";
        case PGSAX_ATTR_IDREF:       return @"IDRef";
        case PGSAX_ATTR_IDREFS:      return @"IDRefs";
        case PGSAX_ATTR_ENTITY:      return @"Entity";
        case PGSAX_ATTR_ENTITIES:    return @"Entities";
        case PGSAX_ATTR_NMTOKEN:     return @"NMToken";
        case PGSAX_ATTR_NMTOKENS:    return @"NMTokens";
        case PGSAX_ATTR_ENUMERATION: return @"Enumeration";
        case PGSAX_ATTR_NOTATION:    return @"Notation";
        case PGSAX_ATTR_CDATA:
        default:                     return @"CData";
    /* @f:1 */ }
}

NS_ASSUME_NONNULL_END

#endif // __RUBICON_PGSAXATTRIBUTE_H__
