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

@implementation PGXMLParser(PGXMLParserExtensions)

#pragma mark Delegate method handling

    -(NSArray<NSString *> *)methodNames {
        static NSArray<NSString *> *_methodNames = nil;

        PGSETIFNIL([PGXMLParser class], _methodNames, (@[
                /* DO NOT CHANGE THE ORDER OF THESE!!!!! */
                @"PGXMLFoundNoteDeclMethod", @"PGXMLFoundUnpEntDeclMethod", @"PGXMLFoundAttrDeclMethod", @"PGXMLFoundElemDeclMethod", @"PGXMLFoundIntEntDeclMethod",
                @"PGXMLFoundExtEntDeclMethod", @"PGXMLDidStartDocMethod", @"PGXMLDidEndDocMethod", @"PGXMLDidStartElemMethod", @"PGXMLDidEndElemMethod",
                @"PGXMLDidStartMapPfxMethod", @"PGXMLDidEndMapPfxMethod", @"PGXMLFoundCharsMethod", @"PGXMLFoundIgnWhitespMethod", @"PGXMLFoundProcInstMethod",
                @"PGXMLFoundCommentMethod", @"PGXMLFoundCDATAMethod", @"PGXMLParseErrMethod", @"PGXMLValidationErrMethod", @"PGXMLReslvExtEntMethod", @"PGXMLReslvIntEntMethod",
                @"PGXMLReslvIntPEntMethod"
        ]));

        return _methodNames;
    }

    -(nullable PGMethodImpl *)methodForName:(PGXMLMethodNames)nameEnum {
        return [self methodForName:nameEnum object:self.delegate];
    }

    -(PGMethodImpl *)methodForName:(PGXMLMethodNames)nameEnum object:(id)object {
        NSString     *name   = self.methodNames[nameEnum];
        PGMethodImpl *method = nil;

        if(name) {
            if((method = self.methods[name]) == nil) {
                @synchronized(self.methods) {
                    if((method = self.methods[name]) == nil) {
                        SEL sel = [self selectorForMethodName:nameEnum];
                        if(sel) self.methods[name] = method = [PGMethodImpl methodWithSelector:sel forObject:object];
                    }
                }
            }
        }

        return method;
    }

    -(nullable SEL)selectorForMethodName:(PGXMLMethodNames)nameEnum {
        switch(nameEnum) { // @f:0
            case PGXMLfoundNoteDeclMethod:   return @selector(parser:foundNotationDeclarationWithName:publicID:systemID:);
            case PGXMLfoundUnpEntDeclMethod: return @selector(parser:foundUnparsedEntityDeclarationWithName:publicID:systemID:notationName:);
            case PGXMLfoundAttrDeclMethod:   return @selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:);
            case PGXMLfoundElemDeclMethod:   return @selector(parser:foundElementDeclarationWithName:model:);
            case PGXMLfoundIntEntDeclMethod: return @selector(parser:foundInternalEntityDeclarationWithName:value:);
            case PGXMLfoundExtEntDeclMethod: return @selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:);
            case PGXMLdidStartDocMethod:     return @selector(parserDidStartDocument:);
            case PGXMLdidEndDocMethod:       return @selector(parserDidEndDocument:);
            case PGXMLdidStartElemMethod:    return @selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:);
            case PGXMLdidEndElemMethod:      return @selector(parser:didEndElement:namespaceURI:qualifiedName:);
            case PGXMLdidStartMapPfxMethod:  return @selector(parser:didStartMappingPrefix:toURI:);
            case PGXMLdidEndMapPfxMethod:    return @selector(parser:didEndMappingPrefix:);
            case PGXMLfoundCharsMethod:      return @selector(parser:foundCharacters:);
            case PGXMLfoundIgnWhitespMethod: return @selector(parser:foundIgnorableWhitespace:);
            case PGXMLfoundProcInstMethod:   return @selector(parser:foundProcessingInstructionWithTarget:data:);
            case PGXMLfoundCommentMethod:    return @selector(parser:foundComment:);
            case PGXMLfoundCDATAMethod:      return @selector(parser:foundCDATA:);
            case PGXMLparseErrMethod:        return @selector(parser:parseErrorOccurred:);
            case PGXMLvalidationErrMethod:   return @selector(parser:validationErrorOccurred:);
            case PGXMLreslvExtEntMethod:     return @selector(parser:resolveExternalEntityName:systemID:);
            case PGXMLreslvIntEntMethod:     return @selector(parser:resolveInternalEntityForName:);
            case PGXMLreslvIntPEntMethod:    return @selector(parser:resolveInternalParameterEntityForName:);
            default: return nil; // @f:1
        }
    }

    -(void)_foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundNoteDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundNoteDeclFunc_t)m.f))(m.obj, m.sel, self, name, publicID, systemID);
    }

    -(void)_foundUnparsedEntityDeclarationWithName:(NSString *)name
                                          publicID:(NSString *)publicID
                                          systemID:(NSString *)systemID
                                      notationName:(NSString *)notationName
                                           hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundUnpEntDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundUnpEntDeclFunc_t)m.f))(m.obj, m.sel, self, name, publicID, systemID, notationName);
    }

    -(void)_foundAttributeDeclarationWithName:(NSString *)attributeName
                                   forElement:(NSString *)elementName
                                         type:(NSString *)type
                                 defaultValue:(NSString *)defaultValue
                                      hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundAttrDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundAttrDeclFunc_t)m.f))(m.obj, m.sel, self, attributeName, elementName, type, defaultValue);
    }

    -(void)_foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundElemDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundElemDeclFunc_t)m.f))(m.obj, m.sel, self, elementName, model);
    }

    -(void)_foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundIntEntDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundIntEntDeclFunc_t)m.f))(m.obj, m.sel, self, name, value);
    }

    -(void)_foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundExtEntDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundExtEntDeclFunc_t)m.f))(m.obj, m.sel, self, name, publicID, systemID);
    }

    -(void)_didStartDocument:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLdidStartDocMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLDidStartDocFunc_t)m.f))(m.obj, m.sel, self);
    }

    -(void)_didEndDocument:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLdidEndDocMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLDidEndDocFunc_t)m.f))(m.obj, m.sel, self);
    }

    -(void)_didStartElement:(NSString *)elementName
               namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSArray<PGXMLParserAttribute *> *)attributeDict
                    hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLdidStartElemMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLDidStartElemFunc_t)m.f))(m.obj, m.sel, self, elementName, namespaceURI, qName, attributeDict);
    }

    -(void)_didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLdidEndElemMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLDidEndElemFunc_t)m.f))(m.obj, m.sel, self, elementName, namespaceURI, qName);
    }

    -(void)_didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLdidStartMapPfxMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLDidStartMapPfxFunc_t)m.f))(m.obj, m.sel, self, prefix, namespaceURI);
    }

    -(void)_didEndMappingPrefix:(NSString *)prefix hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLdidEndMapPfxMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLDidEndMapPfxFunc_t)m.f))(m.obj, m.sel, self, prefix);
    }

    -(void)_foundCharacters:(NSString *)string hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundCharsMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundCharsFunc_t)m.f))(m.obj, m.sel, self, string);
    }

    -(void)_foundIgnorableWhitespace:(NSString *)whitespaceString hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundIgnWhitespMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundIgWhitespFunc_t)m.f))(m.obj, m.sel, self, whitespaceString);
    }

    -(void)_foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundProcInstMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundProcInstFunc_t)m.f))(m.obj, m.sel, self, target, data);
    }

    -(void)_foundComment:(NSString *)comment hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundCommentMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundCommentFunc_t)m.f))(m.obj, m.sel, self, comment);
    }

    -(void)_foundCDATA:(NSData *)CDATABlock hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLfoundCDATAMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLFoundCDATAFunc_t)m.f))(m.obj, m.sel, self, CDATABlock);
    }

    -(void)_parseErrorOccurred:(NSError *)parseError hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLparseErrMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLParseErrFunc_t)m.f))(m.obj, m.sel, self, parseError);
    }

    -(void)_validationErrorOccurred:(NSError *)validationError hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLvalidationErrMethod];
        if(setImplFlag(hasImpl, (m != nil))) (*((PGXMLValidationErrFunc_t)m.f))(m.obj, m.sel, self, validationError);
    }

    -(NSData *)_resolveExternalEntityForName:(NSString *)name systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLreslvExtEntMethod];
        return (setImplFlag(hasImpl, (m != nil)) ? (*((PGXMLResolveExtEntFunc_t)m.f))(m.obj, m.sel, self, name, systemID) : nil);
    }

    -(NSString *)_resolveInternalEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLreslvIntEntMethod];
        return (setImplFlag(hasImpl, (m != nil)) ? (*((PGXMLReslvIntEntFunc_t)m.f))(m.obj, m.sel, self, name) : nil);
    }

    -(NSString *)_resolveInternalParameterEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLreslvIntPEntMethod];
        return (setImplFlag(hasImpl, (m != nil)) ? (*((PGXMLReslvIntEntFunc_t)m.f))(m.obj, m.sel, self, name) : nil);
    }

@end
