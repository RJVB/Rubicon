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
    }

    @synthesize delegate = _delegate;
    @synthesize inputStream = _inputStream;
    @synthesize rlock = _rlock;
    @synthesize workingDelegate = _workingDelegate;
    @synthesize ctx = _ctx;
    @synthesize saxHandler = _saxHandler;
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
            self.saxHandler      = NULL;
            self.utf8Filename    = NULL;
            self.workingDelegate = nil;
            self.filename        = nil;
            self.inputStream     = nil;
            self.delegate        = nil;
            self.rlock           = [NSRecursiveLock new];
            self.entities        = [NSMutableDictionary new];
        }

        return self;
    }

    -(BOOL)parse:(NSError **)error {
        BOOL success = NO;

        [self.rlock lock];
        @try {
            if(self.hasAlreadyRun) PGSetError(error, XMLParser, XMLParserAlreadyRun);
            else success = pushParseXML(self, self.delegate, self.inputStream, error);
        }
        @catch(NSException *e) {
            PGSetReference(error, [e makeError:PGXMLParserErrorDomain]);
        }
        @finally { [self.rlock unlock]; }

        return success;
    }

    -(void)dealloc {
        postParseCleanup(self);
    }

#pragma mark SAX Callbacks

    -(void)internalSubset:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId {
        IMP               f = self.funcInternalSubset;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcInternalSubset, f)(d, _selInternalSubset, self, name, externalId, systemId);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)externalSubset:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId {
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

    -(nullable NSString *)getEntity:(nullable NSString *)name {
        IMP               f = self.funcGetEntity;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            return FOO(t_funcGetEntity, f)(d, _selGetEntity, self, name);
        }
        else {
            NSString *str = nil;
            /* TODO: Default Processing... */
            return str;
        }
    }

    -(nullable NSString *)getParameterEntity:(nullable NSString *)name {
        IMP               f = self.funcGetParameterEntity;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            return FOO(t_funcGetParameterEntity, f)(d, _selGetParameterEntity, self, name);
        }
        else {
            NSString *str = nil;
            /* TODO: Default Processing... */
            return str;
        }
    }

    -(nullable NSData *)resolveEntity:(nullable NSString *)publicId systemID:(nullable NSString *)systemId {
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

    -(void)entityDecl:(nullable NSString *)name type:(int)type publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId content:(nullable NSString *)content {
        IMP               f = self.funcEntityDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcEntityDecl, f)(d, _selEntityDecl, self, name, type, publicId, systemId, content);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)notationDecl:(nullable NSString *)name publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId {
        IMP               f = self.funcNotationDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcNotationDecl, f)(d, _selNotationDecl, self, name, publicId, systemId);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)attributeDecl:(nullable NSString *)elem fullname:(nullable NSString *)fname type:(int)type def:(int)def defaultValue:(nullable NSString *)defval tree:(NSArray *)tree {
        IMP               f = self.funcAttributeDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcAttributeDecl, f)(d, _selAttributeDecl, self, elem, fname, type, def, defval, tree);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)elementDecl:(nullable NSString *)name type:(int)type content:(nullable PGSAXElementDecl *)content {
        IMP               f = self.funcElementDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcElementDecl, f)(d, _selElementDecl, self, name, type, content);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)unparsedEntityDecl:(nullable NSString *)name publicID:(nullable NSString *)pubid systemID:(nullable NSString *)sysid notationName:(nullable NSString *)notnam {
        IMP               f = self.funcUnparsedEntityDecl;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcUnparsedEntityDecl, f)(d, _selUnparsedEntityDecl, self, name, pubid, sysid, notnam);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)setDocumentLocator:(nullable PGSAXLocator *)location {
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

    -(void)startElement:(nullable NSString *)name attributes:(NSArray<PGSAXAttribute *> *)attributes {
        IMP               f = self.funcStartElement;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcStartElement, f)(d, _selStartElement, self, name, attributes);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)endElement:(nullable NSString *)name {
        IMP               f = self.funcEndElement;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcEndElement, f)(d, _selEndElement, self, name);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)reference:(nullable NSString *)name {
        IMP               f = self.funcReference;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcReference, f)(d, _selReference, self, name);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)characters:(nullable NSString *)value {
        IMP               f = self.funcCharacters;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcCharacters, f)(d, _selCharacters, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)ignorableWhitespace:(nullable NSString *)value {
        IMP               f = self.funcIgnorableWhitespace;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcIgnorableWhitespace, f)(d, _selIgnorableWhitespace, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)processingInstruction:(nullable NSString *)target data:(nullable NSString *)data {
        IMP               f = self.funcProcessingInstruction;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcProcessingInstruction, f)(d, _selProcessingInstruction, self, target, data);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)comment:(nullable NSString *)value {
        IMP               f = self.funcComment;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcComment, f)(d, _selComment, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)cdataBlock:(nullable NSString *)value {
        IMP               f = self.funcCdataBlock;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcCdataBlock, f)(d, _selCdataBlock, self, value);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)startElemNS:(nullable NSString *)n pfx:(nullable NSString *)p URI:(nullable NSString *)u nspcs:(NSArray<PGSAXNamespace *> *)ns atts:(NSArray<PGSAXAttribute *> *)at {
        IMP               f = self.funcStartElementNS;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcStartElementNS, f)(d, _selStartElementNS, self, n, p, u, ns, at);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)endElementNS:(nullable NSString *)localname prefix:(nullable NSString *)prefix URI:(nullable NSString *)URI {
        IMP               f = self.funcEndElementNS;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcEndElementNS, f)(d, _selEndElementNS, self, localname, prefix, URI);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)xmlStructuredError:(nullable NSString *)msg {
        IMP               f = self.funcXmlStructuredError;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcXmlStructuredError, f)(d, _selXmlStructuredError, self, msg);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)warning:(nullable NSString *)msg {
        IMP               f = self.funcWarning;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcWarning, f)(d, _selWarning, self, msg);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)error:(nullable NSString *)msg {
        IMP               f = self.funcError;
        id<PGSAXDelegate> d = self.workingDelegate;

        if(f && d) {
            FOO(t_funcError, f)(d, _selError, self, msg);
        }
        else {
            /* TODO: Default Processing... */
        }
    }

    -(void)fatalError:(nullable NSString *)msg {
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

