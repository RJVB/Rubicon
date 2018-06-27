/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParserTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/26/18
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

#import "PGXMLParserTools.h"
#import "PGXMLParser+PGXMLParserExtensions.h"

NSString *const PGXMLMsg01             = @"%@ Subset Call Back; Name: \"%@\"; External ID: \"%@\"; System ID: \"%@\"";
NSString *const PGXMLKeyFormat         = @"%@☠︎%@";
NSString *const PGXMLInsideCallbackMsg = @"Inside Callback \"%@\"";

typedef xmlChar       *xch;
typedef const xmlChar *cxch;
typedef const xmlChar **pcxch;

NS_INLINE NSString *stringFromUTF8String(const char *cstr) {
    return (cstr ? [NSString stringWithCString:cstr encoding:NSUTF8StringEncoding] : nil);
}

NS_INLINE NSString *formatUTF8String(const char *msg, va_list args) {
    return [[NSString alloc] initWithFormat:(stringFromUTF8String(msg) ?: @"") arguments:args];
}

NS_INLINE NSString *extractAttrValue(cxch vstart, cxch vend) {
    return ((vstart && (vend > vstart)) ? stringForXMLStringLen(vstart, (vend - vstart)) : @"");
}

NS_INLINE void storeAttr(NSMutableArray<PGXMLParsedAttribute *> *attribs, pcxch rawAttribs, int j, BOOL def) {
    [attribs addObject:[PGXMLParsedAttribute attributeWithLocalName:stringForXMLString(rawAttribs[j + 0])
                                                             prefix:stringForXMLString(rawAttribs[j + 1])
                                                                URI:stringForXMLString(rawAttribs[j + 2])
                                                              value:extractAttrValue(rawAttribs[j + 3], rawAttribs[j + 4])
                                                        isDefaulted:def]];
}

NS_INLINE void storeNamespace(NSMutableArray<PGXMLParsedNamespace *> *nmspcs, pcxch rawNmspcs, int j) {
    [nmspcs addObject:[PGXMLParsedNamespace namespaceWithPrefix:stringForXMLString(rawNmspcs[j + 0]) uri:stringForXMLString(rawNmspcs[j + 1])]];
}

NSArray<PGXMLParsedAttribute *> *convertAttributes(pcxch atts);

NSArray<PGXMLParsedAttribute *> *convertAttributesNS(int nb_attributes, pcxch attributes, int di);

NSArray<PGXMLParsedNamespace *> *convertNamespaces(int nb_namespaces, pcxch namespaces);

xmlParserInputPtr resolveEntityCallBack(void *ctx, cxch publicId, cxch systemId) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    return [parser resolveEntityCallBack:stringForXMLString(publicId) systemID:stringForXMLString(systemId)];
}

void internalSubsetCallBack(void *ctx, cxch name, cxch ExternalID, cxch SystemID) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser internalSubsetCallBack:stringForXMLString(name) externalID:stringForXMLString(ExternalID) systemID:stringForXMLString(SystemID)];
}

void externalSubsetCallBack(void *ctx, cxch name, cxch ExternalID, cxch SystemID) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser externalSubsetCallBack:stringForXMLString(name) externalID:stringForXMLString(ExternalID) systemID:stringForXMLString(SystemID)];
}

xmlEntityPtr getEntityCallBack(void *ctx, cxch name) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    return [parser getEntityCallBack:stringForXMLString(name)];
}

xmlEntityPtr getParameterEntityCallBack(void *ctx, cxch name) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    return [parser getParameterEntityCallBack:stringForXMLString(name)];
}

void entityDeclCallBack(void *ctx, cxch name, int type, cxch publicId, cxch systemId, xch content) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser entityDeclCallBack:stringForXMLString(name) type:type publicID:stringForXMLString(publicId) systemID:stringForXMLString(systemId) content:stringForXMLString(content)];
}

