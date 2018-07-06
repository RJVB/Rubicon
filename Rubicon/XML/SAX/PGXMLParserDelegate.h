/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParserDelegate.h
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

#ifndef RUBICON_PGXMLPARSERDELEGATE_H
#define RUBICON_PGXMLPARSERDELEGATE_H

#import <Rubicon/PGTools.h>
#import <Rubicon/PGXMLParserAttribute.h>

NS_ASSUME_NONNULL_BEGIN

@class PGXMLParser;

@protocol PGXMLParserDelegate<NSObject>

  @optional
// @f:0
#pragma mark DTD handling methods for various declarations.

    /**
     * Sent when the parser encounters a notation declaration in the DTD.
     *
     * @param parser ...
     * @param name ...
     * @param publicID ...
     * @param systemID ...
     */
    -(void)parser:(PGXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID;

    /**
     * Sent when the parser encounters an unparsed entity declaration in the DTD.
     *
     * @param parser ...
     * @param name ...
     * @param publicID ...
     * @param systemID ...
     * @param notationName ...
     */
    -(void)parser:(PGXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID notationName:(nullable NSString *)notationName;

    /**
     * Sent when the parser encounters an attribute declaration in the DTD.
     *
     * @param parser ...
     * @param attributeName ...
     * @param elementName ...
     * @param type ...
     * @param defaultValue ...
     */
    -(void)parser:(PGXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(nullable NSString *)type defaultValue:(nullable NSString *)defaultValue;

    /**
     * Sent when the parser encounters an element declaration in the DTD.
     *
     * @param parser ...
     * @param elementName ...
     * @param model ...
     */
    -(void)parser:(PGXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;

    /**
     * Sent when the parser encounters an internal entity declaration in the DTD.
     *
     * @param parser ...
     * @param name ...
     * @param value ...
     */
    -(void)parser:(PGXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value;

    /**
     * Sent when the parser encounters an external entity declaration in the DTD.
     *
     * @param parser ...
     * @param name ...
     * @param publicID ...
     * @param systemID ...
     */
    -(void)parser:(PGXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID;

#pragma mark Document handling methods...

    /**
     * Sent when the parser begins parsing of the document.
     *
     * @param parser the parser.
     */
    -(void)parserDidStartDocument:(PGXMLParser *)parser;

    /**
     * Sent when the parser has completed parsing. If this is encountered, the parse was successful.
     *
     * @param parser ...
     */
    -(void)parserDidEndDocument:(PGXMLParser *)parser;

    /**
     * Sent when the parser encounters an element start tag.
     *
     * In the case of the cvslog tag, the following is what the delegate receives:
     *   elementName == cvslog, namespaceURI == http: *xml.apple.com/cvslog, qualifiedName == cvslog
     *
     * In the case of the radar tag, the following is what's passed in:
     *    elementName == radar, namespaceURI == http: *xml.apple.com/radar, qualifiedName == radar:radar
     *
     * If namespace processing >isn't< on, the xmlns:radar="http: *xml.apple.com/radar" is returned as an
     * attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.
     *
     * @param parser ...
     * @param elementName ...
     * @param namespaceURI ...
     * @param qName ...
     * @param attributeDict ...
     */
    -(void)parser:(PGXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSArray<PGXMLParserAttribute *> *)attributeDict;

    /**
     * Sent when an end tag is encountered. The various parameters are supplied as above.
     *
     * @param parser ...
     * @param elementName ...
     * @param namespaceURI ...
     * @param qName ...
     */
    -(void)parser:(PGXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName;

    /**
     * Sent when the parser first sees a namespace attribute.
     *
     * In the case of the cvslog tag, before the didStartElement:, you'd get one of these with
     * prefix == @"" and namespaceURI == @"http: *xml.apple.com/cvslog" (i.e. the default namespace)
     *
     * In the case of the radar:radar tag, before the didStartElement: you'd get one of these with
     * prefix == @"radar" and namespaceURI == @"http: *xml.apple.com/radar"
     *
     * @param parser ...
     * @param prefix ...
     * @param namespaceURI ...
     */
    -(void)parser:(PGXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI;

    /**
     * Sent when the namespace prefix in question goes out of scope.
     *
     * @param parser ...
     * @param prefix ...
     */
    -(void)parser:(PGXMLParser *)parser didEndMappingPrefix:(NSString *)prefix;

    /**
     * This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
     * The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
     *
     * @param parser ...
     * @param string ...
     */
    -(void)parser:(PGXMLParser *)parser foundCharacters:(NSString *)string;

    /**
     * Sent when the parser encounters an entity which it needs to resolve.
     *
     * @param parser ...
     * @param name ...
     * @returns the resolved entity.
     */
    -(nullable NSString *)parser:(PGXMLParser *)parser resolveInternalEntityForName:(NSString *)name;

    /**
     * Sent when the parser encounters an entity which it needs to resolve.
     *
     * @param parser ...
     * @param name ...
     * @returns the resolved entity.
     */
    -(nullable NSString *)parser:(PGXMLParser *)parser resolveInternalParameterEntityForName:(NSString *)name;

    /**
     * The parser reports ignorable whitespace in the same way as characters it's found.
     *
     * @param parser ...
     * @param whitespaceString ...
     */
    -(void)parser:(PGXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;

    /**
     * The parser reports a processing instruction to you using this method. In the case above,
     * target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"
     *
     * @param parser ...
     * @param target ...
     * @param data ...
     */
    -(void)parser:(PGXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(nullable NSString *)data;

    /**
     * A comment (Text in a <!-- --> block) is reported to the delegate as a single string
     *
     * @param parser ...
     * @param comment ...
     */
    -(void)parser:(PGXMLParser *)parser foundComment:(NSString *)comment;

    /**
     * This reports a CDATA block to the delegate as an NSData.
     *
     * @param parser ...
     * @param CDATABlock ...
     */
    -(void)parser:(PGXMLParser *)parser foundCDATA:(NSData *)CDATABlock;

    /**
     * This gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.
     *
     * @param parser ...
     * @param name ...
     * @param systemID ...
     * @return ...
     */
    -(nullable NSData *)parser:(PGXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(nullable NSString *)systemID;

#pragma mark Error Handling

    /**
     * ...and this reports a fatal error to the delegate. The parser will stop parsing.
     *
     * @param parser ...
     * @param parseError ...
     */
    -(void)parser:(PGXMLParser *)parser parseErrorOccurred:(NSError *)parseError;

    /**
     * If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.
     *
     * @param parser ...
     * @param validationError ...
     */
    -(void)parser:(PGXMLParser *)parser validationErrorOccurred:(NSError *)validationError;

// @f:1
@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGXMLPARSERDELEGATE_H
