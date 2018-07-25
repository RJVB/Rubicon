/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParser.m
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

#import "PGXMLParser.h"
#import "PGXMLParserTools.h"
#import "PGXMLParser+PGXMLParserExtensions.h"
#import "PGXMLParsedEntity.h"
#import "PGXMLParserInput.h"

typedef NSInteger (*NSInputStreamReadFunc_t)(id, SEL, uint8_t *, NSUInteger);

@implementation PGXMLParser {
        id<PGXMLParserDelegate> __unsafe_unretained _delegate;
    }

#pragma mark Constructors and Destructors

    @synthesize parserError = _parserError;
    @synthesize hasRun = _hasRun;
    @synthesize ctx = _ctx;
    @synthesize saxHandler = _saxHandler;
    @synthesize input = _input;
    @synthesize url = _url;
    @synthesize entities = _entities;
    @synthesize paramEntities = _paramEntities;
    @synthesize namespaceStack = _namespaceStack;
    @synthesize inputs = _inputs;
    @synthesize logger = _logger;
    @synthesize isStandalone = _isStandalone;
    @synthesize publicId = _publicId;
    @synthesize systemId = _systemId;
    @synthesize version = _version;
    @synthesize encoding = _encoding;
    @synthesize methods = _methods;
    @synthesize lck = _lck;

    -(instancetype)init {
        self = [super init];
        if(self) @throw [NSException exceptionWithName:NSIllegalSelectorException reason:PGErrorMsgInvalidConstructor];
        return self;
    }

    -(instancetype)initWithInputStream:(NSInputStream *)stream {
        self = [super init];

        if(self) {
            _lck            = [NSRecursiveLock new];
            _logger         = [PGLogger sharedInstanceWithClass:self.class];
            _inputs         = [NSMutableArray new];
            _entities       = [NSMutableDictionary new];
            _paramEntities  = [NSMutableDictionary new];
            _methods        = [NSMutableDictionary new];
            _namespaceStack = [PGStack new];
            _input          = stream;
        }

        return self;
    }

    -(instancetype)initWithFilePath:(NSString *)filepath {
        self = [self initWithInputStream:[NSInputStream inputStreamWithFileAtPath:filepath]];
        if(self) {
            _url = [NSURL fileURLWithPath:filepath];
        }
        return self;
    }

    -(instancetype)initWithURL:(NSURL *)url {
        self = [self initWithInputStream:[NSInputStream inputStreamWithURL:url]];
        if(self) {
            _url = [url copy];
        }
        return self;
    }

    -(void)dealloc {
        [self destroySAXHandlerStructure];
    }

#pragma mark Getters and Setters

    -(NSArray<NSString *> *)typeNames {
        static NSArray<NSString *> *__typeNames = nil;
        PGSETIFNIL([PGXMLParser class], __typeNames, (@[ @"general", @"parameter", @"predefined", @"other" ]));
        return __typeNames;
    }

    -(id<PGXMLParserDelegate>)delegate {
        id<PGXMLParserDelegate> d = nil;
        [self.lck lock];
        @try { d = _delegate; } @finally { [self.lck unlock]; }
        return d;
    }

    -(void)setDelegate:(id<PGXMLParserDelegate>)delegate {
        [self.lck lock];
        @try {
            if(_delegate != delegate) {
                _delegate = delegate;
                [self.methods removeAllObjects];
            }
        }
        @finally { [self.lck unlock]; }
    }

    -(NSError *)inputStreamError {
        return (self.input.streamError ?: createError(PGErrorCodeUnknownInputStreamError, PGErrorMsgUnknownInputStreamError));
    }

