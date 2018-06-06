/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParser+PGXMLParserExtensions.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/30/18
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

#import "PGXMLParsedAttribute.h"
#import "PGXMLParser+PGXMLParserExtensions.h"
#import "PGXMLParserTools.h"

static SEL PGXMLFoundNoteDeclSel;
static SEL PGXMLFoundUnpEntDeclSel;
static SEL PGXMLFoundAttrDeclSel;
static SEL PGXMLFoundElemDeclSel;
static SEL PGXMLFoundIntEntDeclSel;
static SEL PGXMLFoundExtEntDeclSel;
static SEL PGXMLDidStartDocSel;
static SEL PGXMLDidEndDocSel;
static SEL PGXMLDidStartElemSel;
static SEL PGXMLDidEndElemSel;
static SEL PGXMLDidStartMapPfxSel;
static SEL PGXMLDidEndMapPfxSel;
static SEL PGXMLFoundCharsSel;
static SEL PGXMLFoundIgWhitespSel;
static SEL PGXMLFoundProcInstSel;
static SEL PGXMLFoundCommentSel;
static SEL PGXMLFoundCDATASel;
static SEL PGXMLResolveExtEntSel;
static SEL PGXMLParseErrSel;
static SEL PGXMLValidationErrSel;
static SEL PGXMLReslvIntEntSel;

@implementation PGXMLParser(PGXMLParserExtensions)

