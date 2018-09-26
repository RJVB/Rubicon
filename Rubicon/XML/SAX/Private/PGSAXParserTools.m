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

static SEL _selInternalSubset;
static SEL _selExternalSubset;
static SEL _selIsStandalone;
static SEL _selHasInternalSubset;
static SEL _selHasExternalSubset;
static SEL _selGetEntity;
static SEL _selGetParameterEntity;
static SEL _selResolveEntity;
static SEL _selEntityDecl;
static SEL _selNotationDecl;
static SEL _selAttributeDecl;
static SEL _selElementDecl;
static SEL _selUnparsedEntityDecl;
static SEL _selSetDocumentLocator;
static SEL _selStartDocument;
static SEL _selEndDocument;
static SEL _selStartElement;
static SEL _selEndElement;
static SEL _selReference;
static SEL _selCharacters;
static SEL _selIgnorableWhitespace;
static SEL _selProcessingInstruction;
static SEL _selComment;
static SEL _selCdataBlock;
static SEL _selStartElementNS;
static SEL _selEndElementNS;
static SEL _selXmlStructuredError;
static SEL _selWarning;
static SEL _selError;
static SEL _selFatalError;
static SEL _selStreamRead;

int __hasInternalSubsetSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    return ([p hasInternalSubset] ? 1 : 0);
}

int __hasExternalSubsetSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    return ([p hasExternalSubset] ? 1 : 0);
}

// @f:0
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

void __xmlStructuredError2(void *userData, xmlErrorPtr error) {
    BridgedParserPtr p      = CASTASPARSER(userData);
    NSString         *nsMsg = @""; // TODO: BUILD...
    [p xmlStructuredError:nsMsg];
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
    BridgedParserPtr p    = CASTASPARSER(ctx);
    NSString         *str = [p getEntity:[NSString stringFromXMLString:name]];
    /* TODO: Convert */
    return NULL;
}

xmlEntityPtr __getParameterEntitySAX(void *ctx, const xmlChar *name) {
    BridgedParserPtr p    = CASTASPARSER(ctx);
    NSString         *str = [p getParameterEntity:[NSString stringFromXMLString:name]];
    /* TODO: Convert */
    return NULL;
}

xmlParserInputPtr __resolveEntitySAX(void *ctx, const xmlChar *publicId, const xmlChar *systemId) {
    BridgedParserPtr p     = CASTASPARSER(ctx);
    NSData           *data = [p resolveEntity:[NSString stringFromXMLString:publicId] systemID:[NSString stringFromXMLString:systemId]];
    /* TODO: Convert */
    return NULL;
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
    BridgedParserPtr p       = CASTASPARSER(ctx);
    NSArray          *nsTree = nil; // TODO: Populate
    [p attributeDecl:[NSString stringFromXMLString:elem]
            fullname:[NSString stringFromXMLString:fullname]
                type:type
                 def:def
        defaultValue:[NSString stringFromXMLString:defaultValue]
                tree:nsTree];
}

void __elementDeclSAX(void *ctx, const xmlChar *name, int type, xmlElementContentPtr content) {
    BridgedParserPtr p     = CASTASPARSER(ctx);
    PGSAXElementDecl *elem = nil; // TODO: Create...
    [p elementDecl:[NSString stringFromXMLString:name] type:type content:elem];
}

void __unparsedEntityDeclSAX(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId, const xmlChar *notationName) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    [p unparsedEntityDecl:[NSString stringFromXMLString:name]
                 publicID:[NSString stringFromXMLString:publicId]
                 systemID:[NSString stringFromXMLString:systemId]
             notationName:[NSString stringFromXMLString:notationName]];
}