#pragma mark Parsing

    -(BOOL)parse {
        [self.lck lock];
        @try {
            if(self.hasRun) self.parserError = createError(PGErrorCodeXMLParserAlreadyRun, PGErrorMsgXMLParserAlreadyRun);
            else if(!self.input) self.parserError = createError(PGErrorCodeNoInputStream, PGErrorMsgNoInputStream);
            else if(!self.delegate) self.parserError = createError(PGErrorCodeNoDelegate, PGErrorMsgNoDelegate);
            else if((self.parserError = PGOpenInputStream(self.input)) == nil) {
                @try {
                    PGSimpleBuffer          *b = [PGSimpleBuffer bufferWithLength:PG_DEF_BUF_SZ];
                    id                      o  = self.input;
                    SEL                     s  = @selector(read:maxLength:);
                    NSInputStreamReadFunc_t f  = (NSInputStreamReadFunc_t)[o methodForSelector:s];
                    voidp                   bu = b.buffer;
                    NSUInteger              ln = b.length;
                    NSInteger               br = (*f)(o, s, bu, ln);

                    _version = _encoding = _publicId = _systemId = nil;

                    if(br > 0) {
                        [self setupSAXHandlerStructure];
                        @try {
                            PGCString *fn = [PGCString stringWithNSString:self.url.absoluteString];
                            BOOL      su  = NO, eof;

                            if(createPushContext(self, bu, br, fn.cString)) {
                                @try {
                                    xmlParserCtxtPtr c = self.ctx;

                                    /*
                                     * Nice tight fast loop!
                                     */
                                    do {
                                        eof = ((br = (*f)(o, s, bu, ln)) <= 0);
                                        su  = !xmlParseChunk(c, bu, (int)(eof ? 0 : br), eof);
                                    }
                                    while(su && !eof);

                                    if((br < 0) && (self.parserError == nil)) self.parserError = self.inputStreamError;
                                    su = (su && (br == 0));
                                }
                                @finally {
                                    [self destroyParserContext];
                                }
                            }

                            return su;
                        }
                        @finally {
                            [self destroySAXHandlerStructure];
                        }
                    }
                    else {
                        self.parserError = (br ? self.inputStreamError : createError(PGErrorCodeUnexpectedEndOfInput, PGErrorMsgUnexpectedEndOfInput));
                        return NO;
                    }
                }
                @catch(NSException *e) {
                    self.parserError = e.makeError;
                }
                @finally {
                    [self setHasRun:YES];
                    [self.input close];
                    [self.inputs removeAllObjects];
                    [self.entities removeAllObjects];
                    [self.paramEntities removeAllObjects];
                    [self.namespaceStack removeAllObjects];
                }
            }
        }
        @finally {
            [self.lck unlock];
        }

        return NO;
    }

