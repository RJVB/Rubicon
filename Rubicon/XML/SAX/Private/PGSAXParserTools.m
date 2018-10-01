/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXParserTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/23/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
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

#import "PGSAXParserTools.h"

#pragma mark Utility Class Categories

@implementation NSString(PGSAX)

    +(NSString *)stringFromXMLString:(const xmlChar *)xmlStr {
        return (xmlStr ? [[NSString alloc] initWithUTF8String:(const char *)xmlStr] : nil);
    }

    +(NSString *)stringFromXMLString:(const xmlChar *)xmlStr length:(int)length {
        if(xmlStr && length) {
            xmlChar  *part  = xmlUTF8Strndup(xmlStr, length);
            NSString *nsStr = [self stringFromXMLString:part];
            free(part);
            return nsStr;
        }
        else return (xmlStr ? @"" : nil);
    }

    +(NSString *)stringFromXMLString:(const xmlChar *)xmlStr args:(va_list)args {
        return (xmlStr ? [[NSString alloc] initWithFormat:[self stringFromXMLString:xmlStr] arguments:args] : nil);
    }

@end

#pragma mark Utility Functions

NS_INLINE PGSAXSimpleBuffer *bufferForNSData(BridgedParserPtr p, NSData *data) {
    PGSAXSimpleBuffer *sb = [p createTempBuffer:(int)data.length];
    [data getBytes:sb->buffer length:(NSUInteger)sb->length];
    return sb;
}

NS_INLINE NSString *bar(const char *msg, va_list args) {
    size_t sz   = 4096; // 4K should be more than enough.
    char   *tmp = PGCalloc(1, sz);

    @try {
        vsnprintf(tmp, (sz - 1), msg, args);
        return [NSString stringWithUTF8String:tmp];
    }
    @finally { free(tmp); }
}

xmlSAXHandlerPtr createSAXHandler(xmlSAXHandlerPtr saxh) {
    saxh->initialized           = XML_SAX2_MAGIC;
    saxh->internalSubset        = __internalSubsetSAX;
    saxh->externalSubset        = __externalSubsetSAX;
    saxh->isStandalone          = __isStandaloneSAX;
    saxh->hasInternalSubset     = __hasInternalSubsetSAX;
    saxh->hasExternalSubset     = __hasExternalSubsetSAX;
    saxh->getEntity             = __getEntitySAX;
    saxh->getParameterEntity    = __getParameterEntitySAX;
    saxh->resolveEntity         = __resolveEntitySAX;
    saxh->entityDecl            = __entityDeclSAX;
    saxh->notationDecl          = __notationDeclSAX;
    saxh->attributeDecl         = __attributeDeclSAX;
    saxh->elementDecl           = __elementDeclSAX;
    saxh->unparsedEntityDecl    = __unparsedEntityDeclSAX;
    saxh->setDocumentLocator    = __setDocumentLocatorSAX;
    saxh->startDocument         = __startDocumentSAX;
    saxh->endDocument           = __endDocumentSAX;
    saxh->startElement          = __startElementSAX;
    saxh->endElement            = __endElementSAX;
    saxh->reference             = __referenceSAX;
    saxh->characters            = __charactersSAX;
    saxh->ignorableWhitespace   = __ignorableWhitespaceSAX;
    saxh->processingInstruction = __processingInstructionSAX;
    saxh->comment               = __commentSAX;
    saxh->cdataBlock            = __cdataBlockSAX;
    saxh->startElementNs        = __startElementNsSAX2;
    saxh->endElementNs          = __endElementNsSAX2;
    saxh->serror                = __xmlStructuredError2;
    saxh->warning               = __warningSAX;
    saxh->error                 = __errorSAX;
    saxh->fatalError            = __fatalErrorSAX; /* unused error() get all the errors */
    return saxh;
}