void notationDeclCallBack(void *ctx, cxch name, cxch publicId, cxch systemId) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser notationDeclCallBack:stringForXMLString(name) publicID:stringForXMLString(publicId) systemID:stringForXMLString(systemId)];
}

void attributeDeclCallBack(void *ctx, cxch elem, cxch fullname, int type, int def, cxch defaultValue, xmlEnumerationPtr tree) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser attributeDeclCallBack:stringForXMLString(elem) fullname:stringForXMLString(fullname) type:type def:def defaultValue:stringForXMLString(defaultValue) tree:tree];
}

void elementDeclCallBack(void *ctx, cxch name, int type, xmlElementContentPtr content) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser elementDeclCallBack:stringForXMLString(name) type:type content:content];
}

void unparsedEntityDeclCallBack(void *ctx, cxch name, cxch publicId, cxch systemId, cxch notationName) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser unparsedEntityDeclCallBack:stringForXMLString(name)
                              publicID:stringForXMLString(publicId)
                              systemID:stringForXMLString(systemId)
                          notationName:stringForXMLString(notationName)];
}

void startDocumentCallBack(void *ctx) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser startDocumentCallBack];
}

void endDocumentCallBack(void *ctx) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser endDocumentCallBack];
}

void startElementCallBack(void *ctx, cxch name, cxch *atts) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser startElementCallBack:stringForXMLString(name) attributes:convertAttributes(atts)];
}

void endElementCallBack(void *ctx, cxch name) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser endElementCallBack:stringForXMLString(name)];
}

void referenceCallBack(void *ctx, cxch name) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser referenceCallBack:stringForXMLString(name)];
}

void charactersCallBack(void *ctx, cxch ch, int len) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser charactersCallBack:stringForXMLStringLen(ch, (size_t)len)];
}

void ignorableWhitespaceCallBack(void *ctx, cxch ch, int len) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser ignorableWhitespaceCallBack:stringForXMLStringLen(ch, (size_t)len)];
}

void processingInstructionCallBack(void *ctx, cxch target, cxch data) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser processingInstructionCallBack:stringForXMLString(target) data:stringForXMLString(data)];
}

void commentCallBack(void *ctx, cxch value) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser commentCallBack:stringForXMLString(value)];
}

void cdataBlockCallBack(void *ctx, cxch value, int len) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser cdataBlockCallBack:stringForXMLStringLen(value, (size_t)len)];
}

void warningCallBack(void *ctx, const char *msg, ...) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    va_list          args;
    va_start(args, msg);
    [parser warningCallBack:formatUTF8String(msg, args)];
    va_end(args);
}

void errorCallBack(void *ctx, const char *msg, ...) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    va_list          args;
    va_start(args, msg);
    [parser errorCallBack:formatUTF8String(msg, args)];
    va_end(args);
}

void fatalErrorCallBack(void *ctx, const char *msg, ...) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    va_list          args;
    va_start(args, msg);
    [parser fatalErrorCallBack:formatUTF8String(msg, args)];
    va_end(args);
}

void xmlStructuredErrorCallBack(void *ctx, xmlErrorPtr error) {
    /*
     * TODO: ***ATTENTION***
     * I am not sure if it is going to be passing the context or the user data as the first parameter.
     * The context would make sense since that would be consistent with the other functions but the
     * actual definition of the function in the header file lists the first parameter as "userData"
     * which doesn't really make sense. So we're going to punt and try it the "consistent" way and
     * if we crash on the type-cast then we'll fix it.
     *
     * ParserPtr parser = (__bridge PGXMLParser *)ctx;
     */
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser xmlStructuredErrorCallBack:error];
}

void startElementNsCallBack(void *ctx, cxch localname, cxch prefix, cxch URI, int nb_namespaces, cxch *namespaces, int nb_attributes, int nb_defaulted, cxch *attributes) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser startElementNsCallBack:stringForXMLString(localname)
                            prefix:stringForXMLString(prefix)
                               URI:stringForXMLString(URI)
                        namespaces:convertNamespaces(nb_namespaces, namespaces)
                        attributes:convertAttributesNS(nb_attributes, attributes, (nb_attributes - nb_defaulted))];
}

