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

#import "PGXMLParser+PGXMLParserExtensions.h"

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
static SEL PGXMLParseErrSel;
static SEL PGXMLValidationErrSel;
static SEL PGXMLReslvExtEntSel;
static SEL PGXMLReslvIntEntSel;
static SEL PGXMLReslvIntPEntSel;

@implementation PGXMLParser(PGXMLParserExtensions)

#pragma mark Delegate method handling

    +(void)setSelectors {
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
        PGXMLParseErrSel        = @selector(parser:parseErrorOccurred:);
        PGXMLValidationErrSel   = @selector(parser:validationErrorOccurred:);
        PGXMLDidStartDocSel     = @selector(parserDidStartDocument:);
        PGXMLDidEndDocSel       = @selector(parserDidEndDocument:);
        PGXMLReslvExtEntSel     = @selector(parser:resolveExternalEntityName:systemID:);
        PGXMLReslvIntEntSel     = @selector(parser:resolveInternalEntityForName:);
        PGXMLReslvIntPEntSel    = @selector(parser:resolveInternalParameterEntityForName:);
    }

    -(void)updateDelegateFunctions:(NSObject<PGXMLParserDelegate> *)d {
        // @f:0
        self.foundNoteDeclFunc   =   (PGXMLFoundNoteDeclFunc_t)([d respondsToSelector:PGXMLFoundNoteDeclSel]   ? [d methodForSelector:PGXMLFoundNoteDeclSel]   : nil);
        self.foundUnpEntDeclFunc = (PGXMLFoundUnpEntDeclFunc_t)([d respondsToSelector:PGXMLFoundUnpEntDeclSel] ? [d methodForSelector:PGXMLFoundUnpEntDeclSel] : nil);
        self.foundAttrDeclFunc   =   (PGXMLFoundAttrDeclFunc_t)([d respondsToSelector:PGXMLFoundAttrDeclSel]   ? [d methodForSelector:PGXMLFoundAttrDeclSel]   : nil);
        self.foundElemDeclFunc   =   (PGXMLFoundElemDeclFunc_t)([d respondsToSelector:PGXMLFoundElemDeclSel]   ? [d methodForSelector:PGXMLFoundElemDeclSel]   : nil);
        self.foundIntEntDeclFunc = (PGXMLFoundIntEntDeclFunc_t)([d respondsToSelector:PGXMLFoundIntEntDeclSel] ? [d methodForSelector:PGXMLFoundIntEntDeclSel] : nil);
        self.foundExtEntDeclFunc = (PGXMLFoundExtEntDeclFunc_t)([d respondsToSelector:PGXMLFoundExtEntDeclSel] ? [d methodForSelector:PGXMLFoundExtEntDeclSel] : nil);
        self.didStartDocFunc     =     (PGXMLDidStartDocFunc_t)([d respondsToSelector:PGXMLDidStartDocSel]     ? [d methodForSelector:PGXMLDidStartDocSel]     : nil);
        self.didEndDocFunc       =       (PGXMLDidEndDocFunc_t)([d respondsToSelector:PGXMLDidEndDocSel]       ? [d methodForSelector:PGXMLDidEndDocSel]       : nil);
        self.didStartElemFunc    =    (PGXMLDidStartElemFunc_t)([d respondsToSelector:PGXMLDidStartElemSel]    ? [d methodForSelector:PGXMLDidStartElemSel]    : nil);
        self.didEndElemFunc      =      (PGXMLDidEndElemFunc_t)([d respondsToSelector:PGXMLDidEndElemSel]      ? [d methodForSelector:PGXMLDidEndElemSel]      : nil);
        self.didStartMapPfxFunc  =  (PGXMLDidStartMapPfxFunc_t)([d respondsToSelector:PGXMLDidStartMapPfxSel]  ? [d methodForSelector:PGXMLDidStartMapPfxSel]  : nil);
        self.didEndMapPfxFunc    =    (PGXMLDidEndMapPfxFunc_t)([d respondsToSelector:PGXMLDidEndMapPfxSel]    ? [d methodForSelector:PGXMLDidEndMapPfxSel]    : nil);
        self.foundCharsFunc      =      (PGXMLFoundCharsFunc_t)([d respondsToSelector:PGXMLFoundCharsSel]      ? [d methodForSelector:PGXMLFoundCharsSel]      : nil);
        self.foundIgnWhitespFunc =  (PGXMLFoundIgWhitespFunc_t)([d respondsToSelector:PGXMLFoundIgWhitespSel]  ? [d methodForSelector:PGXMLFoundIgWhitespSel]  : nil);
        self.foundProcInstFunc   =   (PGXMLFoundProcInstFunc_t)([d respondsToSelector:PGXMLFoundProcInstSel]   ? [d methodForSelector:PGXMLFoundProcInstSel]   : nil);
        self.foundCommentFunc    =    (PGXMLFoundCommentFunc_t)([d respondsToSelector:PGXMLFoundCommentSel]    ? [d methodForSelector:PGXMLFoundCommentSel]    : nil);
        self.foundCDATAFunc      =      (PGXMLFoundCDATAFunc_t)([d respondsToSelector:PGXMLFoundCDATASel]      ? [d methodForSelector:PGXMLFoundCDATASel]      : nil);
        self.parseErrFunc        =        (PGXMLParseErrFunc_t)([d respondsToSelector:PGXMLParseErrSel]        ? [d methodForSelector:PGXMLParseErrSel]        : nil);
        self.validationErrFunc   =   (PGXMLValidationErrFunc_t)([d respondsToSelector:PGXMLValidationErrSel]   ? [d methodForSelector:PGXMLValidationErrSel]   : nil);
        self.reslvExtEntFunc     =   (PGXMLResolveExtEntFunc_t)([d respondsToSelector:PGXMLReslvExtEntSel]     ? [d methodForSelector:PGXMLReslvExtEntSel]     : nil);
        self.reslvIntEntFunc     =     (PGXMLReslvIntEntFunc_t)([d respondsToSelector:PGXMLReslvIntEntSel]     ? [d methodForSelector:PGXMLReslvIntEntSel]     : nil);
        self.reslvIntPEntFunc    =     (PGXMLReslvIntEntFunc_t)([d respondsToSelector:PGXMLReslvIntPEntSel]    ? [d methodForSelector:PGXMLReslvIntPEntSel]    : nil);
        // @f:1
    }

    -(void)_foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>  d = self.delegate;
        PGXMLFoundNoteDeclFunc_t f = self.foundNoteDeclFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundNoteDeclSel, self, name, publicID, systemID);
    }

    -(void)_foundUnparsedEntityDeclarationWithName:(NSString *)name
                                          publicID:(NSString *)publicID
                                          systemID:(NSString *)systemID
                                      notationName:(NSString *)notationName
                                           hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>    d = self.delegate;
        PGXMLFoundUnpEntDeclFunc_t f = self.foundUnpEntDeclFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundUnpEntDeclSel, self, name, publicID, systemID, notationName);
    }

    -(void)_foundAttributeDeclarationWithName:(NSString *)attributeName
                                   forElement:(NSString *)elementName
                                         type:(NSString *)type
                                 defaultValue:(NSString *)defaultValue
                                      hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>  d = self.delegate;
        PGXMLFoundAttrDeclFunc_t f = self.foundAttrDeclFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundAttrDeclSel, self, attributeName, elementName, type, defaultValue);
    }

    -(void)_foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>  d = self.delegate;
        PGXMLFoundElemDeclFunc_t f = self.foundElemDeclFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundElemDeclSel, self, elementName, model);
    }

    -(void)_foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>    d = self.delegate;
        PGXMLFoundIntEntDeclFunc_t f = self.foundIntEntDeclFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundIntEntDeclSel, self, name, value);
    }

    -(void)_foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>    d = self.delegate;
        PGXMLFoundExtEntDeclFunc_t f = self.foundExtEntDeclFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundExtEntDeclSel, self, name, publicID, systemID);
    }

    -(void)_didStartDocument:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLDidStartDocFunc_t  f = self.didStartDocFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLDidStartDocSel, self);
    }

    -(void)_didEndDocument:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLDidEndDocFunc_t    f = self.didEndDocFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLDidEndDocSel, self);
    }

    -(void)_didStartElement:(NSString *)elementName
               namespaceURI:(NSString *)namespaceURI
              qualifiedName:(NSString *)qName attributes:(NSArray<PGXMLParserAttribute *> *)attributeDict
                    hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLDidStartElemFunc_t f = self.didStartElemFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLDidStartElemSel, self, elementName, namespaceURI, qName, attributeDict);
    }

    -(void)_didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLDidEndElemFunc_t   f = self.didEndElemFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLDidEndElemSel, self, elementName, namespaceURI, qName);
    }

    -(void)_didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>   d = self.delegate;
        PGXMLDidStartMapPfxFunc_t f = self.didStartMapPfxFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLDidStartMapPfxSel, self, prefix, namespaceURI);
    }

    -(void)_didEndMappingPrefix:(NSString *)prefix hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLDidEndMapPfxFunc_t f = self.didEndMapPfxFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLDidEndMapPfxSel, self, prefix);
    }

    -(void)_foundCharacters:(NSString *)string hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLFoundCharsFunc_t   f = self.foundCharsFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundCharsSel, self, string);
    }

    -(void)_foundIgnorableWhitespace:(NSString *)whitespaceString hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>   d = self.delegate;
        PGXMLFoundIgWhitespFunc_t f = self.foundIgnWhitespFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundIgWhitespSel, self, whitespaceString);
    }

    -(void)_foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>  d = self.delegate;
        PGXMLFoundProcInstFunc_t f = self.foundProcInstFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundProcInstSel, self, target, data);
    }

    -(void)_foundComment:(NSString *)comment hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLFoundCommentFunc_t f = self.foundCommentFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundCommentSel, self, comment);
    }

    -(void)_foundCDATA:(NSData *)CDATABlock hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLFoundCDATAFunc_t   f = self.foundCDATAFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLFoundCDATASel, self, CDATABlock);
    }

    -(void)_parseErrorOccurred:(NSError *)parseError hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLParseErrFunc_t     f = self.parseErrFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLParseErrSel, self, parseError);
    }

    -(void)_validationErrorOccurred:(NSError *)validationError hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>  d = self.delegate;
        PGXMLValidationErrFunc_t f = self.validationErrFunc;

        if(setImplFlag(hasImpl, (d && f))) (*f)(d, PGXMLValidationErrSel, self, validationError);
    }

    -(NSData *)_resolveExternalEntityForName:(NSString *)name systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate>  d = self.delegate;
        PGXMLResolveExtEntFunc_t f = self.reslvExtEntFunc;

        return (setImplFlag(hasImpl, (d && f)) ? (*f)(d, PGXMLReslvExtEntSel, self, name, systemID) : nil);
    }

    -(NSString *)_resolveInternalEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLReslvIntEntFunc_t  f = self.reslvIntEntFunc;

        return (setImplFlag(hasImpl, (d && f)) ? (*f)(d, PGXMLReslvIntEntSel, self, name) : nil);
    }

    -(NSString *)_resolveInternalParameterEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl {
        id<PGXMLParserDelegate> d = self.delegate;
        PGXMLReslvIntEntFunc_t  f = self.reslvIntPEntFunc;

        return (setImplFlag(hasImpl, (d && f)) ? (*f)(d, PGXMLReslvIntPEntSel, self, name) : nil);
    }

@end