#pragma mark Helper Methods

    -(xmlEntityPtr)updateEntityForName:(NSString *)name content:(NSString *)content {
        PGXMLParsedEntity *ent = self.entities[name];

        if(ent) ent.content = content;
        else self.entities[name] = ent = [PGXMLParsedEntity entityWithName:name content:content];

        return ent.xmlEntity;
    }

    -(void)startMappingPrefixes:(NSArray<PGXMLParsedNamespace *> *)namespaces hasImpl:(BOOL *)hasImpl {
        (*hasImpl) = NO;
        if(namespaces.count) {
            for(PGXMLParsedNamespace *ns in namespaces) {
                [self _didStartMappingPrefix:ns.prefix toURI:ns.uri hasImpl:hasImpl];
                if(!(*hasImpl)) break;
            }
        }
    }

    -(void)endMappingPrefixes:(NSArray<PGXMLParsedNamespace *> *)namespaces hasImpl:(BOOL *)hasImpl {
        (*hasImpl) = NO;
        if(namespaces.count) {
            for(PGXMLParsedNamespace *ns in namespaces.reverseObjectEnumerator) {
                [self _didEndMappingPrefix:ns.prefix hasImpl:hasImpl];
                if(!(*hasImpl)) break;
            }
        }
    }

    -(NSString *)getKeyForName:(NSString *)name andType:(int)type {
        switch(type) {
            case XML_INTERNAL_GENERAL_ENTITY:
            case XML_EXTERNAL_GENERAL_PARSED_ENTITY:
            case XML_EXTERNAL_GENERAL_UNPARSED_ENTITY:
                return PGFormat(PGXMLKeyFormat, name, self.typeNames[0]);
            case XML_INTERNAL_PARAMETER_ENTITY:
            case XML_EXTERNAL_PARAMETER_ENTITY:
                return PGFormat(PGXMLKeyFormat, name, self.typeNames[1]);
            case XML_INTERNAL_PREDEFINED_ENTITY:
                return PGFormat(PGXMLKeyFormat, name, self.typeNames[2]);
            default:
                return PGFormat(PGXMLKeyFormat, name, self.typeNames[3]);
        }
    }

    -(NSURL *)urlForPublicID:(NSString *)publicID systemID:(NSString *)systemID {
        NSURL *url = self.url;
        return (url ? [NSURL URLWithString:systemID relativeToURL:url] : [NSURL URLWithString:systemID]);
    }

    -(PGXMLParsedEntity *)getExistingEntityForName:(NSString *)name {
        NSUInteger idxs[] = { 0, 2, 3 };

        for(int i = 0; i < 3; i++) {
            PGXMLParsedEntity *e = self.entities[PGFormat(PGXMLKeyFormat, name, self.typeNames[idxs[i]])];
            if(e) return e;
        }

        return nil;
    }

    -(xmlParserInputPtr)localResolveEntityForPublicID:(NSString *)publicID systemID:(NSString *)systemID {
        if(systemID.length) {
            NSURL *url = [self urlForPublicID:publicID systemID:systemID];
            if(url) return [self xmlParserInputPtrFromData:[NSData dataWithContentsOfURL:url]];
        }
        return NULL;
    }

    -(PGXMLParserInput *)getNewParserInputForData:(NSData *)data {
        PGXMLParserInput *input = [PGXMLParserInput inputWithData:data];
        [self.inputs addObject:input];
        return input;
    }

    -(xmlParserInputPtr)xmlParserInputPtrFromData:(NSData *)data {
        return (self.ctx ? [[self getNewParserInputForData:data] getNewParserInputForContext:self.ctx] : NULL);
    }

    -(void)extractEntitiesFromDTDAtURL:(NSURL *)url externalID:(NSString *)externalID {
        if(url) {
            xmlDtdPtr dtd = xmlParseDTD((const xmlChar *)externalID.UTF8String, (const xmlChar *)url.absoluteString.UTF8String);
            if(dtd && dtd->entities) xmlHashScan((xmlHashTablePtr)dtd->entities, entityHashScanner, (__bridge void *)self);
        }
    }

    -(void)handleSubset:(NSString *)desc name:(NSString *)name externalID:(NSString *)externalID systemID:(NSString *)systemID {
        [self.logger debug:PGXMLMsg01, desc, name, externalID, systemID];
        if(systemID.length) [self extractEntitiesFromDTDAtURL:[self urlForPublicID:externalID systemID:systemID] externalID:externalID];
    }

