/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParserDelegateTest.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/7/18
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

#import "PGXMLParserDelegateTest.h"

@implementation PGXMLParserDelegateTest {
        PGLogger *log;
    }

    -(instancetype)init {
        self = [super init];

        if(self) {
            log = [PGLogger sharedInstanceWithClass:self.class];
        }

        return self;
    }

    -(nullable NSString *)parser:(PGXMLParser *)parser resolveInternalEntityForName:(NSString *)name {
        return nil;
    }

    -(nullable NSData *)parser:(PGXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(nullable NSString *)systemID {
        return nil;
    }

    -(void)parser:(PGXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID {
    }

    -(void)                     parser:(PGXMLParser *)parser
foundUnparsedEntityDeclarationWithName:(NSString *)name
                              publicID:(nullable NSString *)publicID
                              systemID:(nullable NSString *)systemID
                          notationName:(nullable NSString *)notationName {
    }

    -(void)                parser:(PGXMLParser *)parser
foundAttributeDeclarationWithName:(NSString *)attributeName
                       forElement:(NSString *)elementName
                             type:(nullable NSString *)type
                     defaultValue:(nullable NSString *)defaultValue {
    }

    -(void)parser:(PGXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
    }

    -(void)parser:(PGXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value {
    }

    -(void)parser:(PGXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID {
    }

    -(void)parserDidStartDocument:(PGXMLParser *)parser {
    }

    -(void)parserDidEndDocument:(PGXMLParser *)parser {
    }

    -(void)parser:(PGXMLParser *)parser
  didStartElement:(NSString *)elementName
     namespaceURI:(nullable NSString *)namespaceURI
    qualifiedName:(nullable NSString *)qName
       attributes:(NSArray<PGXMLParsedAttribute *> *)attributeDict {
    }

    -(void)parser:(PGXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
    }

    -(void)parser:(PGXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
    }

    -(void)parser:(PGXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
    }

    -(void)parser:(PGXMLParser *)parser foundCharacters:(NSString *)string {
    }

    -(void)parser:(PGXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
    }

    -(void)parser:(PGXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(nullable NSString *)data {
    }

    -(void)parser:(PGXMLParser *)parser foundComment:(NSString *)comment {
    }

    -(void)parser:(PGXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    }

    -(void)parser:(PGXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    }

    -(void)parser:(PGXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    }

@end
