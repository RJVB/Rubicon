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

@class PGXMLParserInput;

NS_ASSUME_NONNULL_BEGIN

/* @f:0 */
typedef void             (*PGXMLFoundNoteDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable);
typedef void           (*PGXMLFoundUnpEntDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable, NSString *_Nullable);
typedef void             (*PGXMLFoundAttrDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *,          NSString *_Nullable, NSString *_Nullable);
typedef void             (*PGXMLFoundElemDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef void           (*PGXMLFoundIntEntDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef void           (*PGXMLFoundExtEntDeclFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable);
typedef void               (*PGXMLDidStartDocFunc_t)(id, SEL, PGXMLParser *);
typedef void                 (*PGXMLDidEndDocFunc_t)(id, SEL, PGXMLParser *);

typedef void              (*PGXMLDidStartElemFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable, NSArray<PGXMLParserAttribute *> *);
typedef void                (*PGXMLDidEndElemFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable, NSString *_Nullable);
typedef void            (*PGXMLDidStartMapPfxFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *);
typedef void              (*PGXMLDidEndMapPfxFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void                (*PGXMLFoundCharsFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void            (*PGXMLFoundIgWhitespFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void             (*PGXMLFoundProcInstFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef void              (*PGXMLFoundCommentFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef void                (*PGXMLFoundCDATAFunc_t)(id, SEL, PGXMLParser *,   NSData *);
typedef void                  (*PGXMLParseErrFunc_t)(id, SEL, PGXMLParser *,  NSError *);
typedef void             (*PGXMLValidationErrFunc_t)(id, SEL, PGXMLParser *,  NSError *);
typedef NSData *_Nullable(*PGXMLResolveExtEntFunc_t)(id, SEL, PGXMLParser *, NSString *, NSString *_Nullable);
typedef NSString *_Nullable(*PGXMLReslvIntEntFunc_t)(id, SEL, PGXMLParser *, NSString *);
typedef NSInteger           (*NSInputStreamReadFunc)(id, SEL, uint8_t *, NSUInteger);
/* @f:1 */

@interface PGXMLParser()

    @property(nullable) /* */ PGXMLFoundNoteDeclFunc_t   foundNoteDeclFunc;
    @property(nullable) /* */ PGXMLFoundUnpEntDeclFunc_t foundUnpEntDeclFunc;
    @property(nullable) /* */ PGXMLFoundAttrDeclFunc_t   foundAttrDeclFunc;
    @property(nullable) /* */ PGXMLFoundElemDeclFunc_t   foundElemDeclFunc;
    @property(nullable) /* */ PGXMLFoundIntEntDeclFunc_t foundIntEntDeclFunc;
    @property(nullable) /* */ PGXMLFoundExtEntDeclFunc_t foundExtEntDeclFunc;
    @property(nullable) /* */ PGXMLDidStartDocFunc_t     didStartDocFunc;
    @property(nullable) /* */ PGXMLDidEndDocFunc_t       didEndDocFunc;
    @property(nullable) /* */ PGXMLDidStartElemFunc_t    didStartElemFunc;
    @property(nullable) /* */ PGXMLDidEndElemFunc_t      didEndElemFunc;
    @property(nullable) /* */ PGXMLDidStartMapPfxFunc_t  didStartMapPfxFunc;
    @property(nullable) /* */ PGXMLDidEndMapPfxFunc_t    didEndMapPfxFunc;
    @property(nullable) /* */ PGXMLFoundCharsFunc_t      foundCharsFunc;
    @property(nullable) /* */ PGXMLFoundIgWhitespFunc_t  foundIgnWhitespFunc;
    @property(nullable) /* */ PGXMLFoundProcInstFunc_t   foundProcInstFunc;
    @property(nullable) /* */ PGXMLFoundCommentFunc_t    foundCommentFunc;
    @property(nullable) /* */ PGXMLFoundCDATAFunc_t      foundCDATAFunc;
    @property(nullable) /* */ PGXMLParseErrFunc_t        parseErrFunc;
    @property(nullable) /* */ PGXMLValidationErrFunc_t   validationErrFunc;
    @property(nullable) /* */ PGXMLResolveExtEntFunc_t   reslvExtEntFunc;
    @property(nullable) /* */ PGXMLReslvIntEntFunc_t     reslvIntEntFunc;
    @property(nullable) /* */ PGXMLReslvIntEntFunc_t     reslvIntPEntFunc;

    @property(nullable) /* */ xmlParserCtxtPtr      ctx;
    @property(nullable) /* */ xmlSAXHandlerPtr      saxHandler;
    @property(nullable) /* */ NSError               *parserError;
    @property(readonly) /* */ NSInputStream         *input;
    @property(readonly) /* */ NSInputStreamReadFunc readFunc;
    @property(copy, nullable) NSURL                 *url;
    @property(copy, nullable) NSString              *publicId;
    @property(copy, nullable) NSString              *systemId;

    @property(readonly) /* */ NSMutableDictionary<NSString *, PGXMLParsedEntity *> *entities;
    @property(readonly) /* */ NSMutableDictionary<NSString *, PGXMLParsedEntity *> *paramEntities;
    @property(readonly) /* */ PGStack<NSArray<PGXMLParsedNamespace *> *>           *namespaceStack;
    @property(readonly) /* */ NSMutableArray<PGXMLParserInput *>                   *inputs;
    @property(readonly) /* */ NSArray<NSString *>                                  *typeNames;
    @property(readonly) /* */ PGLogger                                             *logger;
    @property /*           */ BOOL                                                 hasRun;

#pragma mark Constructors and Destructors

    -(instancetype)init NS_DESIGNATED_INITIALIZER;

#pragma mark Helper Methods

    -(xmlEntityPtr)updateEntityForName:(NSString *)name content:(NSString *)content;

    -(NSURL *)urlForPublicID:(NSString *)publicID systemID:(NSString *)systemID;

    -(PGXMLParsedEntity *)getExistingEntityForName:(NSString *)name;

    -(xmlParserInputPtr)localResolveEntityForPublicID:(NSString *)publicID systemID:(NSString *)systemID;

    -(xmlParserInputPtr)xmlParserInputPtrFromData:(NSData *)data;

    -(void)extractEntitiesFromDTDAtURL:(NSURL *)url externalID:(NSString *)externalID;

    -(void)handleSubset:(NSString *)desc name:(NSString *)name externalID:(NSString *)externalID systemID:(NSString *)systemID;

    -(NSString *)getKeyForName:(NSString *)name andType:(int)type;

    -(void)startMappingPrefixes:(NSArray<PGXMLParsedNamespace *> *)namespaces hasImpl:(BOOL *)hasImpl;

    -(void)endMappingPrefixes:(NSArray<PGXMLParsedNamespace *> *)namespaces hasImpl:(BOOL *)hasImpl;

#pragma mark libxml2 Callback Handlers

    -(xmlParserInputPtr)resolveEntityCallBack:(NSString *)publicID systemID:(NSString *)systemID;

    -(PGXMLParserInput *)getNewParserInputForData:(NSData *)data;

    -(void)internalSubsetCallBack:(NSString *)name externalID:(NSString *)externalID systemID:(NSString *)systemID;

    -(void)externalSubsetCallBack:(NSString *)name externalID:(NSString *)externalID systemID:(NSString *)systemID;

    -(xmlEntityPtr)getEntityCallBack:(nullable NSString *)name;

    -(xmlEntityPtr)getParameterEntityCallBack:(nullable NSString *)name;

    -(void)entityDeclCallBack:(NSString *)name type:(int)type publicID:(NSString *)publicID systemID:(NSString *)systemID content:(NSString *)content;

    -(void)notationDeclCallBack:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;

    -(void)attributeDeclCallBack:(nullable NSString *)elem
                        fullname:(nullable NSString *)fullname
                            type:(int)type
                             def:(int)def
                    defaultValue:(nullable NSString *)defaultValue
                            tree:(xmlEnumerationPtr)tree;

    -(void)elementDeclCallBack:(nullable NSString *)name type:(int)type content:(xmlElementContentPtr)content;

    -(void)unparsedEntityDeclCallBack:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName;

    -(void)startDocumentCallBack;

    -(void)endDocumentCallBack;

    -(void)startElementCallBack:(NSString *)name attributes:(NSArray<PGXMLParserAttribute *> *)attributes;

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
                       namespaces:(NSArray<PGXMLParsedNamespace *> *)namespaces attributes:(NSArray<PGXMLParserAttribute *> *)attributes;

    -(void)endElementNsCallBack:(NSString *)localname prefix:(NSString *)prefix namespaceURI:(NSString *)namespaceURI;

    -(void)xmlStructuredErrorCallBack:(xmlErrorPtr)error;

#pragma mark libxml setup and tear-down

    -(void)setupSAXHandlerStructure;

    -(void)destroySAXHandlerStructure;

    -(void)destroyParserContext;

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
    -(void)_didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSArray<PGXMLParserAttribute *> *)attributeDict hasImpl:(BOOL *)hasImpl;
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
    -(nullable NSString *)_resolveInternalParameterEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl;
    // @f:1

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGXMLPARSER_PGXMLPARSEREXTENSIONS_H
