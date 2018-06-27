/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNSXMLParserDelegateTest.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/21/18
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

#import "PGNSXMLParserDelegateTest.h"
#import "NSString+PGString.h"
#import <Rubicon/PGLogger.h>

@implementation PGNSXMLParserDelegateTest {
        PGLogger *_logger;
    }

    -(instancetype)init {
        self = [super init];

        if(self) {
            _logger = [PGLogger sharedInstanceWithClass:self.class];
        }

        return self;
    }

    -(void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {
        [_logger debug:@"Inside Callback \"%@\"; elementName: \"%@\"; model: \"%@\"", NSStringFromSelector(_cmd), elementName, model];
    }

    -(void)parserDidStartDocument:(NSXMLParser *)parser {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parserDidEndDocument:(NSXMLParser *)parser {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)                     parser:(NSXMLParser *)parser
foundUnparsedEntityDeclarationWithName:(NSString *)name
                              publicID:(nullable NSString *)publicID
                              systemID:(nullable NSString *)systemID
                          notationName:(nullable NSString *)notationName {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)                parser:(NSXMLParser *)parser
foundAttributeDeclarationWithName:(NSString *)attributeName
                       forElement:(NSString *)elementName
                             type:(nullable NSString *)type
                     defaultValue:(nullable NSString *)defaultValue {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser
  didStartElement:(NSString *)elementName
     namespaceURI:(nullable NSString *)namespaceURI
    qualifiedName:(nullable NSString *)qName
       attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"; characters: \"%@\"", s, string.stringByReplacingControlCharsAndSpcs];
    }

    -(void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(nullable NSString *)data {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
    }

    -(nullable NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(nullable NSString *)systemID {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"", s];
        return nil;
    }

    -(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"; Error: %@", s, parseError.description];
    }

    -(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
        NSString *s = NSStringFromSelector(_cmd);
        [_logger debug:@"Inside Callback \"%@\"; Error: %@", s, validationError.description];
    }

@end
