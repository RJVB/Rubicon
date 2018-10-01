/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXParserTools.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/23/18
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

#ifndef __RUBICON_PGSAXPARSERTOOLS_H__
#define __RUBICON_PGSAXPARSERTOOLS_H__

#import "PGSAXParser.h"
#import "PGSAXDelegate.h"
#import "PGSAXAttribute.h"
#import "PGSAXNamespace.h"
#import "PGInternal.h"
#import <libxml/SAX2.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark Declarations

#define FOO(t, f)              (*((t)(f)))
#define CASTASPARSER(p)        (PG_BRDG_CAST(PGSAXParser)(p))
#define PGSAX_PUSH_BUFFER_SIZE (65536)
#define SAX_ENTITY_KEY         @"%@⌘%@"

typedef struct _pgsax_simple_buffer PGSAXSimpleBuffer;
struct _pgsax_simple_buffer {
    char *buffer;
    int  length;
};
typedef PGSAXParser *__unsafe_unretained BridgedParserPtr;

typedef NSInteger (*t_fRead)(id, SEL, uint8_t *, NSUInteger);

#pragma mark Delegate Method Function Types

/* @f:0 */
typedef void (*t_funcInternalSubset)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcExternalSubset)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef BOOL (*t_funcIsStandalone)(id, SEL, PGSAXParser *);
typedef BOOL (*t_funcHasInternalSubset)(id, SEL, PGSAXParser *);
typedef BOOL (*t_funcHasExternalSubset)(id, SEL, PGSAXParser *);
typedef NSString *_Nullable (*t_funcGetEntity)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef NSString *_Nullable (*t_funcGetParameterEntity)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef NSData   *_Nullable (*t_funcResolveEntity)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcEntityDecl)(id, SEL, PGSAXParser *, NSString *_Nullable, int, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcNotationDecl)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcAttributeDecl)(id, SEL, PGSAXParser *, PGSAXAttributeDecl *);
typedef void (*t_funcElementDecl)(id, SEL, PGSAXParser *, NSString *_Nullable, int, PGSAXElementDecl *_Nullable);
typedef void (*t_funcUnparsedEntityDecl)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcSetDocumentLocator)(id, SEL, PGSAXParser *, PGSAXLocator *_Nullable);
typedef void (*t_funcStartDocument)(id, SEL, PGSAXParser *);
typedef void (*t_funcEndDocument)(id, SEL, PGSAXParser *);
typedef void (*t_funcStartElement)(id, SEL, PGSAXParser *, NSString *_Nullable, NSArray<PGSAXAttribute *> *);
typedef void (*t_funcEndElement)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcAttribute)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcReference)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcCharacters)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcIgnorableWhitespace)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcProcessingInstruction)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcComment)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcCdataBlock)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcStartElementNS)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable, NSArray<PGSAXNamespace *> *, NSArray<PGSAXAttribute *> *);
typedef void (*t_funcEndElementNS)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef void (*t_funcXmlStructuredError)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcWarning)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcError)(id, SEL, PGSAXParser *, NSString *_Nullable);
typedef void (*t_funcFatalError)(id, SEL, PGSAXParser *, NSString *_Nullable);
/* @f:1 */

#pragma mark Private Parser Category