void populateSelectorFields(void) {
    static dispatch_once_t __selectorOnce = 0;
    dispatch_once(&__selectorOnce, ^{
        _selInternalSubset        = @selector(internalSubset:name:externalID:systemID:);
        _selExternalSubset        = @selector(externalSubset:name:externalID:systemID:);
        _selIsStandalone          = @selector(isStandalone:);
        _selHasInternalSubset     = @selector(hasInternalSubset:);
        _selHasExternalSubset     = @selector(hasExternalSubset:);
        _selGetEntity             = @selector(getEntity:name:);
        _selGetParameterEntity    = @selector(getParameterEntity:name:);
        _selResolveEntity         = @selector(resolveEntity:publicID:systemID:);
        _selEntityDecl            = @selector(entityDecl:name:type:publicID:systemID:content:);
        _selNotationDecl          = @selector(notationDecl:name:publicID:systemID:);
        _selAttributeDecl         = @selector(attributeDecl:attrDecl:);
        _selElementDecl           = @selector(elementDecl:name:type:content:);
        _selUnparsedEntityDecl    = @selector(unparsedEntityDecl:name:publicID:systemID:notationName:);
        _selSetDocumentLocator    = @selector(setDocumentLocator:location:);
        _selStartDocument         = @selector(startDocument:);
        _selEndDocument           = @selector(endDocument:);
        _selStartElement          = @selector(startElement:name:attributes:);
        _selEndElement            = @selector(endElement:name:);
        _selReference             = @selector(reference:name:);
        _selCharacters            = @selector(characters:value:);
        _selIgnorableWhitespace   = @selector(ignorableWhitespace:value:);
        _selProcessingInstruction = @selector(processingInstruction:target:data:);
        _selComment               = @selector(comment:value:);
        _selCdataBlock            = @selector(cdataBlock:value:);
        _selStartElementNS        = @selector(startElementNS:localname:prefix:URI:namespaces:attributes:);
        _selEndElementNS          = @selector(endElementNS:localname:prefix:URI:);
        _selXmlStructuredError    = @selector(structuredError:msg:);
        _selWarning               = @selector(warning:msg:);
        _selError                 = @selector(error:msg:);
        _selFatalError            = @selector(fatalError:msg:);
        _selStreamRead            = @selector(read:maxLength:);
    });
}

NSString *errorLevelXlat(xmlErrorLevel level) {
    switch(level) {
        case XML_ERR_WARNING:
            return @"Warning";
        case XML_ERR_ERROR:
            return @"Error";
        case XML_ERR_FATAL:
            return @"Fatal";
        default:
            return @"None";
    }
}

