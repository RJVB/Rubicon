/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXParser.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/20/18
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

@implementation PGSAXParser {
        PGSAXSimpleBuffer *_bufferList;
        NSUInteger        _bufferListSize;
        NSUInteger        _bufferListTop;
        xmlSAXHandler     _saxHandler;
    }

    @synthesize delegate = _delegate;
    @synthesize inputStream = _inputStream;
    @synthesize rlock = _rlock;
    @synthesize workingDelegate = _workingDelegate;
    @synthesize ctx = _ctx;
    @synthesize filename = _filename;
    @synthesize utf8Filename = _utf8Filename;
    @synthesize funcInternalSubset = _funcInternalSubset;
    @synthesize funcExternalSubset = _funcExternalSubset;
    @synthesize funcIsStandalone = _funcIsStandalone;
    @synthesize funcHasInternalSubset = _funcHasInternalSubset;
    @synthesize funcHasExternalSubset = _funcHasExternalSubset;
    @synthesize funcGetEntity = _funcGetEntity;
    @synthesize funcGetParameterEntity = _funcGetParameterEntity;
    @synthesize funcResolveEntity = _funcResolveEntity;
    @synthesize funcEntityDecl = _funcEntityDecl;
    @synthesize funcNotationDecl = _funcNotationDecl;
    @synthesize funcAttributeDecl = _funcAttributeDecl;
    @synthesize funcElementDecl = _funcElementDecl;
    @synthesize funcUnparsedEntityDecl = _funcUnparsedEntityDecl;
    @synthesize funcSetDocumentLocator = _funcSetDocumentLocator;
    @synthesize funcStartDocument = _funcStartDocument;
    @synthesize funcEndDocument = _funcEndDocument;
    @synthesize funcStartElement = _funcStartElement;
    @synthesize funcEndElement = _funcEndElement;
    @synthesize funcReference = _funcReference;
    @synthesize funcCharacters = _funcCharacters;
    @synthesize funcIgnorableWhitespace = _funcIgnorableWhitespace;
    @synthesize funcProcessingInstruction = _funcProcessingInstruction;
    @synthesize funcComment = _funcComment;
    @synthesize funcCdataBlock = _funcCdataBlock;
    @synthesize funcStartElementNS = _funcStartElementNS;
    @synthesize funcEndElementNS = _funcEndElementNS;
    @synthesize funcXmlStructuredError = _funcXmlStructuredError;
    @synthesize funcWarning = _funcWarning;
    @synthesize funcError = _funcError;
    @synthesize funcFatalError = _funcFatalError;
    @synthesize entities = _entities;
    @synthesize hasAlreadyRun = _hasAlreadyRun;

    -(instancetype)init {
        self = [super init];

        if(self) {
            self.hasAlreadyRun   = NO;
            self.ctx             = NULL;
            self.utf8Filename    = NULL;
            self.workingDelegate = nil;
            self.filename        = nil;
            self.delegate        = nil;
            self.rlock           = [NSRecursiveLock new];
            self.entities        = [NSMutableDictionary new];

            _bufferList     = NULL;
            _bufferListSize = 0;
            _bufferListTop  = 0;

            memset(&_saxHandler, 0, sizeof(xmlSAXHandler));
        }

        return self;
    }

    -(PGSAXSimpleBuffer *)createTempBuffer:(int)length {
        if(length) {
            @synchronized(self) {
                if(_bufferList == NULL) {
                    _bufferListSize = 5;
                    _bufferListTop  = 0;
                    _bufferList     = PGCalloc(_bufferListSize, sizeof(PGSAXSimpleBuffer));
                }
                else if(_bufferListTop == _bufferListSize) {
                    NSUInteger nsz = (_bufferListSize * 2);
                    _bufferList     = PGRealloc(_bufferList, nsz * sizeof(PGSAXSimpleBuffer));
                    _bufferListSize = nsz;
                }

                _bufferList[_bufferListTop].buffer = NULL;
                _bufferList[_bufferListTop].length = 0;
                _bufferList[_bufferListTop].buffer = PGMalloc((size_t)length);
                _bufferList[_bufferListTop].length = length;
                return &_bufferList[_bufferListTop++];
            }
        }

        return NULL;
    }

    -(instancetype)initWithInputStream:(NSInputStream *)inputStream baseURI:(NSURL *)baseURI {
        self = [self init];

        if(self) {
            if(inputStream) {
                self.inputStream = inputStream;
                self.filename    = [(baseURI ? baseURI.absoluteString : @"/") stringByAppendingPathComponent:@".raw_input_stream.xml"];
            }
            else {
                PGThrowInvArgException(@"Input Stream is required.");
            }
        }

        return self;
    }

    -(instancetype)initWithURL:(NSURL *)url {
        self = [self init];

        if(self) {
            if(url) {
                self.filename    = url.absoluteString;
                self.inputStream = [NSInputStream inputStreamWithURL:url];
            }
            else {
                PGThrowInvArgException(@"URL is required.");
            }
        }

        return self;
    }

    -(instancetype)initWithFilename:(NSString *)filename {
        self = [self init];

        if(self) {
            if(filename.length) {
                self.filename    = filename;
                self.inputStream = [NSInputStream inputStreamWithFileAtPath:filename];
            }
            else {
                PGThrowInvArgException(@"Filename is required.");
            }
        }

        return self;
    }

    -(void)deallocTempBuffers {
        PGLog(@"**** %@ ****", @"Deallocating Temp Buffers");

        @synchronized(self) {
            if(_bufferList) {
                PGSAXSimpleBuffer *bl = _bufferList;

                for(NSUInteger i = 0; i < _bufferListTop; ++i) {
                    if(bl->buffer) free(bl->buffer);
                    bl->length = 0;
                    bl++;
                }

                free(_bufferList);
            }

            _bufferList     = NULL;
            _bufferListTop  = 0;
            _bufferListSize = 0;
        }
    }

    -(void)postParseCleanup {
        PGLog(@"**** %@ ****", @"Post Parse Cleanup");

        if(self.ctx) xmlFreeParserCtxt(self.ctx);
        if(self.utf8Filename) free(self.utf8Filename);

        [self deallocTempBuffers];
        memset(&_saxHandler, 0, sizeof(xmlSAXHandler));

        self.ctx          = NULL;
        self.utf8Filename = NULL;

        self.workingDelegate           = nil;
        self.funcInternalSubset        = nil;
        self.funcExternalSubset        = nil;
        self.funcIsStandalone          = nil;
        self.funcHasInternalSubset     = nil;
        self.funcHasExternalSubset     = nil;
        self.funcGetEntity             = nil;
        self.funcGetParameterEntity    = nil;
        self.funcResolveEntity         = nil;
        self.funcEntityDecl            = nil;
        self.funcNotationDecl          = nil;
        self.funcAttributeDecl         = nil;
        self.funcElementDecl           = nil;
        self.funcUnparsedEntityDecl    = nil;
        self.funcSetDocumentLocator    = nil;
        self.funcStartDocument         = nil;
        self.funcEndDocument           = nil;
        self.funcStartElement          = nil;
        self.funcEndElement            = nil;
        self.funcReference             = nil;
        self.funcCharacters            = nil;
        self.funcIgnorableWhitespace   = nil;
        self.funcProcessingInstruction = nil;
        self.funcComment               = nil;
        self.funcCdataBlock            = nil;
        self.funcStartElementNS        = nil;
        self.funcEndElementNS          = nil;
        self.funcXmlStructuredError    = nil;
        self.funcWarning               = nil;
        self.funcError                 = nil;
        self.funcFatalError            = nil;

        [self.entities removeAllObjects];
    }

    -(BOOL)openInputStream:(NSError **)error {
        NSInputStream *instr = self.inputStream;

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

    -(void)populateFunctionFields {
        NSObject<PGSAXDelegate> *d = self.workingDelegate;
        self.funcInternalSubset        = ((d && [d respondsToSelector:_selInternalSubset]) ? [d methodForSelector:_selInternalSubset] : NULL);
        self.funcExternalSubset        = ((d && [d respondsToSelector:_selExternalSubset]) ? [d methodForSelector:_selExternalSubset] : NULL);
        self.funcIsStandalone          = ((d && [d respondsToSelector:_selIsStandalone]) ? [d methodForSelector:_selIsStandalone] : NULL);
        self.funcHasInternalSubset     = ((d && [d respondsToSelector:_selHasInternalSubset]) ? [d methodForSelector:_selHasInternalSubset] : NULL);
        self.funcHasExternalSubset     = ((d && [d respondsToSelector:_selHasExternalSubset]) ? [d methodForSelector:_selHasExternalSubset] : NULL);
        self.funcGetEntity             = ((d && [d respondsToSelector:_selGetEntity]) ? [d methodForSelector:_selGetEntity] : NULL);
        self.funcGetParameterEntity    = ((d && [d respondsToSelector:_selGetParameterEntity]) ? [d methodForSelector:_selGetParameterEntity] : NULL);
        self.funcResolveEntity         = ((d && [d respondsToSelector:_selResolveEntity]) ? [d methodForSelector:_selResolveEntity] : NULL);
        self.funcEntityDecl            = ((d && [d respondsToSelector:_selEntityDecl]) ? [d methodForSelector:_selEntityDecl] : NULL);
        self.funcNotationDecl          = ((d && [d respondsToSelector:_selNotationDecl]) ? [d methodForSelector:_selNotationDecl] : NULL);
        self.funcAttributeDecl         = ((d && [d respondsToSelector:_selAttributeDecl]) ? [d methodForSelector:_selAttributeDecl] : NULL);
        self.funcElementDecl           = ((d && [d respondsToSelector:_selElementDecl]) ? [d methodForSelector:_selElementDecl] : NULL);
        self.funcUnparsedEntityDecl    = ((d && [d respondsToSelector:_selUnparsedEntityDecl]) ? [d methodForSelector:_selUnparsedEntityDecl] : NULL);
        self.funcSetDocumentLocator    = ((d && [d respondsToSelector:_selSetDocumentLocator]) ? [d methodForSelector:_selSetDocumentLocator] : NULL);
        self.funcStartDocument         = ((d && [d respondsToSelector:_selStartDocument]) ? [d methodForSelector:_selStartDocument] : NULL);
        self.funcEndDocument           = ((d && [d respondsToSelector:_selEndDocument]) ? [d methodForSelector:_selEndDocument] : NULL);
        self.funcStartElement          = ((d && [d respondsToSelector:_selStartElement]) ? [d methodForSelector:_selStartElement] : NULL);
        self.funcEndElement            = ((d && [d respondsToSelector:_selEndElement]) ? [d methodForSelector:_selEndElement] : NULL);
        self.funcReference             = ((d && [d respondsToSelector:_selReference]) ? [d methodForSelector:_selReference] : NULL);
        self.funcCharacters            = ((d && [d respondsToSelector:_selCharacters]) ? [d methodForSelector:_selCharacters] : NULL);
        self.funcIgnorableWhitespace   = ((d && [d respondsToSelector:_selIgnorableWhitespace]) ? [d methodForSelector:_selIgnorableWhitespace] : NULL);
        self.funcProcessingInstruction = ((d && [d respondsToSelector:_selProcessingInstruction]) ? [d methodForSelector:_selProcessingInstruction] : NULL);
        self.funcComment               = ((d && [d respondsToSelector:_selComment]) ? [d methodForSelector:_selComment] : NULL);
        self.funcCdataBlock            = ((d && [d respondsToSelector:_selCdataBlock]) ? [d methodForSelector:_selCdataBlock] : NULL);
        self.funcStartElementNS        = ((d && [d respondsToSelector:_selStartElementNS]) ? [d methodForSelector:_selStartElementNS] : NULL);
        self.funcEndElementNS          = ((d && [d respondsToSelector:_selEndElementNS]) ? [d methodForSelector:_selEndElementNS] : NULL);
        self.funcXmlStructuredError    = ((d && [d respondsToSelector:_selXmlStructuredError]) ? [d methodForSelector:_selXmlStructuredError] : NULL);
        self.funcWarning               = ((d && [d respondsToSelector:_selWarning]) ? [d methodForSelector:_selWarning] : NULL);
        self.funcError                 = ((d && [d respondsToSelector:_selError]) ? [d methodForSelector:_selError] : NULL);
        self.funcFatalError            = ((d && [d respondsToSelector:_selFatalError]) ? [d methodForSelector:_selFatalError] : NULL);
    }

    -(BOOL)createPushContextWithBuffer:(const void *)buffer length:(NSUInteger)length {
        self.utf8Filename = strdup(self.filename ? self.filename.UTF8String : "");
        self.ctx          = xmlCreatePushParserCtxt(createSAXHandler(&_saxHandler), PG_BRDG_CAST(void)self, buffer, (int)length, self.utf8Filename);
        return (self.ctx != NULL);
    }

    -(BOOL)chunkParse:(void *)buffer readFunction:(IMP)fRead error:(NSError **)error {
        xmlParserCtxtPtr ctx    = self.ctx;
        NSInputStream    *instr = self.inputStream;
        NSInteger        length;
        BOOL             success, eof;

        do {
            length  = FOO(t_fRead, fRead)(instr, _selStreamRead, buffer, PGSAX_PUSH_BUFFER_SIZE);
            eof     = (length <= 0);
            success = (xmlParseChunk(ctx, buffer, (int)(eof ? 0 : length), eof) == 0);
        }
        while(success && !eof);

        if(length < 0) PGSetReference(error, instr.streamError);
        return (success && (length == 0));
    }

    -(BOOL)pushParse:(NSError **)error {
        NSInputStream *instr  = self.inputStream;
        BOOL          success = NO;
        NSByte        *buffer = PGMalloc(PGSAX_PUSH_BUFFER_SIZE);

        @try {
            _selStreamRead = @selector(read:maxLength:);
            IMP       fRead  = [instr methodForSelector:_selStreamRead];
            NSInteger length = FOO(t_fRead, fRead)(instr, _selStreamRead, buffer, PGSAX_PUSH_BUFFER_SIZE);

            if(length > 0) {
                if([self createPushContextWithBuffer:buffer length:(NSUInteger)length]) {
                    success = [self chunkParse:buffer readFunction:fRead error:error];
                }
                else {
                    PGSetError(error, XMLParser, XMLParserUnknownError);
                }
            }
            else if(length == 0) {
                PGSetError(error, XMLParser, UnexpectedEndOfInput);
            }
            else {
                PGSetReference(error, instr.streamError);
            }
        }
        @finally {
            free(buffer);
            self.hasAlreadyRun = YES;
        }

        return success;
    }

    -(BOOL)parse:(NSError **)error {
        BOOL success = NO;

        [self.rlock lock];
        @try {

            if(self.hasAlreadyRun) {
                PGSetError(error, XMLParser, XMLParserAlreadyRun);
            }
            else {
                id<PGSAXDelegate> delegate = self.delegate;

                if(delegate && self.inputStream) {
                    @try {
                        self.workingDelegate = delegate;
                        populateSelectorFields();
                        [self populateFunctionFields];
                        success = ([self openInputStream:error] && [self pushParse:error]);
                    }
                    @finally { [self postParseCleanup]; }
                }
                else if(delegate) {
                    PGSetError(error, XMLParser, NoInputStream);
                }
                else {
                    PGSetError(error, XMLParser, NoDelegate);
                }
            }
        }
        @catch(NSException *e) {
            PGSetReference(error, [e makeError:PGXMLParserErrorDomain]);
        }
        @finally { [self.rlock unlock]; }

        return success;
    }

    -(void)dealloc {
        [self postParseCleanup];
    }

#pragma mark SAX Callbacks

    -(void)internalSubset:(NSString *)name externalID:(NSString *)externalId systemID:(NSString *)systemId {
        IMP               f = self.funcInternalSubset;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcInternalSubset, f)(d, _selInternalSubset, self, name, externalId, systemId);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)externalSubset:(NSString *)name externalID:(NSString *)externalId systemID:(NSString *)systemId {
        IMP               f = self.funcExternalSubset;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcExternalSubset, f)(d, _selExternalSubset, self, name, externalId, systemId);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(BOOL)isStandalone {
        IMP               f = self.funcIsStandalone;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            return FOO(t_funcIsStandalone, f)(d, _selIsStandalone, self);
        }
        else {
            BOOL b = NO;
            /* TODO: Default Processing... */
            return b;
        }
    }

    -(BOOL)hasInternalSubset {
        IMP               f = self.funcHasInternalSubset;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            return FOO(t_funcHasInternalSubset, f)(d, _selHasInternalSubset, self);
        }
        else {
            BOOL b = NO;
            /* TODO: Default Processing... */
            return b;
        }
    }

    -(BOOL)hasExternalSubset {
        IMP               f = self.funcHasExternalSubset;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            return FOO(t_funcHasExternalSubset, f)(d, _selHasExternalSubset, self);
        }
        else {
            BOOL b = NO;
            /* TODO: Default Processing... */
            return b;
        }
    }