void endElementNsCallBack(void *ctx, cxch localname, cxch prefix, cxch URI) {
    BridgedParserPtr parser = CASTASPARSER(ctx);
    [parser endElementNsCallBack:stringForXMLString(localname) prefix:stringForXMLString(prefix) namespaceURI:stringForXMLString(URI)];
}

NSArray<PGXMLParsedAttribute *> *convertAttributes(pcxch atts) {
    NSMutableArray<PGXMLParsedAttribute *> *at = [NSMutableArray new];

    for(NSUInteger i = 0; (atts[i + 0] != NULL); i += 2) {
        NSString *aName  = stringForXMLString(atts[i + 0]);
        NSString *aValue = stringForXMLString(atts[i + 1]);
        if(aValue) [at addObject:[PGXMLParsedAttribute attributeWithLocalName:aName value:aValue]];
    }

    return at;
}

NSArray<PGXMLParsedAttribute *> *convertAttributesNS(int nb_attributes, pcxch attributes, int di) {
    NSMutableArray<PGXMLParsedAttribute *> *at = [NSMutableArray arrayWithCapacity:(NSUInteger)nb_attributes];

    for(int i = 0; i < nb_attributes; i++) storeAttr(at, attributes, (i * 5), (i >= di));
    return at;
}

NSArray<PGXMLParsedNamespace *> *convertNamespaces(int nb_namespaces, pcxch namespaces) {
    NSMutableArray<PGXMLParsedNamespace *> *ns = [NSMutableArray arrayWithCapacity:(NSUInteger)nb_namespaces];

    for(int i = 0; i < nb_namespaces; i++) storeNamespace(ns, namespaces, (i * 2));
    return ns;
}

NSString *stringForXMLString(cxch xmlstr) {
    return stringFromUTF8String((const char *)xmlstr);
}

NSString *stringForXMLStringLen(cxch xmlstr, size_t len) {
    NSString *str = @"";

    if(len) {
        xch cstr = PGCalloc(1, sizeof(xmlChar) * (len + 1));
        @try { str = stringForXMLString(PGMemCopy(cstr, xmlstr, len)); } @finally { free(cstr); }
    }

    return str;
}

NSError *createError(NSInteger code, NSString *description) {
    return PGCreateError(PGXMLParserErrorDomain, code, description);
}

BOOL createPushContext(PGXMLParser *parser, const void *buffer, NSInteger bytesRead, const char *filename) {
    @try {
        xmlParserCtxtPtr ctx = xmlCreatePushParserCtxt(parser.saxHandler, (__bridge void *)parser, buffer, (int)bytesRead, filename);

        if(ctx) {
            parser.ctx = ctx;
            return YES;
        }
        else {
            parser.parserError = createError(PGErrorCodeUnknownError, PGErrorMsgUnknowError);
        }
    }
    @catch(NSException *e) {
        parser.parserError = e.makeError;
    }

    return NO;
}

BOOL parseChunk(xmlParserCtxtPtr ctx, const void *buffer, NSInteger bcount, BOOL terminate, BOOL success, NSError **error) {
    return (success && (xmlParseChunk(ctx, buffer, (int)bcount, (terminate ? 1 : 0)) == 0));
}

void entityHashScanner(void *payload, void *data, xmlChar *name) {
    if(payload && data && name) {
        xmlEntityPtr     entity = (xmlEntityPtr)payload;
        BridgedParserPtr parser = CASTASPARSER(data);

        [parser entityDeclCallBack:stringForXMLString(name)
                              type:entity->etype
                          publicID:stringForXMLString(entity->ExternalID)
                          systemID:stringForXMLString(entity->SystemID)
                           content:stringForXMLString(entity->content)];
    }
}