@interface PGSAXParser()

    @property(retain) /*          */ NSMutableDictionary<NSString *, PGSAXEntity *> *entities;

    @property(nullable) /*        */ IMP funcInternalSubset;
    @property(nullable) /*        */ IMP funcExternalSubset;
    @property(nullable) /*        */ IMP funcIsStandalone;
    @property(nullable) /*        */ IMP funcHasInternalSubset;
    @property(nullable) /*        */ IMP funcHasExternalSubset;
    @property(nullable) /*        */ IMP funcGetEntity;
    @property(nullable) /*        */ IMP funcGetParameterEntity;
    @property(nullable) /*        */ IMP funcResolveEntity;
    @property(nullable) /*        */ IMP funcEntityDecl;
    @property(nullable) /*        */ IMP funcNotationDecl;
    @property(nullable) /*        */ IMP funcAttributeDecl;
    @property(nullable) /*        */ IMP funcElementDecl;
    @property(nullable) /*        */ IMP funcUnparsedEntityDecl;
    @property(nullable) /*        */ IMP funcSetDocumentLocator;
    @property(nullable) /*        */ IMP funcStartDocument;
    @property(nullable) /*        */ IMP funcEndDocument;
    @property(nullable) /*        */ IMP funcStartElement;
    @property(nullable) /*        */ IMP funcEndElement;
    @property(nullable) /*        */ IMP funcReference;
    @property(nullable) /*        */ IMP funcCharacters;
    @property(nullable) /*        */ IMP funcIgnorableWhitespace;
    @property(nullable) /*        */ IMP funcProcessingInstruction;
    @property(nullable) /*        */ IMP funcComment;
    @property(nullable) /*        */ IMP funcCdataBlock;
    @property(nullable) /*        */ IMP funcStartElementNS;
    @property(nullable) /*        */ IMP funcEndElementNS;
    @property(nullable) /*        */ IMP funcXmlStructuredError;
    @property(nullable) /*        */ IMP funcWarning;
    @property(nullable) /*        */ IMP funcError;
    @property(nullable) /*        */ IMP funcFatalError;

    @property /*                  */ BOOL              hasAlreadyRun;
    @property(retain) /*          */ NSInputStream     *inputStream;
    @property(nullable, copy) /*  */ NSString          *filename;
    @property(retain) /*          */ NSRecursiveLock   *rlock;
    @property(nullable, retain) /**/ id<PGSAXDelegate> workingDelegate;
    @property(nullable) /*        */ xmlParserCtxtPtr  ctx;
    @property(nullable) /*        */ char              *utf8Filename;

    -(PGSAXSimpleBuffer *)createTempBuffer:(int)length;

    -(PGSAXEntity *)getLocalEntity:(NSString *)name;

    -(PGSAXEntity *)getLocalParameterEntity:(NSString *)name;

    /* @f:0 */

    -(void)internalSubset:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId;

    -(void)externalSubset:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId;

    -(BOOL)isStandalone;

    -(BOOL)hasInternalSubset;

    -(BOOL)hasExternalSubset;

    -(nullable NSString *)getEntity:(nullable NSString *)name;

    -(nullable NSString *)getParameterEntity:(nullable NSString *)name;

    -(nullable NSData *)resolveEntity:(nullable NSString *)publicId systemID:(nullable NSString *)systemId;

    -(PGSAXEntity *)storeEntity:(NSString *)name type:(int)type publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId content:(NSString *)content;

    -(void)entityDecl:(nullable NSString *)name type:(int)type publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId content:(nullable NSString *)content;

    -(void)notationDecl:(nullable NSString *)name publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId;

    -(void)attributeDecl:(PGSAXAttributeDecl *)attrdecl;

    -(void)elementDecl:(NSString *)name type:(int)type content:(PGSAXElementDecl *)content;

    -(void)unparsedEntityDecl:(nullable NSString *)name publicID:(nullable NSString *)pubid systemID:(nullable NSString *)sysid notationName:(nullable NSString *)notnam;

    -(void)setDocumentLocator:(nullable PGSAXLocator *)location;

    -(void)startDocument;

    -(void)endDocument;

    -(void)startElement:(nullable NSString *)name attributes:(NSArray<PGSAXAttribute *> *)attributes;

    -(void)endElement:(nullable NSString *)name;

    -(void)reference:(nullable NSString *)name;

    -(void)characters:(nullable NSString *)value;

    -(void)ignorableWhitespace:(nullable NSString *)value;

    -(void)processingInstruction:(nullable NSString *)target data:(nullable NSString *)data;

    -(void)comment:(nullable NSString *)value;

    -(void)cdataBlock:(nullable NSString *)value;

    -(void)startElemNS:(nullable NSString *)n pfx:(nullable NSString *)p URI:(nullable NSString *)u nspcs:(NSArray<PGSAXNamespace *> *)ns atts:(NSArray<PGSAXAttribute *> *)at;

    -(void)endElementNS:(nullable NSString *)localname prefix:(nullable NSString *)prefix URI:(nullable NSString *)URI;

    -(void)structuredError:(nullable NSString *)msg;

    -(void)warning:(nullable NSString *)msg;

    -(void)error:(nullable NSString *)msg;

    -(void)fatalError:(nullable NSString *)msg;

