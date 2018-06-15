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

#define PG_DEF_BUF_SZ ((size_t)(128))

static SEL NSInputStreamReadSel;

@implementation PGXMLParser {
        NSRecursiveLock     *_lck;
        NSMutableDictionary *_entities;
        NSMutableArray      *_namespaceStack;

        id<PGXMLParserDelegate> __unsafe_unretained _delegate;
    }

#pragma mark Constructors and Destructors

    -(instancetype)init {
        self = [super init];
        if(self) @throw [NSException exceptionWithName:NSIllegalSelectorException reason:PGErrorMsgInvalidConstructor];
        return self;
    }

    -(instancetype)initWithInputStream:(NSInputStream *)stream {
        self = [super init];

        if(self) {
            self.input    = stream;
            self.readFunc = (NSInputStreamReadFunc)[self.input methodForSelector:NSInputStreamReadSel];
        }

        return self;
    }

    -(instancetype)initWithFilePath:(NSString *)filepath {
        self = [self initWithInputStream:[NSInputStream inputStreamWithFileAtPath:filepath]];
        if(self) self.filename = [filepath copy];
        return self;
    }

    -(instancetype)initWithURL:(NSURL *)url {
        self = [self initWithInputStream:[NSInputStream inputStreamWithURL:url]];
        if(self) self.filename = [[url description] copy];
        return self;
    }

    -(void)dealloc {
        [self destroySAXHandlerStructure];
    }

#pragma mark Getters and Setters

    -(NSMutableDictionary<NSString *, PGXMLParsedEntity *> *)entities {
        if(!_entities) { @synchronized(self) { if(!_entities) _entities = [NSMutableDictionary new]; }}
        return _entities;
    }

    -(NSMutableArray<NSArray<PGXMLParsedNamespace *> *> *)namespaceStack {
        if(!_namespaceStack) { @synchronized(self) { if(!_namespaceStack) _namespaceStack = [NSMutableArray new]; }}
        return _namespaceStack;
    }

    -(NSRecursiveLock *)lck {
        if(!_lck) { @synchronized(self) { if(!_lck) _lck = [NSRecursiveLock new]; }}
        return _lck;
    }

    -(id<PGXMLParserDelegate>)delegate {
        [self.lck lock];
        id<PGXMLParserDelegate> d = _delegate;
        [self.lck unlock];
        return d;
    }

    -(void)setDelegate:(id<PGXMLParserDelegate>)delegate {
        [self.lck lock];
        @try { if(_delegate != delegate) [self updateDelegateFunctions:(_delegate = delegate)]; } @finally { [self.lck unlock]; }
    }

