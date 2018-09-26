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

#define FOO(t, f)              (*((t)(f)))
#define CASTASPARSER(p)        ((__bridge PGSAXParser *)(p))
#define PGSAX_PUSH_BUFFER_SIZE (65536)

/* @f:0 */
typedef PGSAXParser *__unsafe_unretained BridgedParserPtr;
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
typedef void (*t_funcAttributeDecl)(id, SEL, PGSAXParser *, NSString *_Nullable, NSString *_Nullable, int, int, NSString *_Nullable, NSArray *);
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
typedef NSInteger (*t_fRead)(id, SEL, uint8_t *, NSUInteger);
/* @f:1 */

@interface PGSAXParser()

    @property(retain) /**/ NSMutableDictionary<NSString *, NSString *> *entities;

    @property /*        */ IMP funcInternalSubset;
    @property /*        */ IMP funcExternalSubset;
    @property /*        */ IMP funcIsStandalone;
    @property /*        */ IMP funcHasInternalSubset;
    @property /*        */ IMP funcHasExternalSubset;
    @property /*        */ IMP funcGetEntity;
    @property /*        */ IMP funcGetParameterEntity;
    @property /*        */ IMP funcResolveEntity;
    @property /*        */ IMP funcEntityDecl;
    @property /*        */ IMP funcNotationDecl;
    @property /*        */ IMP funcAttributeDecl;
    @property /*        */ IMP funcElementDecl;
    @property /*        */ IMP funcUnparsedEntityDecl;
    @property /*        */ IMP funcSetDocumentLocator;
    @property /*        */ IMP funcStartDocument;
    @property /*        */ IMP funcEndDocument;
    @property /*        */ IMP funcStartElement;
    @property /*        */ IMP funcEndElement;
    @property /*        */ IMP funcReference;
    @property /*        */ IMP funcCharacters;
    @property /*        */ IMP funcIgnorableWhitespace;
    @property /*        */ IMP funcProcessingInstruction;
    @property /*        */ IMP funcComment;
    @property /*        */ IMP funcCdataBlock;
    @property /*        */ IMP funcStartElementNS;
    @property /*        */ IMP funcEndElementNS;
    @property /*        */ IMP funcXmlStructuredError;
    @property /*        */ IMP funcWarning;
    @property /*        */ IMP funcError;
    @property /*        */ IMP funcFatalError;

    @property /*        */ BOOL              hasAlreadyRun;
    @property(retain) /**/ NSInputStream     *inputStream;
    @property(copy) /*  */ NSString          *filename;
    @property(retain) /**/ NSRecursiveLock   *rlock;
    @property(retain) /**/ id<PGSAXDelegate> workingDelegate;
    @property /*        */ xmlParserCtxtPtr  ctx;
    @property /*        */ xmlSAXHandlerPtr  saxHandler;
    @property /*        */ char              *utf8Filename;

/* @f:0 */

    -(void)internalSubset:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId;

    -(void)externalSubset:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId;

    -(BOOL)isStandalone;

    -(BOOL)hasInternalSubset;

    -(BOOL)hasExternalSubset;

    -(nullable NSString *)getEntity:(nullable NSString *)name;

    -(nullable NSString *)getParameterEntity:(nullable NSString *)name;

    -(nullable NSData *)resolveEntity:(nullable NSString *)publicId systemID:(nullable NSString *)systemId;

    -(void)entityDecl:(nullable NSString *)name type:(int)type publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId content:(nullable NSString *)content;

    -(void)notationDecl:(nullable NSString *)name publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId;

    -(void)attributeDecl:(nullable NSString *)elem fullname:(nullable NSString *)fname type:(int)type def:(int)def defaultValue:(nullable NSString *)defval tree:(NSArray *)tree;

    -(void)elementDecl:(nullable NSString *)name type:(int)type content:(nullable PGSAXElementDecl *)content;

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

    -(void)xmlStructuredError:(nullable NSString *)msg;

    -(void)warning:(nullable NSString *)msg;

    -(void)error:(nullable NSString *)msg;

    -(void)fatalError:(nullable NSString *)msg;

/* @f:1 */

@end

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

/* @f:0 */
FOUNDATION_EXPORT BOOL pushParseXML(PGSAXParser *parser, id<PGSAXDelegate> delegate, NSInputStream *instr, NSError **error);
FOUNDATION_EXPORT void postParseCleanup(PGSAXParser *parser);

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

FOUNDATION_EXPORT static SEL _selInternalSubset;
FOUNDATION_EXPORT static SEL _selExternalSubset;
FOUNDATION_EXPORT static SEL _selIsStandalone;
FOUNDATION_EXPORT static SEL _selHasInternalSubset;
FOUNDATION_EXPORT static SEL _selHasExternalSubset;
FOUNDATION_EXPORT static SEL _selGetEntity;
FOUNDATION_EXPORT static SEL _selGetParameterEntity;
FOUNDATION_EXPORT static SEL _selResolveEntity;
FOUNDATION_EXPORT static SEL _selEntityDecl;
FOUNDATION_EXPORT static SEL _selNotationDecl;
FOUNDATION_EXPORT static SEL _selAttributeDecl;
FOUNDATION_EXPORT static SEL _selElementDecl;
FOUNDATION_EXPORT static SEL _selUnparsedEntityDecl;
FOUNDATION_EXPORT static SEL _selSetDocumentLocator;
FOUNDATION_EXPORT static SEL _selStartDocument;
FOUNDATION_EXPORT static SEL _selEndDocument;
FOUNDATION_EXPORT static SEL _selStartElement;
FOUNDATION_EXPORT static SEL _selEndElement;
FOUNDATION_EXPORT static SEL _selReference;
FOUNDATION_EXPORT static SEL _selCharacters;
FOUNDATION_EXPORT static SEL _selIgnorableWhitespace;
FOUNDATION_EXPORT static SEL _selProcessingInstruction;
FOUNDATION_EXPORT static SEL _selComment;
FOUNDATION_EXPORT static SEL _selCdataBlock;
FOUNDATION_EXPORT static SEL _selStartElementNS;
FOUNDATION_EXPORT static SEL _selEndElementNS;
FOUNDATION_EXPORT static SEL _selXmlStructuredError;
FOUNDATION_EXPORT static SEL _selWarning;
FOUNDATION_EXPORT static SEL _selError;
FOUNDATION_EXPORT static SEL _selFatalError;
FOUNDATION_EXPORT static SEL _selStreamRead;

NS_ASSUME_NONNULL_END

#endif // __RUBICON_PGSAXPARSERTOOLS_H__
