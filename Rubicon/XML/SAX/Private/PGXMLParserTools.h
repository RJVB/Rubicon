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

#import "PGXMLParsedNamespace.h"

@class PGXMLParsedEntity;

NS_ASSUME_NONNULL_BEGIN

#define CASTASPARSER(p)  (PG_BRDG_CAST(PGXMLParser)(p))
#define PG_DEF_BUF_SZ ((size_t)(128))

FOUNDATION_EXPORT NSString *const PGXMLMsg01;
FOUNDATION_EXPORT NSString *const PGXMLKeyFormat;
FOUNDATION_EXPORT NSString *const PGXMLInsideCallbackMsg;

typedef PGXMLParser *__unsafe_unretained BridgedParserPtr;

NS_INLINE BOOL setImplFlag(BOOL *pbool, BOOL flag) {
    if(pbool) (*pbool) = flag;
    return flag;
}

NS_INLINE NSString *createQName(NSString *localname, NSString *_Nullable prefix) {
    return (prefix.length ? PGFormat(@"%@:%@", prefix, localname) : localname);
}

/**
 * In theory the libxml2 strings are simply UTF-8 encoded, null terminated C strings so the following
 * should be all that is needed to convert from xmlChar to NSString.
 *
 * @param xmlstr the C string based on xmlChar
 * @return an instance of NSString.
 */
FOUNDATION_EXPORT NSString *_Nullable stringForXMLString(const xmlChar *_Nullable xmlstr);

/**
 * In theory the libxml2 strings are simply UTF-8 encoded, null terminated C strings so the following
 * should be all that is needed to convert from xmlChar to NSString.
 *
 * @param xmlstr the C string based on xmlChar
 * @param len the length of the C string.
 * @return an instance of NSString.
 */
FOUNDATION_EXPORT NSString *_Nullable stringForXMLStringLen(const xmlChar *_Nullable xmlstr, size_t len);

FOUNDATION_EXPORT NSError *createError(NSInteger code, NSString *description);

FOUNDATION_EXPORT void entityHashScanner(void *payload, void *data, xmlChar *name);

FOUNDATION_EXPORT BOOL createPushContext(PGXMLParser *parser, const void *buffer, NSInteger bytesRead, const char *filename);

FOUNDATION_EXPORT BOOL parseChunk(xmlParserCtxtPtr ctx, const void *buffer, NSInteger bcount, BOOL terminate, BOOL success, NSError **error);

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