#pragma mark Delegate method handling

    +(void)setSelectors {
        static dispatch_once_t pgxmlparser1Once = 0;

        dispatch_once(&pgxmlparser1Once, ^{
            PGXMLFoundNoteDeclSel   = @selector(parser:foundNotationDeclarationWithName:publicID:systemID:);
            PGXMLFoundUnpEntDeclSel = @selector(parser:foundUnparsedEntityDeclarationWithName:publicID:systemID:notationName:);
            PGXMLFoundAttrDeclSel   = @selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:);
            PGXMLFoundElemDeclSel   = @selector(parser:foundElementDeclarationWithName:model:);
            PGXMLFoundIntEntDeclSel = @selector(parser:foundInternalEntityDeclarationWithName:value:);
            PGXMLFoundExtEntDeclSel = @selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:);
            PGXMLDidStartElemSel    = @selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:);
            PGXMLDidEndElemSel      = @selector(parser:didEndElement:namespaceURI:qualifiedName:);
            PGXMLDidStartMapPfxSel  = @selector(parser:didStartMappingPrefix:toURI:);
            PGXMLDidEndMapPfxSel    = @selector(parser:didEndMappingPrefix:);
            PGXMLFoundCharsSel      = @selector(parser:foundCharacters:);
            PGXMLFoundIgWhitespSel  = @selector(parser:foundIgnorableWhitespace:);
            PGXMLFoundProcInstSel   = @selector(parser:foundProcessingInstructionWithTarget:data:);
            PGXMLFoundCommentSel    = @selector(parser:foundComment:);
            PGXMLFoundCDATASel      = @selector(parser:foundCDATA:);
            PGXMLResolveExtEntSel   = @selector(parser:resolveExternalEntityName:systemID:);
            PGXMLParseErrSel        = @selector(parser:parseErrorOccurred:);
            PGXMLValidationErrSel   = @selector(parser:validationErrorOccurred:);
            PGXMLDidStartDocSel     = @selector(parserDidStartDocument:);
            PGXMLDidEndDocSel       = @selector(parserDidEndDocument:);
            PGXMLReslvIntEntSel     = @selector(parser:resolveInternalEntityForName:);
        });
    }

    -(void)updateDelegateFunctions:(id<PGXMLParserDelegate>)d {
        // @f:0
        self.foundNoteDeclFunc   = ([d respondsToSelector:PGXMLFoundNoteDeclSel]   ? [d methodForSelector:PGXMLFoundNoteDeclSel]   : nil);
        self.foundUnpEntDeclFunc = ([d respondsToSelector:PGXMLFoundUnpEntDeclSel] ? [d methodForSelector:PGXMLFoundUnpEntDeclSel] : nil);
        self.foundAttrDeclFunc   = ([d respondsToSelector:PGXMLFoundAttrDeclSel]   ? [d methodForSelector:PGXMLFoundAttrDeclSel]   : nil);
        self.foundElemDeclFunc   = ([d respondsToSelector:PGXMLFoundElemDeclSel]   ? [d methodForSelector:PGXMLFoundElemDeclSel]   : nil);
        self.foundIntEntDeclFunc = ([d respondsToSelector:PGXMLFoundIntEntDeclSel] ? [d methodForSelector:PGXMLFoundIntEntDeclSel] : nil);
        self.foundExtEntDeclFunc = ([d respondsToSelector:PGXMLFoundExtEntDeclSel] ? [d methodForSelector:PGXMLFoundExtEntDeclSel] : nil);
        self.didStartDocFunc     = ([d respondsToSelector:PGXMLDidStartDocSel]     ? [d methodForSelector:PGXMLDidStartDocSel]     : nil);
        self.didEndDocFunc       = ([d respondsToSelector:PGXMLDidEndDocSel]       ? [d methodForSelector:PGXMLDidEndDocSel]       : nil);
        self.didStartElemFunc    = ([d respondsToSelector:PGXMLDidStartElemSel]    ? [d methodForSelector:PGXMLDidStartElemSel]    : nil);
        self.didEndElemFunc      = ([d respondsToSelector:PGXMLDidEndElemSel]      ? [d methodForSelector:PGXMLDidEndElemSel]      : nil);
        self.didStartMapPfxFunc  = ([d respondsToSelector:PGXMLDidStartMapPfxSel]  ? [d methodForSelector:PGXMLDidStartMapPfxSel]  : nil);
        self.didEndMapPfxFunc    = ([d respondsToSelector:PGXMLDidEndMapPfxSel]    ? [d methodForSelector:PGXMLDidEndMapPfxSel]    : nil);
        self.foundCharsFunc      = ([d respondsToSelector:PGXMLFoundCharsSel]      ? [d methodForSelector:PGXMLFoundCharsSel]      : nil);
        self.foundIgnWhitespFunc = ([d respondsToSelector:PGXMLFoundIgWhitespSel]  ? [d methodForSelector:PGXMLFoundIgWhitespSel]  : nil);
        self.foundProcInstFunc   = ([d respondsToSelector:PGXMLFoundProcInstSel]   ? [d methodForSelector:PGXMLFoundProcInstSel]   : nil);
        self.foundCommentFunc    = ([d respondsToSelector:PGXMLFoundCommentSel]    ? [d methodForSelector:PGXMLFoundCommentSel]    : nil);
        self.foundCDATAFunc      = ([d respondsToSelector:PGXMLFoundCDATASel]      ? [d methodForSelector:PGXMLFoundCDATASel]      : nil);
        self.resolveExtEntFunc   = ([d respondsToSelector:PGXMLResolveExtEntSel]   ? [d methodForSelector:PGXMLResolveExtEntSel]   : nil);
        self.parseErrFunc        = ([d respondsToSelector:PGXMLParseErrSel]        ? [d methodForSelector:PGXMLParseErrSel]        : nil);
        self.validationErrFunc   = ([d respondsToSelector:PGXMLValidationErrSel]   ? [d methodForSelector:PGXMLValidationErrSel]   : nil);
        self.reslvIntEntFunc     = ([d respondsToSelector:PGXMLReslvIntEntSel]     ? [d methodForSelector:PGXMLReslvIntEntSel]     : nil);
        // @f:1
    }

    -(void)_foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundNoteDeclFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundNoteDeclFunc)(self.delegate, PGXMLFoundNoteDeclSel, self, name, publicID, systemID);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundUnparsedEntityDeclarationWithName:(NSString *)name
                                          publicID:(NSString *)publicID
                                          systemID:(NSString *)systemID
                                      notationName:(NSString *)notationName
                                           hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundUnpEntDeclFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundUnpEntDeclFunc)(self.delegate, PGXMLFoundUnpEntDeclSel, self, name, publicID, systemID, notationName);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundAttributeDeclarationWithName:(NSString *)attributeName
                                   forElement:(NSString *)elementName
                                         type:(NSString *)type
                                 defaultValue:(NSString *)defaultValue
                                      hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundAttrDeclFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundAttrDeclFunc)(self.delegate, PGXMLFoundAttrDeclSel, self, attributeName, elementName, type, defaultValue);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundElemDeclFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundElemDeclFunc)(self.delegate, PGXMLFoundElemDeclSel, self, elementName, model);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundIntEntDeclFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundIntEntDeclFunc)(self.delegate, PGXMLFoundIntEntDeclSel, self, name, value);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundExtEntDeclFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundExtEntDeclFunc)(self.delegate, PGXMLFoundExtEntDeclSel, self, name, publicID, systemID);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_didStartDocument:(BOOL *)hasImpl {
        if(self.delegate && self.didStartDocFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.didStartDocFunc)(self.delegate, PGXMLDidStartDocSel, self);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_didEndDocument:(BOOL *)hasImpl {
        if(self.delegate && self.didEndDocFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.didEndDocFunc)(self.delegate, PGXMLDidEndDocSel, self);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_didStartElement:(NSString *)elementName
               namespaceURI:(NSString *)namespaceURI
              qualifiedName:(NSString *)qName
                 attributes:(NSArray<PGXMLParsedAttribute *> *)attributeDict
                    hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.didStartElemFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.didStartElemFunc)(self.delegate, PGXMLDidStartElemSel, self, elementName, namespaceURI, qName, attributeDict);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.didEndElemFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.didEndElemFunc)(self.delegate, PGXMLDidEndElemSel, self, elementName, namespaceURI, qName);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.didStartMapPfxFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.didStartMapPfxFunc)(self.delegate, PGXMLDidStartMapPfxSel, self, prefix, namespaceURI);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_didEndMappingPrefix:(NSString *)prefix hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.didEndMapPfxFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.didEndMapPfxFunc)(self.delegate, PGXMLDidEndMapPfxSel, self, prefix);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundCharacters:(NSString *)string hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundCharsFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundCharsFunc)(self.delegate, PGXMLFoundCharsSel, self, string);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundIgnorableWhitespace:(NSString *)whitespaceString hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundIgnWhitespFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundIgnWhitespFunc)(self.delegate, PGXMLFoundIgWhitespSel, self, whitespaceString);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundProcInstFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundProcInstFunc)(self.delegate, PGXMLFoundProcInstSel, self, target, data);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundComment:(NSString *)comment hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundCommentFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundCommentFunc)(self.delegate, PGXMLFoundCommentSel, self, comment);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_foundCDATA:(NSData *)CDATABlock hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.foundCDATAFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.foundCDATAFunc)(self.delegate, PGXMLFoundCDATASel, self, CDATABlock);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_parseErrorOccurred:(NSError *)parseError hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.parseErrFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.parseErrFunc)(self.delegate, PGXMLParseErrSel, self, parseError);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(void)_validationErrorOccurred:(NSError *)validationError hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.validationErrFunc) {
            if(hasImpl) *hasImpl = YES;
            (*self.validationErrFunc)(self.delegate, PGXMLValidationErrSel, self, validationError);
        }
        else {
            if(hasImpl) *hasImpl = NO;
        }
    }

    -(NSData *)_resolveExternalEntityForName:(NSString *)name systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.resolveExtEntFunc) {
            if(hasImpl) *hasImpl = YES;
            return (*self.resolveExtEntFunc)(self.delegate, PGXMLResolveExtEntSel, self, name, systemID);
        }
        else {
            if(hasImpl) *hasImpl = NO;
            return nil;
        }
    }

    -(NSString *)_resolveInternalEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl {
        if(self.delegate && self.reslvIntEntFunc) {
            if(hasImpl) *hasImpl = YES;
            return (*self.reslvIntEntFunc)(self.delegate, PGXMLReslvIntEntSel, self, name);
        }
        else {
            if(hasImpl) *hasImpl = NO;
            return nil;
        }
    }

@end