NSArray<NSString *> *errorDomainXlat(int errorDomain) {
    switch(errorDomain) {
        case XML_FROM_NONE:
            return @[ @"None", @"" ];
        case XML_FROM_PARSER:
            return @[ @"Parser", @"XML parser" ];
        case XML_FROM_TREE:
            return @[ @"Tree", @"Tree module" ];
        case XML_FROM_NAMESPACE:
            return @[ @"Namespace", @"XML Namespace module" ];
        case XML_FROM_DTD:
            return @[ @"DTD", @"XML DTD validation with parser context" ];
        case XML_FROM_HTML:
            return @[ @"HTML", @"HTML parser" ];
        case XML_FROM_MEMORY:
            return @[ @"Memory", @"Memory allocator" ];
        case XML_FROM_OUTPUT:
            return @[ @"Output", @"Serialization code" ];
        case XML_FROM_IO:
            return @[ @"IO", @"Input/Output stack" ];
        case XML_FROM_FTP:
            return @[ @"FTP", @"FTP module" ];
        case XML_FROM_HTTP:
            return @[ @"HTTP", @"HTTP module" ];
        case XML_FROM_XINCLUDE:
            return @[ @"XInclude", @"XInclude processing" ];
        case XML_FROM_XPATH:
            return @[ @"XPath", @"XPath module" ];
        case XML_FROM_XPOINTER:
            return @[ @"XPointer", @"XPointer module" ];
        case XML_FROM_REGEXP:
            return @[ @"Regexp", @"Regular expressions module" ];
        case XML_FROM_DATATYPE:
            return @[ @"Datatype", @"W3C XML Schemas Datatype module" ];
        case XML_FROM_SCHEMASP:
            return @[ @"Schemas Parser", @"W3C XML Schemas parser module" ];
        case XML_FROM_SCHEMASV:
            return @[ @"Schemas Validation", @"W3C XML Schemas validation module" ];
        case XML_FROM_RELAXNGP:
            return @[ @"Relaxng Parser", @"Relax-NG parser module" ];
        case XML_FROM_RELAXNGV:
            return @[ @"Relaxng Validation", @"Relax-NG validator module" ];
        case XML_FROM_CATALOG:
            return @[ @"Catalog", @"Catalog module" ];
        case XML_FROM_C14N:
            return @[ @"C14N", @"Canonicalization module" ];
        case XML_FROM_XSLT:
            return @[ @"XSLT", @"XSLT engine from libxslt" ];
        case XML_FROM_VALID:
            return @[ @"Validation", @"XML DTD validation with valid context" ];
        case XML_FROM_CHECK:
            return @[ @"Check", @"Error checking module" ];
        case XML_FROM_WRITER:
            return @[ @"Writer", @"XMLwriter module" ];
        case XML_FROM_MODULE:
            return @[ @"Module", @"Dynamically loaded module module" ];
        case XML_FROM_I18N:
            return @[ @"I18N", @"Module handling character conversion" ];
        case XML_FROM_SCHEMATRONV:
            return @[ @"Schematron", @"Schematron validator module" ];
        case XML_FROM_BUFFER:
            return @[ @"Buffer", @"Buffers module" ];
        case XML_FROM_URI:
            return @[ @"URI", @"URI module" ];
        default:
            return @[ @"Unknown", @"" ];
    }
}

// @f:0
#pragma mark Call Back Functions

int __isStandaloneSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    return ([p isStandalone] ? 1 : 0);
}

int __hasInternalSubsetSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    return ([p hasInternalSubset] ? 1 : 0);
}

int __hasExternalSubsetSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    return ([p hasExternalSubset] ? 1 : 0);
}

void __startElementNsSAX2(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes) { // @f:1
    BridgedParserPtr          p   = CASTASPARSER(ctx);
    NSArray<PGSAXNamespace *> *ns = [PGSAXNamespace namespacesFromArray:namespaces length:(NSUInteger)nb_namespaces];
    NSArray<PGSAXAttribute *> *at = [PGSAXAttribute attributeListFromAttributes:attributes length:(NSUInteger)nb_attributes numDefs:(NSUInteger)nb_defaulted];
    [p startElemNS:[NSString stringFromXMLString:localname] pfx:[NSString stringFromXMLString:prefix] URI:[NSString stringFromXMLString:URI] nspcs:ns atts:at];
}

void __endElementNsSAX2(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p endElementNS:[NSString stringFromXMLString:localname] prefix:[NSString stringFromXMLString:prefix] URI:[NSString stringFromXMLString:URI]];
}

void __internalSubsetSAX(void *ctx, const xmlChar *name, const xmlChar *ExternalID, const xmlChar *SystemID) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p internalSubset:[NSString stringFromXMLString:name] externalID:[NSString stringFromXMLString:ExternalID] systemID:[NSString stringFromXMLString:SystemID]];
}

void __externalSubsetSAX(void *ctx, const xmlChar *name, const xmlChar *ExternalID, const xmlChar *SystemID) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p externalSubset:[NSString stringFromXMLString:name] externalID:[NSString stringFromXMLString:ExternalID] systemID:[NSString stringFromXMLString:SystemID]];
}