#pragma mark Parsing

    -(BOOL)parseChunkWithBuffer:(void *)buffer maxLength:(NSUInteger)length {
        NSInputStream *input  = self.input;
        NSInteger     rcount  = (*self.readFunc)(input, NSInputStreamReadSel, buffer, length);
        BOOL          success = YES;

        while(success && (rcount > 0)) {
            if((success = parseChunk(self, buffer, rcount, NO, success))) rcount = (*self.readFunc)(input, NSInputStreamReadSel, buffer, length);
        }

        success = parseChunk(self, buffer, 0, YES, success);
        self.parserError = (((rcount >= 0) || success || self.parserError) ? self.parserError : self.getInputStreamError);
        return success;
    }

    -(BOOL)parseWithBuffer:(void *)buffer maxLength:(NSUInteger)length bytesRead:(NSInteger)bytesRead filename:(const char *)filename {
        if(createPushContext(self, buffer, bytesRead, filename)) {
            @try {
                return [self parseChunkWithBuffer:buffer maxLength:length];
            }
            @finally { [self destroyParserContext]; }
        }
        return NO;
    }

    -(BOOL)parseWithBuffer:(void *)buffer maxLength:(NSUInteger)length bytesRead:(NSInteger)bytesRead {
        char *filename = PGStrdup(self.filename ? self.filename.UTF8String : "");
        @try { return [self parseWithBuffer:buffer maxLength:length bytesRead:bytesRead filename:filename]; } @finally { free(filename); }
    }

    -(BOOL)parseWithBuffer:(void *)buffer maxLength:(NSUInteger)length {
        BOOL      success    = NO;
        NSInteger readStatus = (*self.readFunc)(self.input, NSInputStreamReadSel, buffer, length);

        if(readStatus > 0) {
            self.parserError = nil;
            [self setupSAXHandlerStructure];
            @try { success = [self parseWithBuffer:buffer maxLength:length bytesRead:readStatus]; } @finally { [self destroySAXHandlerStructure]; }
        }
        else if(readStatus == 0) self.parserError = createError(PGErrorCodeUnexpectedEndOfInput, PGErrorMsgUnexpectedEndOfInput);
        else self.parserError = self.getInputStreamError;

        return success;
    }

    -(BOOL)parse04 {
        uint8_t *buffer = PGMalloc(PG_DEF_BUF_SZ);
        @try { return [self parseWithBuffer:buffer maxLength:PG_DEF_BUF_SZ]; } @finally { free(buffer); }
    }

    -(BOOL)parse03 {
        @try { return self.parse04; } @finally { [self.input close]; }
    }

    -(BOOL)parse02 {
        @try {
            return (self.openInputStream && self.parse03);
        }
        @finally {
            self.hasRun = YES;
        }
    }

    -(BOOL)parse01 {
        @try {
            if(self.hasRun) self.parserError = createError(PGErrorCodeXMLParserAlreadyRun, PGErrorMsgXMLParserAlreadyRun);
            else if(!self.input) self.parserError = createError(PGErrorCodeNoInputStream, PGErrorMsgNoInputStream);
            else if(!self.delegate) self.parserError = createError(PGErrorCodeNoDelegate, PGErrorMsgNoDelegate);
            else return self.parse02;
        }
        @catch(NSException *e) {
            if(!self.parserError) self.parserError = e.makeError;
        }
        return NO;
    }

    -(BOOL)parse {
        [self.lck lock];
        @try { return self.parse01; } @finally { [self.lck unlock]; }
    }

    -(BOOL)openInputStream {
        return ((self.parserError = PGOpenInputStream(self.input)) == nil);
    }

    -(NSError *)getInputStreamError {
        return (self.input.streamError ?: createError(PGErrorCodeUnknownInputStreamError, PGErrorMsgUnknownInputStreamError));
    }

