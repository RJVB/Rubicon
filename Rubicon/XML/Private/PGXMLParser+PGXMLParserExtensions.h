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

NS_ASSUME_NONNULL_BEGIN

@interface PGXMLParser(PGXMLParserExtensions)

    +(void)setSelectors;

    -(void)updateDelegateFunctions:(id<PGXMLParserDelegate>)d;

    // @f:0
    -(void)_foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID hasImpl:(BOOL *)hasImpl;
    -(void)_foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID notationName:(nullable NSString *)notationName hasImpl:(BOOL *)hasImpl;
    -(void)_foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(nullable NSString *)type defaultValue:(nullable NSString *)defaultValue hasImpl:(BOOL *)hasImpl;
    -(void)_foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model hasImpl:(BOOL *)hasImpl;
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