xmlEntityPtr __getEntitySAX(void *ctx, const xmlChar *name) {
    BridgedParserPtr p          = CASTASPARSER(ctx);
    NSString         *nsName    = [NSString stringFromXMLString:name];
    NSString         *nsContent = [p getEntity:nsName];
    PGSAXEntity      *entity    = nil;

    if(nsContent) entity     = [p storeEntity:nsName type:-XML_INTERNAL_GENERAL_ENTITY publicID:NULL systemID:NULL content:nsContent];
    if(entity == nil) entity = [p getLocalEntity:nsName];
    return entity.xmlEntity;
}

xmlEntityPtr __getParameterEntitySAX(void *ctx, const xmlChar *name) {
    BridgedParserPtr p          = CASTASPARSER(ctx);
    NSString         *nsName    = [NSString stringFromXMLString:name];
    NSString         *nsContent = [p getParameterEntity:nsName];
    PGSAXEntity      *entity    = nil;

    if(nsContent) entity     = [p storeEntity:nsName type:-XML_INTERNAL_PARAMETER_ENTITY publicID:NULL systemID:NULL content:nsContent];
    if(entity == nil) entity = [p getLocalParameterEntity:nsName];
    return entity.xmlEntity;
}

xmlParserInputPtr __resolveEntitySAX(void *ctx, const xmlChar *publicId, const xmlChar *systemId) {
    BridgedParserPtr p     = CASTASPARSER(ctx);
    NSData           *data = [p resolveEntity:[NSString stringFromXMLString:publicId] systemID:[NSString stringFromXMLString:systemId]];

    if(data.length) {
        PGSAXSimpleBuffer       *sb   = bufferForNSData(p, data);
        xmlParserInputBufferPtr inbuf = xmlParserInputBufferCreateMem(sb->buffer, sb->length, XML_CHAR_ENCODING_UTF8);
        xmlParserInputPtr       pinp  = xmlNewIOInputStream(p.ctx, inbuf, XML_CHAR_ENCODING_UTF8);
        return pinp;
    }

    return xmlLoadExternalEntity((const char *)systemId, (const char *)systemId, p.ctx);
}

void __entityDeclSAX(void *ctx, const xmlChar *name, int type, const xmlChar *publicId, const xmlChar *systemId, xmlChar *content) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p entityDecl:[NSString stringFromXMLString:name]
             type:type
         publicID:[NSString stringFromXMLString:publicId]
         systemID:[NSString stringFromXMLString:systemId]
          content:[NSString stringFromXMLString:content]];
}

void __notationDeclSAX(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p notationDecl:[NSString stringFromXMLString:name] publicID:[NSString stringFromXMLString:publicId] systemID:[NSString stringFromXMLString:systemId]];
}

void __attributeDeclSAX(void *ctx, const xmlChar *elem, const xmlChar *fullname, int type, int def, const xmlChar *defaultValue, xmlEnumerationPtr tree) {
    BridgedParserPtr           p       = CASTASPARSER(ctx);
    NSMutableArray<NSString *> *values = [NSMutableArray new];

    PGLog(@"Inside Callback> %@", @"__attributeDeclSAX");
    while(tree) {
        NSString *enumValue = [NSString stringFromXMLString:tree->name];
        PGLog(@"        AttribEnum: \"%@\"", enumValue);
        [values addObject:enumValue];
        tree = tree->next;
    }

    [p attributeDecl:[PGSAXAttributeDecl declWithElement:[NSString stringFromXMLString:elem]
                                                fullname:[NSString stringFromXMLString:fullname]
                                                attrType:(PGSAXAttributeType)type
                                             attrDefault:(PGSAXAttributeDefault)def
                                            defaultValue:[NSString stringFromXMLString:defaultValue]
                                               valueList:values]];
}

void __elementDeclSAX(void *ctx, const xmlChar *name, int type, xmlElementContentPtr content) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p elementDecl:[NSString stringFromXMLString:name] type:type content:[PGSAXElementDecl declWithXmlElementContent:content]];
}