#pragma mark libxml2 Callback Handlers

    -(void)internalSubsetCallBack:(NSString *)name externalID:(NSString *)externalID systemID:(NSString *)systemID {
        [self handleSubset:@"Internal" name:name externalID:externalID systemID:systemID];
    }

    -(void)externalSubsetCallBack:(NSString *)name externalID:(NSString *)externalID systemID:(NSString *)systemID {
        [self handleSubset:@"External" name:name externalID:externalID systemID:systemID];
    }

    -(xmlParserInputPtr)resolveEntityCallBack:(NSString *)publicID systemID:(NSString *)systemID {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL   hasImpl = NO;
        NSData *data   = [self _resolveExternalEntityForName:publicID systemID:systemID hasImpl:&hasImpl];
        return (data.length ? [self xmlParserInputPtrFromData:data] : [self localResolveEntityForPublicID:publicID systemID:systemID]);
    }

    -(xmlEntityPtr)getEntityCallBack:(NSString *)name {
        [self.logger debug:@"%@; name: \"%@\"", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd)), name];
        BOOL              hasImpl  = NO;
        NSString          *content = [self _resolveInternalEntityForName:name hasImpl:&hasImpl];
        PGXMLParsedEntity *e       = [self getExistingEntityForName:name];

        if(content) {
            if(e) e.content = content;
            else e = [PGXMLParsedEntity entityWithName:name content:content];
        }

        return e.xmlEntity;
    }

    -(xmlEntityPtr)getParameterEntityCallBack:(NSString *)name {
        [self.logger debug:@"%@; name: \"%@\"", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd)), name];
        BOOL              hasImpl  = NO;
        NSString          *content = [self _resolveInternalParameterEntityForName:name hasImpl:&hasImpl];
        PGXMLParsedEntity *e       = self.paramEntities[PGFormat(PGXMLKeyFormat, name, self.typeNames[1])];

        if(content) {
            if(e) e.content = content;
            else e = [PGXMLParsedEntity entityWithName:name content:content];
        }

        return e.xmlEntity;
    }

    -(void)entityDeclCallBack:(NSString *)name type:(int)type publicID:(NSString *)publicID systemID:(NSString *)systemID content:(NSString *)content {
        NSString *s = PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd));
        [self.logger debug:@"%@; %@: \"%@\"; %@: \"%@\"; %@: \"%@\"; %@: \"%@\"; %@: \"%@\"",
                           s,
                           @"name",
                           name,
                           @"type",
                           @(type),
                           @"public ID",
                           publicID,
                           @"system ID",
                           systemID,
                           @"content",
                           content];

        NSString          *key    = [self getKeyForName:name andType:type];
        PGXMLParsedEntity *ent    = self.entities[key];
        BOOL              hasImpl = NO;

        if(ent) {
            ent.content  = content;
            ent.publicID = publicID;
            ent.systemID = systemID;
            ent.type     = (xmlEntityType)type;
        }
        else {
            ent = [PGXMLParsedEntity entityWithName:name content:content publicID:publicID systemID:systemID type:(xmlEntityType)type];
            self.entities[key] = ent;
        }

        [self _foundInternalEntityDeclarationWithName:name value:content hasImpl:&hasImpl];
    }

    -(void)notationDeclCallBack:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {
        NSString *s = PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd));
        [self.logger debug:@"%@; %@: \"%@\"; %@: \"%@\"; %@: \"%@\"", s, @"name", name, @"publicID", publicID, @"systemID", systemID];
        BOOL hasImpl = NO;
        [self _foundNotationDeclarationWithName:name publicID:publicID systemID:systemID hasImpl:&hasImpl];
    }

    -(void)attributeDeclCallBack:(NSString *)elem fullname:(NSString *)fullname type:(int)type def:(int)def defaultValue:(NSString *)defaultValue tree:(xmlEnumerationPtr)tree {
        NSString *s = PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd));
        [self.logger debug:@"%@; %@: \"%@\"; %@: \"%@\"; %@: \"%@\"; %@: \"%@\"; %@: \"%@\"",
                           s,
                           @"elem",
                           elem,
                           @"fullname",
                           fullname,
                           @"type",
                           @(type),
                           @"def",
                           @(def),
                           @"defaultValue",
                           defaultValue];
        BOOL hasImpl = NO;
        [self _foundAttributeDeclarationWithName:fullname forElement:elem type:[@(type) stringValue] defaultValue:defaultValue hasImpl:&hasImpl];
    }

    -(void)elementDeclCallBack:(NSString *)name type:(int)type content:(xmlElementContentPtr)content {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _foundElementDeclarationWithName:name model:nil hasImpl:&hasImpl];
    }

    -(void)unparsedEntityDeclCallBack:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _foundUnparsedEntityDeclarationWithName:name publicID:publicID systemID:systemID notationName:notationName hasImpl:&hasImpl];
    }

    -(void)startDocumentCallBack {
        xmlParserCtxtPtr ctx = self.ctx;

        if(ctx) {
            _isStandalone = ((ctx->standalone) != 0);
            _version      = stringForXMLString(ctx->version);
            _encoding     = stringForXMLString(ctx->encoding);

            NSString *fmt = @"%@; line: %@; column: %@; encoding: \"%@\"; version: \"%@\"; standalone: %@";
            NSString *loc = PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd));
            [self.logger debug:fmt, loc, @(self.lineNumber), @(self.columnNumber), self.encoding, self.version, (self.isStandalone ? @"YES" : @"NO")];
        }
        else {
            _isStandalone = NO;
            _version      = nil;
            _encoding     = nil;

            [self.logger debug:@"%@; *** NO CONTEXT ***", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        }

        BOOL hasImpl = NO;
        [self _didStartDocument:&hasImpl];
    }

    -(NSUInteger)lineNumber {
        xmlParserCtxtPtr ctx = self.ctx;
        return (NSUInteger)MAX((ctx ? ctx->input->line : 0), 0);
    }

    -(NSUInteger)columnNumber {
        xmlParserCtxtPtr ctx = self.ctx;
        return (NSUInteger)MAX((ctx ? ctx->input->col : 0), 0);
    }

    -(void)endDocumentCallBack {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _didEndDocument:&hasImpl];
    }

    -(void)startElementCallBack:(NSString *)name attributes:(NSArray<PGXMLParserAttribute *> *)attributes {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _didStartElement:name namespaceURI:nil qualifiedName:nil attributes:attributes hasImpl:&hasImpl];
    }

    -(void)endElementCallBack:(NSString *)name {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _didEndElement:name namespaceURI:nil qualifiedName:nil hasImpl:&hasImpl];
    }

    -(void)startElementNsCallBack:(NSString *)localname
                           prefix:(NSString *)prefix
                              URI:(NSString *)URI
                       namespaces:(NSArray<PGXMLParsedNamespace *> *)namespaces
                       attributes:(NSArray<PGXMLParserAttribute *> *)attributes {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self.namespaceStack push:(namespaces.count ? namespaces : @[])];
        [self startMappingPrefixes:namespaces hasImpl:&hasImpl];
        [self _didStartElement:localname namespaceURI:URI qualifiedName:createQName(localname, prefix) attributes:attributes hasImpl:&hasImpl];
    }

    -(void)endElementNsCallBack:(NSString *)localname prefix:(NSString *)prefix namespaceURI:(NSString *)namespaceURI {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _didEndElement:localname namespaceURI:namespaceURI qualifiedName:createQName(localname, prefix) hasImpl:&hasImpl];
        [self endMappingPrefixes:self.namespaceStack.pop hasImpl:&hasImpl];
    }

    -(void)referenceCallBack:(NSString *)name {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        xmlEntityPtr ent = [self getEntityCallBack:name];
        if(ent && ent->content) [self charactersCallBack:stringForXMLString(ent->content)];
    }

    -(void)charactersCallBack:(NSString *)ch {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _foundCharacters:ch hasImpl:&hasImpl];
    }

    -(void)ignorableWhitespaceCallBack:(NSString *)ch {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _foundIgnorableWhitespace:ch hasImpl:&hasImpl];
    }

    -(void)processingInstructionCallBack:(NSString *)target data:(NSString *)data {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _foundProcessingInstructionWithTarget:target data:data hasImpl:&hasImpl];
    }

    -(void)commentCallBack:(NSString *)value {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        [self _foundComment:value hasImpl:&hasImpl];
    }

    -(void)cdataBlockCallBack:(NSString *)value {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;

        if(value) {
            char *str = strdup(value.UTF8String);
            [self _foundCDATA:[NSData dataWithBytesNoCopy:str length:strlen(str) freeWhenDone:YES] hasImpl:&hasImpl];
        }
        else [self _foundCDATA:[NSData new] hasImpl:&hasImpl];
    }

    -(void)warningCallBack:(NSString *)msg {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        self.parserError = createError(PGErrorCodeXMLParserWarning, msg);
        [self _parseErrorOccurred:self.parserError hasImpl:&hasImpl];
    }

    -(void)errorCallBack:(NSString *)msg {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        // int  col     = self.ctx->input->col;
        // int  lin     = self.ctx->input->line;
        self.parserError = createError(PGErrorCodeXMLParserError, msg);
        [self _parseErrorOccurred:self.parserError hasImpl:&hasImpl];
    }

    -(void)fatalErrorCallBack:(NSString *)msg {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL hasImpl = NO;
        self.parserError = createError(PGErrorCodeXMLParserFatalError, msg);
        [self _parseErrorOccurred:self.parserError hasImpl:&hasImpl];
    }

    -(void)xmlStructuredErrorCallBack:(xmlErrorPtr)error {
        [self.logger debug:@"%@", PGFormat(PGXMLInsideCallbackMsg, NSStringFromSelector(_cmd))];
        BOOL     hasImpl = NO;
        NSString *msg    = [NSString stringWithFormat:@"(%d:%d) %@", error->domain, error->code, [NSString stringWithUTF8String:error->message]];
        self.parserError = createError(PGErrorCodeXMLParserStructError, msg);
        [self _parseErrorOccurred:self.parserError hasImpl:&hasImpl];
    }