void __setDocumentLocatorSAX(void *ctx, xmlSAXLocatorPtr loc) {
    BridgedParserPtr p        = CASTASPARSER(ctx);
    PGSAXLocator     *locator = [[PGSAXLocator alloc] initWithLocator:loc context:ctx];
    [p setDocumentLocator:locator];
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

NS_INLINE NSString *bar(const char *msg, va_list args) {
    size_t sz   = 4096; // 4K should be more than enough.
    char   *tmp = PGCalloc(1, sz);

    @try {
        vsnprintf(tmp, (sz - 1), msg, args);
        return [NSString stringWithUTF8String:tmp];
    }
    @finally { free(tmp); }
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

int __isStandaloneSAX(void *ctx) {
    BridgedParserPtr p = CASTASPARSER(ctx);
    return ([p isStandalone] ? 1 : 0);
}

BOOL chunkParse(xmlParserCtxtPtr ctx, const void *buffer, NSInputStream *instr, IMP fRead, NSError **error) {
    NSInteger length;
    BOOL      success, eof;

    do {
        eof     = ((length = FOO(t_fRead, fRead)(instr, _selStreamRead, buffer, PGSAX_PUSH_BUFFER_SIZE)) <= 0);
        success = (xmlParseChunk(ctx, buffer, (int)(eof ? 0 : length), eof) == 0);
    }
    while(success && !eof);

    if(length < 0) PGSetReference(error, instr.streamError);
    return (success && (length == 0));
}

BOOL openInputStream(NSInputStream *instr, NSError **error) {
    if(instr.streamStatus == NSStreamStatusNotOpen) [instr open];

    for(;;) {
        switch(instr.streamStatus) {
            case NSStreamStatusOpening:
                break;
            case NSStreamStatusOpen:
            case NSStreamStatusReading:
            case NSStreamStatusWriting:
                PGSetReference(error, nil);
                return YES;
            case NSStreamStatusAtEnd:
                PGSetError(error, XMLParser, UnexpectedEndOfInput);
                return NO;
            case NSStreamStatusClosed:
                PGSetError(error, XMLParser, InputStreamClosed);
                return NO;
            case NSStreamStatusError:
                PGSetReference(error, instr.streamError);
                return NO;
            default:
                return NO;
        }
    }
}

xmlSAXHandlerPtr populateSAXHandler() {
    xmlSAXHandlerPtr saxh = PGCalloc(1, sizeof(xmlSAXHandler));
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

void populateSelectorFields() {
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
        _selAttributeDecl         = @selector(attributeDecl:elem:fullname:type:def:defaultValue:tree:);
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
        _selXmlStructuredError    = @selector(xmlStructuredError:msg:);
        _selWarning               = @selector(warning:msg:);
        _selError                 = @selector(error:msg:);
        _selFatalError            = @selector(fatalError:msg:);
        _selStreamRead            = @selector(read:maxLength:);
    });
}

void populateFunctionFields(PGSAXParser *parser, id<PGSAXDelegate> delegate) {
    parser.funcInternalSubset        = ((delegate && [delegate respondsToSelector:_selInternalSubset]) ? [delegate methodForSelector:_selInternalSubset] : NULL);
    parser.funcExternalSubset        = ((delegate && [delegate respondsToSelector:_selExternalSubset]) ? [delegate methodForSelector:_selExternalSubset] : NULL);
    parser.funcIsStandalone          = ((delegate && [delegate respondsToSelector:_selIsStandalone]) ? [delegate methodForSelector:_selIsStandalone] : NULL);
    parser.funcHasInternalSubset     = ((delegate && [delegate respondsToSelector:_selHasInternalSubset]) ? [delegate methodForSelector:_selHasInternalSubset] : NULL);
    parser.funcHasExternalSubset     = ((delegate && [delegate respondsToSelector:_selHasExternalSubset]) ? [delegate methodForSelector:_selHasExternalSubset] : NULL);
    parser.funcGetEntity             = ((delegate && [delegate respondsToSelector:_selGetEntity]) ? [delegate methodForSelector:_selGetEntity] : NULL);
    parser.funcGetParameterEntity    = ((delegate && [delegate respondsToSelector:_selGetParameterEntity]) ? [delegate methodForSelector:_selGetParameterEntity] : NULL);
    parser.funcResolveEntity         = ((delegate && [delegate respondsToSelector:_selResolveEntity]) ? [delegate methodForSelector:_selResolveEntity] : NULL);
    parser.funcEntityDecl            = ((delegate && [delegate respondsToSelector:_selEntityDecl]) ? [delegate methodForSelector:_selEntityDecl] : NULL);
    parser.funcNotationDecl          = ((delegate && [delegate respondsToSelector:_selNotationDecl]) ? [delegate methodForSelector:_selNotationDecl] : NULL);
    parser.funcAttributeDecl         = ((delegate && [delegate respondsToSelector:_selAttributeDecl]) ? [delegate methodForSelector:_selAttributeDecl] : NULL);
    parser.funcElementDecl           = ((delegate && [delegate respondsToSelector:_selElementDecl]) ? [delegate methodForSelector:_selElementDecl] : NULL);
    parser.funcUnparsedEntityDecl    = ((delegate && [delegate respondsToSelector:_selUnparsedEntityDecl]) ? [delegate methodForSelector:_selUnparsedEntityDecl] : NULL);
    parser.funcSetDocumentLocator    = ((delegate && [delegate respondsToSelector:_selSetDocumentLocator]) ? [delegate methodForSelector:_selSetDocumentLocator] : NULL);
    parser.funcStartDocument         = ((delegate && [delegate respondsToSelector:_selStartDocument]) ? [delegate methodForSelector:_selStartDocument] : NULL);
    parser.funcEndDocument           = ((delegate && [delegate respondsToSelector:_selEndDocument]) ? [delegate methodForSelector:_selEndDocument] : NULL);
    parser.funcStartElement          = ((delegate && [delegate respondsToSelector:_selStartElement]) ? [delegate methodForSelector:_selStartElement] : NULL);
    parser.funcEndElement            = ((delegate && [delegate respondsToSelector:_selEndElement]) ? [delegate methodForSelector:_selEndElement] : NULL);
    parser.funcReference             = ((delegate && [delegate respondsToSelector:_selReference]) ? [delegate methodForSelector:_selReference] : NULL);
    parser.funcCharacters            = ((delegate && [delegate respondsToSelector:_selCharacters]) ? [delegate methodForSelector:_selCharacters] : NULL);
    parser.funcIgnorableWhitespace   = ((delegate && [delegate respondsToSelector:_selIgnorableWhitespace]) ? [delegate methodForSelector:_selIgnorableWhitespace] : NULL);
    parser.funcProcessingInstruction = ((delegate && [delegate respondsToSelector:_selProcessingInstruction]) ? [delegate methodForSelector:_selProcessingInstruction] : NULL);
    parser.funcComment               = ((delegate && [delegate respondsToSelector:_selComment]) ? [delegate methodForSelector:_selComment] : NULL);
    parser.funcCdataBlock            = ((delegate && [delegate respondsToSelector:_selCdataBlock]) ? [delegate methodForSelector:_selCdataBlock] : NULL);
    parser.funcStartElementNS        = ((delegate && [delegate respondsToSelector:_selStartElementNS]) ? [delegate methodForSelector:_selStartElementNS] : NULL);
    parser.funcEndElementNS          = ((delegate && [delegate respondsToSelector:_selEndElementNS]) ? [delegate methodForSelector:_selEndElementNS] : NULL);
    parser.funcXmlStructuredError    = ((delegate && [delegate respondsToSelector:_selXmlStructuredError]) ? [delegate methodForSelector:_selXmlStructuredError] : NULL);
    parser.funcWarning               = ((delegate && [delegate respondsToSelector:_selWarning]) ? [delegate methodForSelector:_selWarning] : NULL);
    parser.funcError                 = ((delegate && [delegate respondsToSelector:_selError]) ? [delegate methodForSelector:_selError] : NULL);
    parser.funcFatalError            = ((delegate && [delegate respondsToSelector:_selFatalError]) ? [delegate methodForSelector:_selFatalError] : NULL);
}

xmlParserCtxtPtr createPushContextForDelegate(PGSAXParser *parser, id<PGSAXDelegate> delegate, NSString *filename, const void *buffer, NSUInteger length) {
    parser.workingDelegate = delegate;
    parser.utf8Filename    = strdup(filename ? filename.UTF8String : "");

    populateSelectorFields();
    populateFunctionFields(parser, delegate);
    parser.saxHandler = populateSAXHandler();

    xmlParserCtxtPtr ctx = xmlCreatePushParserCtxt(parser.saxHandler, PG_BRDG_CAST(void)parser, buffer, (int)length, parser.utf8Filename);
    return ctx;
}

BOOL pushParse(PGSAXParser *parse, id<PGSAXDelegate> delegate, NSInputStream *instr, NSError **error) {
    BOOL   success = NO;
    NSByte *buffer = PGMalloc(PGSAX_PUSH_BUFFER_SIZE);

    @try {
        IMP       fRead  = [instr methodForSelector:_selStreamRead];
        NSInteger length = FOO(t_fRead, fRead)(instr, _selStreamRead, buffer, PGSAX_PUSH_BUFFER_SIZE);

        if(length > 0) {
            parse.ctx = createPushContextForDelegate(parse, delegate, parse.filename, buffer, (NSUInteger)length);
            if(parse.ctx) success = chunkParse(parse.ctx, buffer, instr, fRead, error);
            else { PGSetError(error, XMLParser, XMLParserUnknownError); }
        }
        else if(length == 0) PGSetError(error, XMLParser, UnexpectedEndOfInput);
        else PGSetReference(error, instr.streamError);
    }
    @finally {
        free(buffer);
        postParseCleanup(parse);
        parse.hasAlreadyRun = YES;
    }

    return success;
}

BOOL pushParseXML(PGSAXParser *parser, id<PGSAXDelegate> delegate, NSInputStream *instr, NSError **error) {
    BOOL success = NO;
    if(delegate && instr) success = (openInputStream(instr, error) && pushParse(parser, delegate, instr, error));
    else if(delegate) PGSetError(error, XMLParser, NoInputStream);
    else { PGSetError(error, XMLParser, NoDelegate); }
    return success;
}

void postParseCleanup(PGSAXParser *parser) {
    if(parser.ctx) xmlFreeParserCtxt(parser.ctx);
    if(parser.saxHandler) free(parser.saxHandler);
    if(parser.utf8Filename) free(parser.utf8Filename);

    parser.ctx          = NULL;
    parser.saxHandler   = NULL;
    parser.utf8Filename = NULL;

    parser.workingDelegate           = nil;
    parser.funcInternalSubset        = nil;
    parser.funcExternalSubset        = nil;
    parser.funcIsStandalone          = nil;
    parser.funcHasInternalSubset     = nil;
    parser.funcHasExternalSubset     = nil;
    parser.funcGetEntity             = nil;
    parser.funcGetParameterEntity    = nil;
    parser.funcResolveEntity         = nil;
    parser.funcEntityDecl            = nil;
    parser.funcNotationDecl          = nil;
    parser.funcAttributeDecl         = nil;
    parser.funcElementDecl           = nil;
    parser.funcUnparsedEntityDecl    = nil;
    parser.funcSetDocumentLocator    = nil;
    parser.funcStartDocument         = nil;
    parser.funcEndDocument           = nil;
    parser.funcStartElement          = nil;
    parser.funcEndElement            = nil;
    parser.funcReference             = nil;
    parser.funcCharacters            = nil;
    parser.funcIgnorableWhitespace   = nil;
    parser.funcProcessingInstruction = nil;
    parser.funcComment               = nil;
    parser.funcCdataBlock            = nil;
    parser.funcStartElementNS        = nil;
    parser.funcEndElementNS          = nil;
    parser.funcXmlStructuredError    = nil;
    parser.funcWarning               = nil;
    parser.funcError                 = nil;
    parser.funcFatalError            = nil;

    [parser.entities removeAllObjects];
}

