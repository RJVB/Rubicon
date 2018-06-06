/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParserTools.h
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

#ifndef __PGXMLPARSERTOOLS_H__
#define __PGXMLPARSERTOOLS_H__

#import "PGInternal.h"
#import "PGXMLParsedNamespace.h"
#import <libxml/parser.h>
#import <libxml/SAX2.h>

@class PGXMLParsedEntity;

NS_ASSUME_NONNULL_BEGIN

/**
 * In theory the libxml2 strings are simply UTF-8 encoded, null terminated C strings so the following
 * should be all that is needed to convert from xmlChar to NSString.
 *
 * @param xmlstr the C string based on xmlChar
 * @return an instance of NSString.
 */
NSString *_Nullable stringForXMLString(const xmlChar *_Nullable xmlstr);

/**
 * In theory the libxml2 strings are simply UTF-8 encoded, null terminated C strings so the following
 * should be all that is needed to convert from xmlChar to NSString.
 *
 * @param xmlstr the C string based on xmlChar
 * @param len the length of the C string.
 * @return an instance of NSString.
 */
NSString *_Nullable stringForXMLStringLen(const xmlChar *_Nullable xmlstr, size_t len);

NSError *createError(NSInteger code, NSString *description);

NS_INLINE NSString *createQName(NSString *localname, NSString *prefix) {
    return (prefix.length ? PGFormat(@"%@:%@", prefix, localname) : localname);
}

@interface PGXMLParser()

    @property /*     */ IMP              foundNoteDeclFunc;
    @property /*     */ IMP              foundUnpEntDeclFunc;
    @property /*     */ IMP              foundAttrDeclFunc;
    @property /*     */ IMP              foundElemDeclFunc;
    @property /*     */ IMP              foundIntEntDeclFunc;
    @property /*     */ IMP              foundExtEntDeclFunc;
    @property /*     */ IMP              didStartDocFunc;
    @property /*     */ IMP              didEndDocFunc;
    @property /*     */ IMP              didStartElemFunc;
    @property /*     */ IMP              didEndElemFunc;
    @property /*     */ IMP              didStartMapPfxFunc;
    @property /*     */ IMP              didEndMapPfxFunc;
    @property /*     */ IMP              foundCharsFunc;
    @property /*     */ IMP              foundIgnWhitespFunc;
    @property /*     */ IMP              foundProcInstFunc;
    @property /*     */ IMP              foundCommentFunc;
    @property /*     */ IMP              foundCDATAFunc;
    @property /*     */ IMP              resolveExtEntFunc;
    @property /*     */ IMP              parseErrFunc;
    @property /*     */ IMP              validationErrFunc;
    @property /*     */ IMP              reslvIntEntFunc;
    @property /*     */ BOOL             hasRun;
    @property /*     */ xmlParserCtxtPtr ctx;
    @property /*     */ xmlSAXHandlerPtr saxHandler;
    @property /*     */ NSError          *parserError;
    @property(readonly) NSRecursiveLock  *lck;
    @property(copy)/**/ NSInputStream    *input;
    @property(copy)/**/ NSString         *filename;
    @property(copy)/**/ NSString         *publicId;
    @property(copy)/**/ NSString         *systemId;

    @property /*     */ NSMutableDictionary<NSString *, PGXMLParsedEntity *> *entities;

    -(instancetype)init NS_DESIGNATED_INITIALIZER;

    -(void)destroySAXHandlerStructure;

    -(void)setupSAXHandlerStructure;

    -(xmlParserInputPtr)resolveEntityCallBack:(nullable NSString *)publicId systemId:(nullable NSString *)systemId;

    -(void)internalSubsetCallBack:(nullable NSString *)name ExternalID:(nullable NSString *)ExternalID SystemID:(nullable NSString *)SystemID;

    -(void)externalSubsetCallBack:(nullable NSString *)name ExternalID:(nullable NSString *)ExternalID SystemID:(nullable NSString *)SystemID;

    -(xmlEntityPtr)getEntityCallBack:(nullable NSString *)name;

    -(xmlEntityPtr)getParameterEntityCallBack:(nullable NSString *)name;

    -(void)entityDeclCallBack:(nullable NSString *)name
                         type:(int)type
                     publicId:(nullable NSString *)publicId
                     systemId:(nullable NSString *)systemId
                      content:(nullable NSString *)content;

    -(void)notationDeclCallBack:(nullable NSString *)name publicId:(nullable NSString *)publicId systemId:(nullable NSString *)systemId;

    -(void)attributeDeclCallBack:(nullable NSString *)elem
                        fullname:(nullable NSString *)fullname
                            type:(int)type
                             def:(int)def
                    defaultValue:(nullable NSString *)defaultValue
                            tree:(xmlEnumerationPtr)tree;

    -(void)elementDeclCallBack:(nullable NSString *)name type:(int)type content:(xmlElementContentPtr)content;

    -(void)unparsedEntityDeclCallBack:(nullable NSString *)name
                             publicId:(nullable NSString *)publicId
                             systemId:(nullable NSString *)systemId
                         notationName:(nullable NSString *)notationName;

    -(void)startDocumentCallBack;

    -(void)endDocumentCallBack;

    -(void)startElementCallBack:(NSString *)name attributes:(NSArray<PGXMLParsedAttribute *> *)attributes;

    -(void)endElementCallBack:(nullable NSString *)name;

    -(void)referenceCallBack:(nullable NSString *)name;

    -(void)charactersCallBack:(NSString *)ch;

    -(void)ignorableWhitespaceCallBack:(NSString *)ch;

    -(void)processingInstructionCallBack:(nullable NSString *)target data:(nullable NSString *)data;

    -(void)commentCallBack:(nullable NSString *)value;

    -(void)cdataBlockCallBack:(NSString *)value;

    -(void)warningCallBack:(NSString *)msg;

    -(void)errorCallBack:(NSString *)msg;

    -(void)fatalErrorCallBack:(NSString *)msg;

    -(void)startElementNsCallBack:(NSString *)localname
                           prefix:(NSString *)prefix
                              URI:(NSString *)URI
                       namespaces:(NSArray<PGXMLParsedNamespace *> *)namespaces
                       attributes:(NSArray<PGXMLParsedAttribute *> *)attributes;

    -(void)endElementNsCallBack:(nullable NSString *)localname prefix:(nullable NSString *)prefix URI:(nullable NSString *)URI;

    -(void)xmlStructuredErrorCallBack:(xmlErrorPtr)error;

