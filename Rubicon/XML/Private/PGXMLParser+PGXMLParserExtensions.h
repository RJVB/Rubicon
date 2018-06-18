/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParser+PGXMLParserExtensions.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/30/18
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

#ifndef RUBICON_PGXMLPARSER_PGXMLPARSEREXTENSIONS_H
#define RUBICON_PGXMLPARSER_PGXMLPARSEREXTENSIONS_H

#import "PGXMLParser.h"
#import "PGXMLParserTools.h"

NS_ASSUME_NONNULL_BEGIN

/* @f:0 */
typedef void    (*PGXMLFoundNoteDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable);
typedef void  (*PGXMLFoundUnpEntDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef void    (*PGXMLFoundAttrDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *,          NSString *_Nullable, NSString *_Nullable);
typedef void    (*PGXMLFoundElemDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef void  (*PGXMLFoundIntEntDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef void  (*PGXMLFoundExtEntDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable);
typedef void      (*PGXMLDidStartDocFunc_t)(id, SEL, PGXMLParser *);
typedef void        (*PGXMLDidEndDocFunc_t)(id, SEL, PGXMLParser *);
typedef void     (*PGXMLDidStartElemFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable, NSArray<PGXMLParsedAttribute *> *);
typedef void       (*PGXMLDidEndElemFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable);
typedef void   (*PGXMLDidStartMapPfxFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *);
typedef void     (*PGXMLDidEndMapPfxFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void       (*PGXMLFoundCharsFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void   (*PGXMLFoundIgWhitespFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void    (*PGXMLFoundProcInstFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef void     (*PGXMLFoundCommentFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void       (*PGXMLFoundCDATAFunc_t)(id, SEL, PGXMLParser *,   NSData *);
typedef NSData *(*PGXMLResolveExtEntFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef void         (*PGXMLParseErrFunc_t)(id, SEL, PGXMLParser *,  NSError *);
typedef void    (*PGXMLValidationErrFunc_t)(id, SEL, PGXMLParser *,  NSError *);
typedef NSString *(*PGXMLReslvIntEntFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef NSInteger        (*NSInputStreamReadFunc)(id, SEL, uint8_t *, NSUInteger);
/* @f:1 */

@interface PGXMLParser()

    @property(nullable) /* */ PGXMLFoundNoteDeclFunc_t                             foundNoteDeclFunc;
    @property(nullable) /* */ PGXMLFoundUnpEntDeclFunc_t                           foundUnpEntDeclFunc;
    @property(nullable) /* */ PGXMLFoundAttrDeclFunc_t                             foundAttrDeclFunc;
    @property(nullable) /* */ PGXMLFoundElemDeclFunc_t                             foundElemDeclFunc;
    @property(nullable) /* */ PGXMLFoundIntEntDeclFunc_t                           foundIntEntDeclFunc;
    @property(nullable) /* */ PGXMLFoundExtEntDeclFunc_t                           foundExtEntDeclFunc;
    @property(nullable) /* */ PGXMLDidStartDocFunc_t                               didStartDocFunc;
    @property(nullable) /* */ PGXMLDidEndDocFunc_t                                 didEndDocFunc;
    @property(nullable) /* */ PGXMLDidStartElemFunc_t                              didStartElemFunc;
    @property(nullable) /* */ PGXMLDidEndElemFunc_t                                didEndElemFunc;
    @property(nullable) /* */ PGXMLDidStartMapPfxFunc_t                            didStartMapPfxFunc;
    @property(nullable) /* */ PGXMLDidEndMapPfxFunc_t                              didEndMapPfxFunc;
    @property(nullable) /* */ PGXMLFoundCharsFunc_t                                foundCharsFunc;
    @property(nullable) /* */ PGXMLFoundIgWhitespFunc_t                            foundIgnWhitespFunc;
    @property(nullable) /* */ PGXMLFoundProcInstFunc_t                             foundProcInstFunc;
    @property(nullable) /* */ PGXMLFoundCommentFunc_t                              foundCommentFunc;
    @property(nullable) /* */ PGXMLFoundCDATAFunc_t                                foundCDATAFunc;
    @property(nullable) /* */ PGXMLResolveExtEntFunc_t                             resolveExtEntFunc;
    @property(nullable) /* */ PGXMLParseErrFunc_t                                  parseErrFunc;
    @property(nullable) /* */ PGXMLValidationErrFunc_t                             validationErrFunc;
    @property(nullable) /* */ PGXMLReslvIntEntFunc_t                               reslvIntEntFunc;
    @property /*           */ BOOL                                                 hasRun;
    @property(nullable) /* */ xmlParserCtxtPtr                                     ctx;
    @property(nullable) /* */ xmlSAXHandlerPtr                                     saxHandler;
    @property(nullable) /* */ NSError                                              *parserError;
    @property(readonly) /* */ NSRecursiveLock                                      *lck;
    @property /*           */ NSInputStream                                        *input;
    @property /*           */ NSInputStreamReadFunc                                readFunc;
    @property(copy, nullable) NSURL                                                *url;
    @property(copy, nullable) NSString                                             *publicId;
    @property(copy, nullable) NSString                                             *systemId;
    @property(readonly) /* */ NSMutableDictionary<NSString *, PGXMLParsedEntity *> *entities;
    @property(readonly) /* */ PGStack<NSArray<PGXMLParsedNamespace *> *>           *namespaceStack;

    -(instancetype)init NS_DESIGNATED_INITIALIZER;

    -(void)destroySAXHandlerStructure;

    -(void)setupSAXHandlerStructure;

    -(BOOL)openInputStream;

    -(NSError *)getInputStreamError;

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

    -(void)startMappingPrefixes:(NSArray<PGXMLParsedNamespace *> *)namespaces hasImpl:(BOOL *)hasImpl;

    -(void)endMappingPrefixes:(NSArray<PGXMLParsedNamespace *> *)namespaces hasImpl:(BOOL *)hasImpl;

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

@interface PGXMLParser(PGXMLParserExtensions)

    +(void)setSelectors;

    -(void)updateDelegateFunctions:(NSObject<PGXMLParserDelegate> *)d;

    // @f:0
    -(void)_foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID hasImpl:(BOOL *)hasImpl;
    -(void)_foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID notationName:(nullable NSString *)notationName hasImpl:(BOOL *)hasImpl;
    -(void)_foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(nullable NSString *)type defaultValue:(nullable NSString *)defaultValue hasImpl:(BOOL *)hasImpl;
    -(void)_foundElementDeclarationWithName:(NSString *)elementName model:(nullable NSString *)model hasImpl:(BOOL *)hasImpl;
    -(void)_foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value hasImpl:(BOOL *)hasImpl;
    -(void)_foundExternalEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID hasImpl:(BOOL *)hasImpl;
    -(void)_didStartDocument:(BOOL *)hasImpl;
    -(void)_didEndDocument:(BOOL *)hasImpl;
    -(void)_didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSArray<PGXMLParsedAttribute *> *)attributeDict hasImpl:(BOOL *)hasImpl;
    -(void)_didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName hasImpl:(BOOL *)hasImpl;
    -(void)_didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI hasImpl:(BOOL *)hasImpl;
    -(void)_didEndMappingPrefix:(NSString *)prefix hasImpl:(BOOL *)hasImpl;
    -(void)_foundCharacters:(NSString *)string hasImpl:(BOOL *)hasImpl;
    -(void)_foundIgnorableWhitespace:(NSString *)whitespaceString hasImpl:(BOOL *)hasImpl;
    -(void)_foundProcessingInstructionWithTarget:(NSString *)target data:(nullable NSString *)data hasImpl:(BOOL *)hasImpl;
    -(void)_foundComment:(NSString *)comment hasImpl:(BOOL *)hasImpl;
    -(void)_foundCDATA:(NSData *)CDATABlock hasImpl:(BOOL *)hasImpl;
    -(void)_parseErrorOccurred:(NSError *)parseError hasImpl:(BOOL *)hasImpl;
    -(void)_validationErrorOccurred:(NSError *)validationError hasImpl:(BOOL *)hasImpl;
    -(nullable NSData *)_resolveExternalEntityForName:(NSString *)name systemID:(nullable NSString *)systemID hasImpl:(BOOL *)hasImpl;
    -(nullable NSString *)_resolveInternalEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl;
    // @f:1

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGXMLPARSER_PGXMLPARSEREXTENSIONS_H