/* @f:1 */

@end

#pragma mark Utility Class Categories

@interface NSString(PGSAX)

    +(NSString *)stringFromXMLString:(const xmlChar *)xmlStr;

    +(NSString *)stringFromXMLString:(const xmlChar *)xmlStr length:(int)length;

    +(NSString *)stringFromXMLString:(const xmlChar *)xmlStr args:(va_list)args;

@end

@interface PGSAXLocator()

    -(instancetype)initWithLocator:(xmlSAXLocatorPtr)locator context:(voidp)ctx;

@end

@interface PGSAXNamespace()

    +(NSArray<PGSAXNamespace *> *)namespacesFromArray:(const xmlChar **)arr length:(NSUInteger)length;

@end

@interface PGSAXAttribute()

    +(NSArray<PGSAXAttribute *> *)attributeListFromAttributes:(const xmlChar **)atts length:(NSUInteger)length numDefs:(NSUInteger)numDefs;

    +(NSArray<PGSAXAttribute *> *)attributeListFromAttributes:(const xmlChar **)atts;

@end

@interface PGSAXElementDecl()

    -(instancetype)initWithXmlElementContent:(xmlElementContentPtr)elemContent;

    +(instancetype)declWithXmlElementContent:(xmlElementContentPtr)elemContent;
@end

@interface PGSAXEntity()

    @property(readonly) xmlEntityPtr xmlEntity;

@end

/* @f:0 */
#pragma mark Utility Function Declarations

FOUNDATION_EXPORT void populateSelectorFields(void);
FOUNDATION_EXPORT xmlSAXHandlerPtr createSAXHandler(xmlSAXHandlerPtr saxh);
FOUNDATION_EXPORT NSArray<NSString *> *errorDomainXlat(int errorDomain);
FOUNDATION_EXPORT NSString *errorLevelXlat(xmlErrorLevel level);

#pragma mark Call Back Function Declarations

