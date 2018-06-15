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

    -(void)parser:(PGXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; Pubic ID: \"%@\"; System ID: \"%@\"", @"foundNotationDeclarationWithName", name, publicID, systemID];
    }

    -(void)                     parser:(PGXMLParser *)parser
foundUnparsedEntityDeclarationWithName:(NSString *)name
                              publicID:(nullable NSString *)publicID
                              systemID:(nullable NSString *)systemID
                          notationName:(nullable NSString *)notationName {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; Public ID: \"%@\"; System ID: \"%@\"; Notation Name: \"%@\"",
                   @"foundUnparsedEntityDeclarationWithName",
                   name,
                   publicID,
                   systemID,
                   notationName];
    }

    -(void)                parser:(PGXMLParser *)parser
foundAttributeDeclarationWithName:(NSString *)attributeName
                       forElement:(NSString *)elementName
                             type:(nullable NSString *)type
                     defaultValue:(nullable NSString *)defaultValue {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; Element: \"%@\"; Type: \"%@\"; Default Value: \"%@\"",
                   @"foundAttributeDeclarationWithName",
                   attributeName,
                   elementName,
                   type,
                   defaultValue];
    }

    -(void)parser:(PGXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; Model: \"%@\"", @"foundElementDeclarationWithName", elementName, model];
    }

    -(void)parser:(PGXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; Value: \"%@\"", @"foundInternalEntityDeclarationWithName", name, value];
    }

    -(void)parser:(PGXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; Pubic ID: \"%@\"; System ID: \"%@\"", @"foundExternalEntityDeclarationWithName", name, publicID, systemID];
    }

    -(void)parserDidStartDocument:(PGXMLParser *)parser {
        [log debug:@"Inside Callback \"%@\"", @"didStartDocument"];
    }

    -(void)parserDidEndDocument:(PGXMLParser *)parser {
        [log debug:@"Inside Callback \"%@\"", @"didEndDocument"];
    }

    -(void)parser:(PGXMLParser *)parser
  didStartElement:(NSString *)elementName
     namespaceURI:(nullable NSString *)namespaceURI
    qualifiedName:(nullable NSString *)qName
       attributes:(NSArray<PGXMLParsedAttribute *> *)attributeDict {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; URI: \"%@\"; Qualified Name: \"%@\"", @"didStartElement", elementName, namespaceURI, qName];

        for(PGXMLParsedAttribute *attr in attributeDict) {
            [log debug:@"    attr> Local Name: \"%@\"; Prefix: \"%@\"; URI: \"%@\"; Value: \"%@\"; Is Defaulted: \"%@\"",
                       attr.localName,
                       attr.prefix,
                       attr.URI,
                       attr.value,
                       (attr.isDefaulted ? @"YES" : @"NO")];
        }
    }

    -(void)parser:(PGXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; URI: \"%@\"; Qualified Name: \"%@\"", @"didEndElement", elementName, namespaceURI, qName];
    }

    -(void)parser:(PGXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
        [log debug:@"Inside Callback \"%@\"; Prefix: \"%@\"; URI: \"%@\"", @"didStartMappingPrefix", prefix, namespaceURI];
    }

    -(void)parser:(PGXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
        [log debug:@"Inside Callback \"%@\"; Prefix: \"%@\"", @"didEndMappingPrefix", prefix];
    }

    -(void)parser:(PGXMLParser *)parser foundCharacters:(NSString *)string {
        [log debug:@"Inside Callback \"%@\"; Chars: \"%@\"", @"foundCharacters", string.stringByReplacingControlCharsAndSpcs];
    }

    -(nullable NSString *)parser:(PGXMLParser *)parser resolveInternalEntityForName:(NSString *)name {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"", @"resolveInternalEntityForName", name];
        return nil;
    }

    -(void)parser:(PGXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
        [log debug:@"Inside Callback \"%@\"; String: \"%@\"", @"foundIgnorableWhitespace", whitespaceString.stringByReplacingControlCharsAndSpcs];
    }

    -(void)parser:(PGXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(nullable NSString *)data {
        [log debug:@"Inside Callback \"%@\"; Target: \"%@\"; Data: \"%@\"", @"foundProcessingInstructionWithTarget", target, data];
    }

    -(void)parser:(PGXMLParser *)parser foundComment:(NSString *)comment {
        [log debug:@"Inside Callback \"%@\"; Comment: \"%@\"", @"foundComment", comment];
    }

    -(void)parser:(PGXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
        [log debug:@"Inside Callback \"%@\"; CDATA Block: \"%@\"", @"foundCDATA", CDATABlock];
    }

    -(nullable NSData *)parser:(PGXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(nullable NSString *)systemID {
        [log debug:@"Inside Callback \"%@\"; Name: \"%@\"; System ID: \"%@\"", @"resolveExternalEntityName", name, systemID];
        return nil;
    }

    -(void)parser:(PGXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
        [log debug:@"Inside Callback \"%@\"; Error: \"%@\"", @"parseErrorOccurred", [parseError description]];
    }

    -(void)parser:(PGXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
        [log debug:@"Inside Callback \"%@\"; Error: \"%@\"", @"validationErrorOccurred", [validationError description]];
    }

@end