#pragma mark libxml setup and tear-down

    -(void)setupSAXHandlerStructure {
        LIBXML_TEST_VERSION
        self.saxHandler = PGCalloc(1, sizeof(xmlSAXHandler));

        self.saxHandler->initialized           = XML_SAX2_MAGIC;
        self.saxHandler->internalSubset        = internalSubsetCallBack;
        self.saxHandler->externalSubset        = externalSubsetCallBack;
        self.saxHandler->resolveEntity         = resolveEntityCallBack;
        self.saxHandler->getEntity             = getEntityCallBack;
        self.saxHandler->getParameterEntity    = getParameterEntityCallBack;
        self.saxHandler->entityDecl            = entityDeclCallBack;
        self.saxHandler->unparsedEntityDecl    = unparsedEntityDeclCallBack;
        self.saxHandler->notationDecl          = notationDeclCallBack;
        self.saxHandler->attributeDecl         = attributeDeclCallBack;
        self.saxHandler->elementDecl           = elementDeclCallBack;
        self.saxHandler->startDocument         = startDocumentCallBack;
        self.saxHandler->endDocument           = endDocumentCallBack;
        self.saxHandler->startElement          = startElementCallBack;
        self.saxHandler->endElement            = endElementCallBack;
        self.saxHandler->reference             = referenceCallBack;
        self.saxHandler->characters            = charactersCallBack;
        self.saxHandler->ignorableWhitespace   = ignorableWhitespaceCallBack;
        self.saxHandler->processingInstruction = processingInstructionCallBack;
        self.saxHandler->comment               = commentCallBack;
        self.saxHandler->warning               = warningCallBack;
        self.saxHandler->error                 = errorCallBack;
        self.saxHandler->fatalError            = fatalErrorCallBack;
        self.saxHandler->cdataBlock            = cdataBlockCallBack;
        self.saxHandler->startElementNs        = startElementNsCallBack;
        self.saxHandler->endElementNs          = endElementNsCallBack;
        self.saxHandler->serror                = xmlStructuredErrorCallBack;
    }

    -(void)destroySAXHandlerStructure {
        if(self.saxHandler) {
            memset(self.saxHandler, 0, sizeof(xmlSAXHandler));
            free(self.saxHandler);
            self.saxHandler = NULL;
        }

        xmlCleanupParser();
        xmlMemoryDump();
    }

    -(void)destroyParserContext {
        xmlFreeParserCtxt(self.ctx);
        self.ctx = NULL;
    }

#pragma mark Initialize Static Fields

    +(void)initialize {
        static dispatch_once_t _initOnce = 0;
        dispatch_once(&_initOnce, ^{
            /*
             * This will initialize the library and check potential ABI
             * mismatches between the version it was compiled for and
             * the actual shared library used.
             */
            LIBXML_TEST_VERSION
        });
    }

@end
