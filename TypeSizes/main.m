/************************************************************************//**
 *     PROJECT: Rubicon
 *      TARGET: TypeSizes
 *    FILENAME: main.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 08/30/18 11:03 AM
 * DESCRIPTION:
 *
 * Copyright © 2018  Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *//************************************************************************/

#import <Rubicon/Rubicon.h>

#define FMT_INSIDE @"Inside Callback> %@"
#define FMT_PARAM  @"        Param: \"%@\" = \"%@\";"

@interface MyDelegate : NSObject<PGSAXDelegate>
@end

@implementation MyDelegate {
    }

    -(void)internalSubset:(PGSAXParser *)parser name:(NSString *)name externalID:(NSString *)externalId systemID:(NSString *)systemId {
        PGLog(FMT_INSIDE, @"internalSubset");
        PGLog(FMT_PARAM, @"name", name);
        PGLog(FMT_PARAM, @"externalId", externalId);
        PGLog(FMT_PARAM, @"systemId", systemId);
    }

    -(void)externalSubset:(PGSAXParser *)parser name:(NSString *)name externalID:(NSString *)externalId systemID:(NSString *)systemId {
        PGLog(FMT_INSIDE, @"externalSubset");
        PGLog(FMT_PARAM, @"name", name);
        PGLog(FMT_PARAM, @"externalId", externalId);
        PGLog(FMT_PARAM, @"systemId", systemId);
    }

    -(BOOL)isStandalone:(PGSAXParser *)parser {
        PGLog(FMT_INSIDE, @"isStandalone");
        return NO;
    }

    -(BOOL)hasInternalSubset:(PGSAXParser *)parser {
        PGLog(FMT_INSIDE, @"hasInternalSubset");
        return NO;
    }

    -(BOOL)hasExternalSubset:(PGSAXParser *)parser {
        PGLog(FMT_INSIDE, @"hasExternalSubset");
        return NO;
    }

    -(NSString *)getEntity:(PGSAXParser *)parser name:(NSString *)name {
        return nil;
    }

    -(NSString *)getParameterEntity:(PGSAXParser *)parser name:(NSString *)name {
        PGLog(FMT_INSIDE, @"getParameterEntity");
        PGLog(FMT_PARAM, @"name", name);
        return nil;
    }

    -(NSData *)resolveEntity:(PGSAXParser *)parser publicID:(NSString *)publicId systemID:(NSString *)systemId {
        PGLog(FMT_INSIDE, @"resolveEntity");
        PGLog(FMT_PARAM, @"publicId", publicId);
        PGLog(FMT_PARAM, @"systemId", systemId);
        return nil;
    }

    -(void)entityDecl:(PGSAXParser *)parser name:(NSString *)name type:(int)type publicID:(NSString *)publicId systemID:(NSString *)systemId content:(NSString *)content {
        PGLog(FMT_INSIDE, @"entityDecl");
        PGLog(FMT_PARAM, @"name", name);
        PGLog(FMT_PARAM, @"type", @(type));
        PGLog(FMT_PARAM, @"publicId", publicId);
        PGLog(FMT_PARAM, @"systemId", systemId);
        PGLog(FMT_PARAM, @"content", content);
    }

    -(void)notationDecl:(PGSAXParser *)parser name:(NSString *)name publicID:(NSString *)publicId systemID:(NSString *)systemId {
        PGLog(FMT_INSIDE, @"notationDecl");
        PGLog(FMT_PARAM, @"name", name);
        PGLog(FMT_PARAM, @"publicId", publicId);
        PGLog(FMT_PARAM, @"systemId", systemId);
    }

    -(void)attributeDecl:(PGSAXParser *)parser attrDecl:(PGSAXAttributeDecl *)attrdecl {
        PGLog(FMT_INSIDE, @"attributeDecl");
        PGLog(FMT_PARAM, @"elem", attrdecl.element);
        PGLog(FMT_PARAM, @"name", attrdecl.fullname);
        PGLog(FMT_PARAM, @"type", PGSAXAttributeTypeName(attrdecl.attrType));
        PGLog(FMT_PARAM, @"def", PGSAXAttributeDefaultName(attrdecl.attrDefault));
        PGLog(FMT_PARAM, @"defaultValue", attrdecl.defaultValue);
    }

    -(void)elementDecl:(PGSAXParser *)parser name:(nullable NSString *)name type:(int)type content:(nullable PGSAXElementDecl *)content {
        PGLog(FMT_INSIDE, @"elementDecl");
        PGLog(FMT_PARAM, @"name", name);
        PGLog(FMT_PARAM, @"type", @(type));
    }

    -(void)unparsedEntityDecl:(PGSAXParser *)parser name:(NSString *)name publicID:(NSString *)publicId systemID:(NSString *)systemId notationName:(NSString *)notationName {
        PGLog(FMT_INSIDE, @"unparsedEntityDecl");
        PGLog(FMT_PARAM, @"name", name);
        PGLog(FMT_PARAM, @"publicId", publicId);
        PGLog(FMT_PARAM, @"systemId", systemId);
        PGLog(FMT_PARAM, @"notationName", notationName);
    }

    -(void)setDocumentLocator:(PGSAXParser *)parser location:(PGSAXLocator *)location {
        PGLog(FMT_INSIDE, @"setDocumentLocator");
    }

    -(void)startDocument:(PGSAXParser *)parser {
        PGLog(FMT_INSIDE, @"startDocument");
    }

    -(void)endDocument:(PGSAXParser *)parser {
        PGLog(FMT_INSIDE, @"endDocument");
    }

    -(void)startElement:(PGSAXParser *)parser name:(NSString *)name attributes:(NSArray<PGSAXAttribute *> *)attributes {
        PGLog(FMT_INSIDE, @"startElement");
    }

    -(void)endElement:(PGSAXParser *)parser name:(NSString *)name {
        PGLog(FMT_INSIDE, @"endElement");
        PGLog(FMT_PARAM, @"name", name);
    }

    -(void)reference:(PGSAXParser *)parser name:(NSString *)name {
        PGLog(FMT_INSIDE, @"reference");
        PGLog(FMT_PARAM, @"name", name);
    }

    -(void)characters:(PGSAXParser *)parser value:(NSString *)value {
        PGLog(FMT_INSIDE, @"characters");
        PGLog(FMT_PARAM, @"value", value);
    }

    -(void)ignorableWhitespace:(PGSAXParser *)parser value:(NSString *)value {
        PGLog(FMT_INSIDE, @"ignorableWhitespace");
        PGLog(FMT_PARAM, @"value", value);
    }

    -(void)processingInstruction:(PGSAXParser *)parser target:(NSString *)target data:(NSString *)data {
        PGLog(FMT_INSIDE, @"processingInstruction");
        PGLog(FMT_PARAM, @"target", target);
        PGLog(FMT_PARAM, @"data", data);
    }

    -(void)comment:(PGSAXParser *)parser value:(NSString *)value {
        PGLog(FMT_INSIDE, @"comment");
        PGLog(FMT_PARAM, @"value", value);
    }

    -(void)cdataBlock:(PGSAXParser *)parser value:(NSString *)value {
        PGLog(FMT_INSIDE, @"cdataBlock");
        PGLog(FMT_PARAM, @"value", value);
    }

    -(void)startElementNS:(PGSAXParser *)parser
                localname:(NSString *)localname
                   prefix:(NSString *)prefix
                      URI:(NSString *)URI
               namespaces:(NSArray<PGSAXNamespace *> *)namespaces
               attributes:(NSArray<PGSAXAttribute *> *)attributes {
        PGLog(FMT_INSIDE, @"startElementNS");
        PGLog(FMT_PARAM, @"localname", localname);
        PGLog(FMT_PARAM, @"prefix", prefix);
        PGLog(FMT_PARAM, @"URI", URI);
    }

    -(void)endElementNS:(PGSAXParser *)parser localname:(NSString *)localname prefix:(NSString *)prefix URI:(NSString *)URI {
        PGLog(FMT_INSIDE, @"endElementNS");
        PGLog(FMT_PARAM, @"localname", localname);
        PGLog(FMT_PARAM, @"prefix", prefix);
        PGLog(FMT_PARAM, @"URI", URI);
    }

    -(void)structuredError:(PGSAXParser *)parser msg:(NSString *)msg {
        PGLog(FMT_INSIDE, @"structuredError");
        PGLog(FMT_PARAM, @"msg", msg);
    }

    -(void)warning:(PGSAXParser *)parser msg:(NSString *)msg {
        PGLog(FMT_INSIDE, @"warning");
        PGLog(FMT_PARAM, @"msg", msg);
    }

    -(void)error:(PGSAXParser *)parser msg:(NSString *)msg {
        PGLog(FMT_INSIDE, @"error");
        PGLog(FMT_PARAM, @"msg", msg);
    }

    -(void)fatalError:(PGSAXParser *)parser msg:(NSString *)msg {
        PGLog(FMT_INSIDE, @"fatalError");
        PGLog(FMT_PARAM, @"msg", msg);
    }

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSError     *error    = nil;
        MyDelegate  *delegate = [MyDelegate new];
        PGSAXParser *parser   = [[PGSAXParser alloc] initWithFilename:@"~/Desktop/XML/Test.xml".stringByExpandingTildeInPath];

        parser.delegate = delegate;

        BOOL b = [parser parse:&error];
        PGLog(@"Result: %@; Error: %@", (b ? @"SUCCESS" : @"FAILED"), (b ? @"" : (error ? error.localizedDescription : @"Unknown")));
//        int a[] = { 9, 8, 2, 4 };
//        int b = (sizeof(a)/sizeof(a[0]));
//        PGLog(@"Number of elements: %d", b);
    }

    return 0;
}
