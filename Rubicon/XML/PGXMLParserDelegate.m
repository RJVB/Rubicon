/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParserDelegate.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/23/18
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

#import "PGInternal.h"

typedef NSString    *NSStrP;
typedef NSXMLParser *NSXMLParsP;

typedef NSDictionary<NSStrP, NSStrP> *NSStrDict;

@implementation PGXMLParserDelegate {
    }

    -(void)parserDidStartDocument:(NSXMLParsP)parser {
        NSLog(@"Inside %@", @"parserDidStartDocument");
    }

    -(void)parserDidEndDocument:(NSXMLParsP)parser {
        NSLog(@"Inside %@", @"parserDidEndDocument");
    }

    -(void)parser:(NSXMLParsP)parser foundNotationDeclarationWithName:(NSStrP)name publicID:(NSStrP)publicID systemID:(NSStrP)systemID {
        NSLog(@"Inside %@; name: \"%@\"; %@%@", @"foundNotationDeclarationWithName", name, PGFormat(@"; publicID: \"%@\"", publicID), PGFormat(@"; systemID: \"%@\"", systemID));
    }

    -(void)parser:(NSXMLParsP)parser foundUnparsedEntityDeclarationWithName:(NSStrP)name publicID:(NSStrP)publicID systemID:(NSStrP)systemID notationName:(NSStrP)notationName {
        NSLog(@"Inside %@; name: \"%@\"; %@%@%@",
              @"foundUnparsedEntityDeclarationWithName",
              name,
              PGFormat(@"; publicID: \"%@\"", publicID),
              PGFormat(@"; systemID: \"%@\"", systemID),
              PGFormat(@"; notationName: \"%@\"", notationName));
    }

    -(void)parser:(NSXMLParsP)parser foundAttributeDeclarationWithName:(NSStrP)attributeName forElement:(NSStrP)elementName type:(NSStrP)type defaultValue:(NSStrP)defaultValue {
        NSLog(@"Inside %@; attributeName: \"%@\"; %@%@%@",
              @"foundAttributeDeclarationWithName",
              attributeName,
              PGFormat(@"; elementName: \"%@\"", elementName),
              PGFormat(@"; type: \"%@\"", type),
              PGFormat(@"; defaultValue: \"%@\"", defaultValue));
    }

    -(void)parser:(NSXMLParsP)parser foundElementDeclarationWithName:(NSStrP)elementName model:(NSStrP)model {
        NSLog(@"Inside %@; elementName: \"%@\"; %@", @"foundElementDeclarationWithName", elementName, PGFormat(@"; model: \"%@\"", model));
    }

    -(void)parser:(NSXMLParsP)parser foundInternalEntityDeclarationWithName:(NSStrP)name value:(NSStrP)value {
        NSLog(@"Inside %@; name: \"%@\"; %@", @"foundInternalEntityDeclarationWithName", name, PGFormat(@"; value: \"%@\"", value));
    }

    -(void)parser:(NSXMLParsP)parser foundExternalEntityDeclarationWithName:(NSStrP)name publicID:(NSStrP)publicID systemID:(NSStrP)systemID {
        NSLog(@"Inside %@; name: \"%@\"; %@%@",
              @"foundExternalEntityDeclarationWithName",
              name,
              PGFormat(@"; publicID: \"%@\"", publicID),
              PGFormat(@"; systemID: \"%@\"", systemID));
    }

    -(void)parser:(NSXMLParsP)parser didStartElement:(NSStrP)elementName namespaceURI:(NSStrP)namespaceURI qualifiedName:(NSStrP)qName attributes:(NSStrDict)attributeDict {
        NSLog(@"Inside %@; elementName: \"%@\"; %@%@", @"didStartElement", elementName, PGFormat(@"; namespaceURI: \"%@\"", namespaceURI), PGFormat(@"; qName: \"%@\"", qName));
    }

    -(void)parser:(NSXMLParsP)parser didEndElement:(NSStrP)elementName namespaceURI:(NSStrP)namespaceURI qualifiedName:(NSStrP)qName {
        NSLog(@"Inside %@; elementName: \"%@\"; %@%@", @"didEndElement", elementName, PGFormat(@"; namespaceURI: \"%@\"", namespaceURI), PGFormat(@"; qName: \"%@\"", qName));
    }

    -(void)parser:(NSXMLParsP)parser didStartMappingPrefix:(NSStrP)prefix toURI:(NSStrP)namespaceURI {
        NSLog(@"Inside %@; prefix: \"%@\"; %@", @"didStartMappingPrefix", prefix, PGFormat(@"; namespaceURI: \"%@\"", namespaceURI));
    }

    -(void)parser:(NSXMLParsP)parser didEndMappingPrefix:(NSStrP)prefix {
        NSLog(@"Inside %@; prefix: \"%@\";", @"didEndMappingPrefix", prefix);
    }

    -(void)parser:(NSXMLParsP)parser foundCharacters:(NSStrP)string {
        NSLog(@"Inside %@; string: \"%@\";", @"foundCharacters", string);
    }

    -(void)parser:(NSXMLParsP)parser foundIgnorableWhitespace:(NSStrP)whitespaceString {
        NSLog(@"Inside %@; whitespaceString: \"%@\";", @"foundIgnorableWhitespace", whitespaceString);
    }

    -(void)parser:(NSXMLParsP)parser foundProcessingInstructionWithTarget:(NSStrP)target data:(NSStrP)data {
        NSLog(@"Inside %@; target: \"%@\"; %@", @"foundProcessingInstructionWithTarget", target, PGFormat(@"; data: \"%@\"", data));
    }

    -(void)parser:(NSXMLParsP)parser foundComment:(NSStrP)comment {
        NSLog(@"Inside %@; comment: \"%@\";", @"foundComment", comment);
    }

    -(void)parser:(NSXMLParsP)parser foundCDATA:(NSData *)CDATABlock {
        NSLog(@"Inside %@; CDATABlock: \"%@\"", @"foundCDATA", CDATABlock);
    }

    -(NSData *)parser:(NSXMLParsP)parser resolveExternalEntityName:(NSStrP)name systemID:(NSStrP)systemID {
        NSLog(@"Inside %@; name: \"%@\"; systemID: \"%@\";", @"resolveExternalEntityName", name, systemID);
        return nil;
    }

    -(void)parser:(NSXMLParsP)parser parseErrorOccurred:(NSError *)parseError {
        NSLog(@"Inside parseErrorOccurred; parseError: \"%@\"", parseError);
    }

    -(void)parser:(NSXMLParsP)parser validationErrorOccurred:(NSError *)validationError {
        NSLog(@"Inside validationErrorOccurred; validationError: \"%@\"", validationError);
    }

@end