void __unparsedEntityDeclSAX(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId, const xmlChar *notationName) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p unparsedEntityDecl:[NSString stringFromXMLString:name]
                 publicID:[NSString stringFromXMLString:publicId]
                 systemID:[NSString stringFromXMLString:systemId]
             notationName:[NSString stringFromXMLString:notationName]];
}

void __setDocumentLocatorSAX(void *ctx, xmlSAXLocatorPtr loc) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p setDocumentLocator:[[PGSAXLocator alloc] initWithLocator:loc context:ctx]];
}

void __startDocumentSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p startDocument];
}

void __endDocumentSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p endDocument];
}

void __startElementSAX(void *ctx, const xmlChar *name, const xmlChar **atts) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p startElement:[NSString stringFromXMLString:name] attributes:[PGSAXAttribute attributeListFromAttributes:atts]];
}

void __endElementSAX(void *ctx, const xmlChar *name) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p endElement:[NSString stringFromXMLString:name]];
}

void __referenceSAX(void *ctx, const xmlChar *name) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p reference:[NSString stringFromXMLString:name]];
}

void __charactersSAX(void *ctx, const xmlChar *ch, int len) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p characters:[NSString stringFromXMLString:ch length:len]];
}

void __ignorableWhitespaceSAX(void *ctx, const xmlChar *ch, int len) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p ignorableWhitespace:[NSString stringFromXMLString:ch length:len]];
}

void __processingInstructionSAX(void *ctx, const xmlChar *target, const xmlChar *data) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p processingInstruction:[NSString stringFromXMLString:target] data:[NSString stringFromXMLString:data]];
}

void __commentSAX(void *ctx, const xmlChar *value) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p comment:[NSString stringFromXMLString:value]];
}

void __cdataBlockSAX(void *ctx, const xmlChar *value, int len) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p cdataBlock:[NSString stringFromXMLString:value length:len]];
}

void __warningSAX(void *ctx, const char *msg, ...) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    va_list          args;
    va_start(args, msg);
    NSString *nsMsg = bar(msg, args);
    va_end(args);
    [p warning:nsMsg];
}

void __errorSAX(void *ctx, const char *msg, ...) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    va_list          args;
    va_start(args, msg);
    NSString *nsMsg = bar(msg, args);
    va_end(args);
    [p error:nsMsg];
}

void __fatalErrorSAX(void *ctx, const char *msg, ...) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    va_list          args;
    va_start(args, msg);
    NSString *nsMsg = bar(msg, args);
    va_end(args);
    [p fatalError:nsMsg];
}

void __xmlStructuredError2(void *userData, xmlErrorPtr error) {
    BridgedParserPtr p = CASTASPARSER(userData);
    [p structuredError:[NSString stringWithFormat:@"[%@][%@][%@][%@:%@] %@",
                                                  errorLevelXlat(error->level),
                                                  errorDomainXlat(error->domain)[0],
                                                  @(error->code),
                                                  @(error->line),
                                                  @(error->int2),
                                                  [NSString stringWithUTF8String:error->message].trim]];
}

#pragma mark Delegate Method Selectors

SEL _selInternalSubset;
SEL _selExternalSubset;
SEL _selIsStandalone;
SEL _selHasInternalSubset;
SEL _selHasExternalSubset;
SEL _selGetEntity;
SEL _selGetParameterEntity;
SEL _selResolveEntity;
SEL _selEntityDecl;
SEL _selNotationDecl;
SEL _selAttributeDecl;
SEL _selElementDecl;
SEL _selUnparsedEntityDecl;
SEL _selSetDocumentLocator;
SEL _selStartDocument;
SEL _selEndDocument;
SEL _selStartElement;
SEL _selEndElement;
SEL _selReference;
SEL _selCharacters;
SEL _selIgnorableWhitespace;
SEL _selProcessingInstruction;
SEL _selComment;
SEL _selCdataBlock;
SEL _selStartElementNS;
SEL _selEndElementNS;
SEL _selXmlStructuredError;
SEL _selWarning;
SEL _selError;
SEL _selFatalError;
SEL _selStreamRead;