#define FMT_INSIDE @"Inside Callback> %@"
#define FMT_PARAM  @"        Param: \"%@\"; Value: \"%@\";"

    -(NSString *)getEntity:(NSString *)name {
        IMP               f = self.funcGetEntity;
        id<PGSAXDelegate> d = self.workingDelegate;

        PGLog(FMT_INSIDE, @"getEntity");
        PGLog(FMT_PARAM, @"name", name);

        if(f && d) {
            NSString *content = FOO(t_funcGetEntity, f)(d, _selGetEntity, self, name);
            if(content) return content;
        }

        return nil;
    }

    -(PGSAXEntity *)getLocalEntity:(NSString *)name {
        PGLog(@"            **** %@ ****", @"DEFAULTING");
        int tps[] = { XML_INTERNAL_GENERAL_ENTITY, XML_EXTERNAL_GENERAL_PARSED_ENTITY, XML_EXTERNAL_GENERAL_UNPARSED_ENTITY, XML_INTERNAL_PREDEFINED_ENTITY };

        for(int i = 0, j = (sizeof(tps) / sizeof(tps[0])); i < j; ++i) {
            NSString    *key    = PGFormat(SAX_ENTITY_KEY, name, @(tps[i]));
            PGSAXEntity *entity = self.entities[key];
            if(entity) return entity;
        }

        return nil;
    }

    -(PGSAXEntity *)getLocalParameterEntity:(NSString *)name {
        PGLog(@"            **** %@ ****", @"DEFAULTING");
        int tps[] = { XML_INTERNAL_PARAMETER_ENTITY, XML_EXTERNAL_PARAMETER_ENTITY };

        for(int i = 0, j = (sizeof(tps) / sizeof(tps[0])); i < j; ++i) {
            NSString    *key    = PGFormat(SAX_ENTITY_KEY, name, @(tps[i]));
            PGSAXEntity *entity = self.entities[key];
            if(entity) return entity;
        }

        return nil;
    }

    -(NSString *)getParameterEntity:(NSString *)name {
        IMP               f = self.funcGetParameterEntity;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            NSString *content = FOO(t_funcGetParameterEntity, f)(d, _selGetParameterEntity, self, name);
            if(content) return content;
        }

        return nil;
    }

    -(NSData *)resolveEntity:(NSString *)publicId systemID:(NSString *)systemId {
        IMP               f = self.funcResolveEntity;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            return FOO(t_funcResolveEntity, f)(d, _selResolveEntity, self, publicId, systemId);
        }
        else {
            NSData *data = nil;
            /* TODO: Default Processing... */
            return data;
        }
    }

    -(PGSAXEntity *)storeEntity:(NSString *)name type:(int)type publicID:(NSString *)publicId systemID:(NSString *)systemId content:(NSString *)content {
        PGLog(@"            **** %@: %@ ****", @"STORING ENTITY", name);
        if(name.length && content) {
            PGSAXEntity *entity = [PGSAXEntity entityWithName:name content:content type:type systemId:systemId publicId:publicId];
            NSString    *key    = PGFormat(SAX_ENTITY_KEY, name, @(type));
            self.entities[key] = entity;
            return entity;
        }
        return nil;
    }

    -(void)entityDecl:(NSString *)name type:(int)type publicID:(NSString *)publicId systemID:(NSString *)systemId content:(NSString *)content {
        IMP               f = self.funcEntityDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        [self storeEntity:name type:type publicID:publicId systemID:systemId content:content];

        if(f && d) {
            FOO(t_funcEntityDecl, f)(d, _selEntityDecl, self, name, type, publicId, systemId, content);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)notationDecl:(NSString *)name publicID:(NSString *)publicId systemID:(NSString *)systemId {
        IMP               f = self.funcNotationDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcNotationDecl, f)(d, _selNotationDecl, self, name, publicId, systemId);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)attributeDecl:(PGSAXAttributeDecl *)attrdecl {
        IMP               f = self.funcAttributeDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcAttributeDecl, f)(d, _selAttributeDecl, self, attrdecl);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)elementDecl:(NSString *)name type:(int)type content:(PGSAXElementDecl *)content {
        IMP               f = self.funcElementDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcElementDecl, f)(d, _selElementDecl, self, name, type, content);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)unparsedEntityDecl:(NSString *)name publicID:(NSString *)pubid systemID:(NSString *)sysid notationName:(NSString *)notnam {
        IMP               f = self.funcUnparsedEntityDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcUnparsedEntityDecl, f)(d, _selUnparsedEntityDecl, self, name, pubid, sysid, notnam);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)setDocumentLocator:(PGSAXLocator *)location {
        IMP               f = self.funcSetDocumentLocator;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcSetDocumentLocator, f)(d, _selSetDocumentLocator, self, location);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)startDocument {
        IMP               f = self.funcStartDocument;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcStartDocument, f)(d, _selStartDocument, self);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)endDocument {
        IMP               f = self.funcEndDocument;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcEndDocument, f)(d, _selEndDocument, self);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)startElement:(NSString *)name attributes:(NSArray<PGSAXAttribute *> *)attributes {
        IMP               f = self.funcStartElement;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcStartElement, f)(d, _selStartElement, self, name, attributes);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)endElement:(NSString *)name {
        IMP               f = self.funcEndElement;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcEndElement, f)(d, _selEndElement, self, name);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)reference:(NSString *)name {
        IMP               f = self.funcReference;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcReference, f)(d, _selReference, self, name);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)characters:(NSString *)value {
        IMP               f = self.funcCharacters;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcCharacters, f)(d, _selCharacters, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)ignorableWhitespace:(NSString *)value {
        IMP               f = self.funcIgnorableWhitespace;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcIgnorableWhitespace, f)(d, _selIgnorableWhitespace, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)processingInstruction:(NSString *)target data:(NSString *)data {
        IMP               f = self.funcProcessingInstruction;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcProcessingInstruction, f)(d, _selProcessingInstruction, self, target, data);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)comment:(NSString *)value {
        IMP               f = self.funcComment;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcComment, f)(d, _selComment, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)cdataBlock:(NSString *)value {
        IMP               f = self.funcCdataBlock;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcCdataBlock, f)(d, _selCdataBlock, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)startElemNS:(NSString *)n pfx:(NSString *)p URI:(NSString *)u nspcs:(NSArray<PGSAXNamespace *> *)ns atts:(NSArray<PGSAXAttribute *> *)at {
        IMP               f = self.funcStartElementNS;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcStartElementNS, f)(d, _selStartElementNS, self, n, p, u, ns, at);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)endElementNS:(NSString *)localname prefix:(NSString *)prefix URI:(NSString *)URI {
        IMP               f = self.funcEndElementNS;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcEndElementNS, f)(d, _selEndElementNS, self, localname, prefix, URI);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)structuredError:(NSString *)msg {
        IMP               f = self.funcXmlStructuredError;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcXmlStructuredError, f)(d, _selXmlStructuredError, self, msg);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)warning:(NSString *)msg {
        IMP               f = self.funcWarning;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcWarning, f)(d, _selWarning, self, msg);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)error:(NSString *)msg {
        IMP               f = self.funcError;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcError, f)(d, _selError, self, msg);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)fatalError:(NSString *)msg {
        IMP               f = self.funcFatalError;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcFatalError, f)(d, _selFatalError, self, msg);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

@end