@end

FOUNDATION_EXPORT xmlParserInputPtr resolveEntityCallBack(void *ctx, const xmlChar *publicId, const xmlChar *systemId);

FOUNDATION_EXPORT void internalSubsetCallBack(void *ctx, const xmlChar *name, const xmlChar *ExternalID, const xmlChar *SystemID);

FOUNDATION_EXPORT void externalSubsetCallBack(void *ctx, const xmlChar *name, const xmlChar *ExternalID, const xmlChar *SystemID);

FOUNDATION_EXPORT xmlEntityPtr getEntityCallBack(void *ctx, const xmlChar *name);

FOUNDATION_EXPORT xmlEntityPtr getParameterEntityCallBack(void *ctx, const xmlChar *name);

FOUNDATION_EXPORT void entityDeclCallBack(void *ctx, const xmlChar *name, int type, const xmlChar *publicId, const xmlChar *systemId, xmlChar *content);

FOUNDATION_EXPORT void notationDeclCallBack(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId);

FOUNDATION_EXPORT void attributeDeclCallBack(void *ctx, const xmlChar *elem, const xmlChar *fullname, int type, int def, const xmlChar *defaultValue, xmlEnumerationPtr tree);

FOUNDATION_EXPORT void elementDeclCallBack(void *ctx, const xmlChar *name, int type, xmlElementContentPtr content);

FOUNDATION_EXPORT void unparsedEntityDeclCallBack(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId, const xmlChar *notationName);

FOUNDATION_EXPORT void startDocumentCallBack(void *ctx);

FOUNDATION_EXPORT void endDocumentCallBack(void *ctx);

FOUNDATION_EXPORT void startElementCallBack(void *ctx, const xmlChar *name, const xmlChar **atts);

FOUNDATION_EXPORT void endElementCallBack(void *ctx, const xmlChar *name);

FOUNDATION_EXPORT void referenceCallBack(void *ctx, const xmlChar *name);

FOUNDATION_EXPORT void charactersCallBack(void *ctx, const xmlChar *ch, int len);

FOUNDATION_EXPORT void ignorableWhitespaceCallBack(void *ctx, const xmlChar *ch, int len);

FOUNDATION_EXPORT void processingInstructionCallBack(void *ctx, const xmlChar *target, const xmlChar *data);

FOUNDATION_EXPORT void commentCallBack(void *ctx, const xmlChar *value);

FOUNDATION_EXPORT void cdataBlockCallBack(void *ctx, const xmlChar *value, int len);

FOUNDATION_EXPORT void warningCallBack(void *ctx, const char *msg, ...);

FOUNDATION_EXPORT void errorCallBack(void *ctx, const char *msg, ...);

FOUNDATION_EXPORT void fatalErrorCallBack(void *ctx, const char *msg, ...);

FOUNDATION_EXPORT void startElementNsCallBack(void *ctx,
                                              const xmlChar *localname,
                                              const xmlChar *prefix,
                                              const xmlChar *URI,
                                              int nb_namespaces,
                                              const xmlChar **namespaces,
                                              int nb_attributes,
                                              int nb_defaulted,
                                              const xmlChar **attributes);

FOUNDATION_EXPORT void endElementNsCallBack(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);

FOUNDATION_EXPORT void xmlStructuredErrorCallBack(void *ctx, xmlErrorPtr error);

NS_ASSUME_NONNULL_END

#endif //__PGXMLPARSERTOOLS_H__