FOUNDATION_EXPORT int __hasInternalSubsetSAX(void *ctx);
FOUNDATION_EXPORT int __hasExternalSubsetSAX(void *ctx);
FOUNDATION_EXPORT void __startElementNsSAX2(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
FOUNDATION_EXPORT void __endElementNsSAX2(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
FOUNDATION_EXPORT void __xmlStructuredError2(void *userData, xmlErrorPtr error);
FOUNDATION_EXPORT void __internalSubsetSAX(void *ctx, const xmlChar *name, const xmlChar *ExternalID, const xmlChar *SystemID);
FOUNDATION_EXPORT void __externalSubsetSAX(void *ctx, const xmlChar *name, const xmlChar *ExternalID, const xmlChar *SystemID);
FOUNDATION_EXPORT xmlEntityPtr __getEntitySAX(void *ctx, const xmlChar *name);
FOUNDATION_EXPORT xmlEntityPtr __getParameterEntitySAX(void *ctx, const xmlChar *name);
FOUNDATION_EXPORT xmlParserInputPtr __resolveEntitySAX(void *ctx, const xmlChar *publicId, const xmlChar *systemId);
FOUNDATION_EXPORT void __entityDeclSAX(void *ctx, const xmlChar *name, int type, const xmlChar *publicId, const xmlChar *systemId, xmlChar *content);
FOUNDATION_EXPORT void __notationDeclSAX(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId);
FOUNDATION_EXPORT void __attributeDeclSAX(void *ctx, const xmlChar *elem, const xmlChar *fullname, int type, int def, const xmlChar *defaultValue, xmlEnumerationPtr tree);
FOUNDATION_EXPORT void __elementDeclSAX(void *ctx, const xmlChar *name, int type, xmlElementContentPtr content);
FOUNDATION_EXPORT void __unparsedEntityDeclSAX(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId, const xmlChar *notationName);
FOUNDATION_EXPORT void __setDocumentLocatorSAX(void *ctx, xmlSAXLocatorPtr loc);
FOUNDATION_EXPORT void __startDocumentSAX(void *ctx);
FOUNDATION_EXPORT void __endDocumentSAX(void *ctx);
FOUNDATION_EXPORT void __startElementSAX(void *ctx, const xmlChar *name, const xmlChar **atts);
FOUNDATION_EXPORT void __endElementSAX(void *ctx, const xmlChar *name);
FOUNDATION_EXPORT void __referenceSAX(void *ctx, const xmlChar *name);
FOUNDATION_EXPORT void __charactersSAX(void *ctx, const xmlChar *ch, int len);
FOUNDATION_EXPORT void __ignorableWhitespaceSAX(void *ctx, const xmlChar *ch, int len);
FOUNDATION_EXPORT void __processingInstructionSAX(void *ctx, const xmlChar *target, const xmlChar *data);
FOUNDATION_EXPORT void __commentSAX(void *ctx, const xmlChar *value);
FOUNDATION_EXPORT void __cdataBlockSAX(void *ctx, const xmlChar *value, int len);
FOUNDATION_EXPORT void __warningSAX(void *ctx, const char *msg, ...);
FOUNDATION_EXPORT void __errorSAX(void *ctx, const char *msg, ...);
FOUNDATION_EXPORT void __fatalErrorSAX(void *ctx, const char *msg, ...);
FOUNDATION_EXPORT int __isStandaloneSAX(void *ctx);
/* @f:1 */

#pragma mark Delegate Method Selectors

FOUNDATION_EXPORT SEL _selInternalSubset;
FOUNDATION_EXPORT SEL _selExternalSubset;
FOUNDATION_EXPORT SEL _selIsStandalone;
FOUNDATION_EXPORT SEL _selHasInternalSubset;
FOUNDATION_EXPORT SEL _selHasExternalSubset;
FOUNDATION_EXPORT SEL _selGetEntity;
FOUNDATION_EXPORT SEL _selGetParameterEntity;
FOUNDATION_EXPORT SEL _selResolveEntity;
FOUNDATION_EXPORT SEL _selEntityDecl;
FOUNDATION_EXPORT SEL _selNotationDecl;
FOUNDATION_EXPORT SEL _selAttributeDecl;
FOUNDATION_EXPORT SEL _selElementDecl;
FOUNDATION_EXPORT SEL _selUnparsedEntityDecl;
FOUNDATION_EXPORT SEL _selSetDocumentLocator;
FOUNDATION_EXPORT SEL _selStartDocument;
FOUNDATION_EXPORT SEL _selEndDocument;
FOUNDATION_EXPORT SEL _selStartElement;
FOUNDATION_EXPORT SEL _selEndElement;
FOUNDATION_EXPORT SEL _selReference;
FOUNDATION_EXPORT SEL _selCharacters;
FOUNDATION_EXPORT SEL _selIgnorableWhitespace;
FOUNDATION_EXPORT SEL _selProcessingInstruction;
FOUNDATION_EXPORT SEL _selComment;
FOUNDATION_EXPORT SEL _selCdataBlock;
FOUNDATION_EXPORT SEL _selStartElementNS;
FOUNDATION_EXPORT SEL _selEndElementNS;
FOUNDATION_EXPORT SEL _selXmlStructuredError;
FOUNDATION_EXPORT SEL _selWarning;
FOUNDATION_EXPORT SEL _selError;
FOUNDATION_EXPORT SEL _selFatalError;
FOUNDATION_EXPORT SEL _selStreamRead;

NS_ASSUME_NONNULL_END

#endif // __RUBICON_PGSAXPARSERTOOLS_H__