#pragma mark libxml2 Callback Handlers

    -(xmlParserInputPtr)resolveEntityCallBack:(NSString *)publicId systemId:(NSString *)systemId {
        BOOL   hasImpl = NO;
        NSData *data   = [self _resolveExternalEntityForName:publicId systemID:systemId hasImpl:&hasImpl];
        int    blen    = (int)data.length;

        if(blen) {
            char *buf = PGMalloc((size_t)blen);

            @try {
                [data getBytes:buf length:(NSUInteger)blen];
                xmlParserInputBufferPtr pib = xmlParserInputBufferCreateMem(buf, blen, XML_CHAR_ENCODING_UTF8);
                return xmlNewIOInputStream(self.ctx, pib, XML_CHAR_ENCODING_UTF8);
            }
            @finally { free(buf); }
        }

        return xmlLoadExternalEntity(publicId.UTF8String, systemId.UTF8String, self.ctx);
    }

    -(void)internalSubsetCallBack:(NSString *)name ExternalID:(NSString *)ExternalID SystemID:(NSString *)SystemID {
        [[PGLogger sharedInstanceWithClass:self.class] debug:@"Internal Subset Call Back; Name: \"%@\"; External ID: \"%@\"; System ID: \"%@\"", name, ExternalID, SystemID];
    }

    -(void)externalSubsetCallBack:(NSString *)name ExternalID:(NSString *)ExternalID SystemID:(NSString *)SystemID {
        [[PGLogger sharedInstanceWithClass:self.class] debug:@"External Subset Call Back; Name: \"%@\"; External ID: \"%@\"; System ID: \"%@\"", name, ExternalID, SystemID];
    }

    -(xmlEntityPtr)getEntityCallBack:(NSString *)name {
        BOOL              hasImpl  = NO;
        PGXMLParsedEntity *ent     = self.entities[name];
        NSString          *content = [self _resolveInternalEntityForName:name hasImpl:&hasImpl];

        if(ent && content) ent.content = content; else if(content) self.entities[name] = ent = [PGXMLParsedEntity entityWithName:name content:content];
        return ent.xmlEntity;
    }

    -(xmlEntityPtr)getParameterEntityCallBack:(NSString *)name {
        return [self getEntityCallBack:name];
    }

    -(void)entityDeclCallBack:(NSString *)name type:(int)type publicId:(NSString *)publicId systemId:(NSString *)systemId content:(NSString *)content {
        PGXMLParsedEntity *ent = self.entities[name];

        if(ent) {
            ent.content  = content;
            ent.publicID = publicId;
            ent.systemID = systemId;
            ent.type     = (xmlEntityType)type;
        }
        else {
            self.entities[name] = [PGXMLParsedEntity entityWithName:name content:content publicID:publicId systemID:systemId type:(xmlEntityType)type];
        }
        BOOL hasImpl = NO;

        [self _foundInternalEntityDeclarationWithName:name value:content hasImpl:&hasImpl];
    }

    -(void)notationDeclCallBack:(NSString *)name publicId:(NSString *)publicId systemId:(NSString *)systemId {
        BOOL hasImpl = NO;
        [self _foundNotationDeclarationWithName:name publicID:publicId systemID:systemId hasImpl:&hasImpl];
    }

    -(void)attributeDeclCallBack:(NSString *)elem fullname:(NSString *)fullname type:(int)type def:(int)def defaultValue:(NSString *)defaultValue tree:(xmlEnumerationPtr)tree {
        BOOL hasImpl = NO;
        [self _foundAttributeDeclarationWithName:fullname forElement:elem type:[@(type) stringValue] defaultValue:defaultValue hasImpl:&hasImpl];
    }

    -(void)elementDeclCallBack:(NSString *)name type:(int)type content:(xmlElementContentPtr)content {
        BOOL hasImpl = NO;
        [self _foundElementDeclarationWithName:name model:nil hasImpl:&hasImpl];
    }

    -(void)unparsedEntityDeclCallBack:(NSString *)name publicId:(NSString *)publicId systemId:(NSString *)systemId notationName:(NSString *)notationName {
        BOOL hasImpl = NO;
        [self _foundUnparsedEntityDeclarationWithName:name publicID:publicId systemID:systemId notationName:notationName hasImpl:&hasImpl];
    }

    -(void)startDocumentCallBack {
        BOOL hasImpl = NO;
        [self _didStartDocument:&hasImpl];
    }

    -(void)endDocumentCallBack {
        BOOL hasImpl = NO;
        [self _didEndDocument:&hasImpl];
    }

    -(void)startElementCallBack:(NSString *)name attributes:(NSArray<PGXMLParsedAttribute *> *)attributes {
        BOOL hasImpl = NO;
        [self _didStartElement:name namespaceURI:nil qualifiedName:nil attributes:attributes hasImpl:&hasImpl];
    }

    -(void)endElementCallBack:(NSString *)name {
        BOOL hasImpl = NO;
        [self _didEndElement:name namespaceURI:nil qualifiedName:nil hasImpl:&hasImpl];
    }

    -(void)startElementNsCallBack:(NSString *)localname
                           prefix:(NSString *)prefix
                              URI:(NSString *)URI
                       namespaces:(NSArray<PGXMLParsedNamespace *> *)namespaces
                       attributes:(NSArray<PGXMLParsedAttribute *> *)attributes {
        BOOL hasImpl = NO;
        [self.namespaceStack addObject:(namespaces.count ? namespaces : @[])];
        [self startMappingPrefixes:namespaces hasImpl:&hasImpl];
        [self _didStartElement:localname namespaceURI:URI qualifiedName:createQName(localname, prefix) attributes:attributes hasImpl:&hasImpl];
    }

    -(void)endElementNsCallBack:(NSString *)localname prefix:(NSString *)prefix URI:(NSString *)URI {
        BOOL hasImpl = NO;
        [self _didEndElement:localname namespaceURI:URI qualifiedName:createQName(localname, prefix) hasImpl:&hasImpl];
        [self endMappingPrefixes:self.namespaceStack.popLastObject hasImpl:&hasImpl];
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

    -(void)referenceCallBack:(NSString *)name {
        BOOL     hasImpl  = NO;
        NSString *content = [self _resolveInternalEntityForName:name hasImpl:&hasImpl];

        if(hasImpl && content) {
            hasImpl = NO;
            [self _foundCharacters:content hasImpl:&hasImpl];
        }
    }

    -(void)charactersCallBack:(NSString *)ch {
        BOOL hasImpl = NO;
        [self _foundCharacters:ch hasImpl:&hasImpl];
    }

    -(void)ignorableWhitespaceCallBack:(NSString *)ch {
        BOOL hasImpl = NO;
        [self _foundIgnorableWhitespace:ch hasImpl:&hasImpl];
    }

    -(void)processingInstructionCallBack:(NSString *)target data:(NSString *)data {
        BOOL hasImpl = NO;
        [self _foundProcessingInstructionWithTarget:target data:data hasImpl:&hasImpl];
    }

    -(void)commentCallBack:(NSString *)value {
        BOOL hasImpl = NO;
        [self _foundComment:value hasImpl:&hasImpl];
    }

    -(void)cdataBlockCallBack:(NSString *)value {
        BOOL hasImpl = NO;

        if(value) {
            char   *str  = strdup(value.UTF8String);
            NSData *data = [NSData dataWithBytesNoCopy:str length:strlen(str) freeWhenDone:YES];
            [self _foundCDATA:data hasImpl:&hasImpl];
        }
        else [self _foundCDATA:[NSData new] hasImpl:&hasImpl];
    }

    -(void)warningCallBack:(NSString *)msg {
        BOOL hasImpl = NO;
        self.parserError = createError(PGErrorCodeXMLParserWarning, msg);
        [self _parseErrorOccurred:self.parserError hasImpl:&hasImpl];
    }

    -(void)errorCallBack:(NSString *)msg {
        BOOL hasImpl = NO;
        // int  col     = self.ctx->input->col;
        // int  lin     = self.ctx->input->line;
        self.parserError = createError(PGErrorCodeXMLParserError, msg);
        [self _parseErrorOccurred:self.parserError hasImpl:&hasImpl];
    }

    -(void)fatalErrorCallBack:(NSString *)msg {
        BOOL hasImpl = NO;
        self.parserError = createError(PGErrorCodeXMLParserFatalError, msg);
        [self _parseErrorOccurred:self.parserError hasImpl:&hasImpl];
    }

    -(void)xmlStructuredErrorCallBack:(xmlErrorPtr)error {
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
        self.saxHandler->resolveEntity         = resolveEntityCallBack;
        self.saxHandler->getEntity             = getEntityCallBack;
        self.saxHandler->entityDecl            = entityDeclCallBack;
        self.saxHandler->notationDecl          = notationDeclCallBack;
        self.saxHandler->attributeDecl         = attributeDeclCallBack;
        self.saxHandler->elementDecl           = elementDeclCallBack;
        self.saxHandler->unparsedEntityDecl    = unparsedEntityDeclCallBack;
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
        self.saxHandler->getParameterEntity    = getParameterEntityCallBack;
        self.saxHandler->cdataBlock            = cdataBlockCallBack;
        self.saxHandler->externalSubset        = externalSubsetCallBack;
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
            NSInputStreamReadSel = @selector(read:maxLength:);
            [self setSelectors];
        });
    }

@end

