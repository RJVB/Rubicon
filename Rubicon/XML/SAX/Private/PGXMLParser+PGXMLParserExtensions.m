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

NS_INLINE PGMethodImpl *_getMethod(PGXMLParser *parser, NSString *name, SEL sel, id object) {
    return ((parser && sel && object) ? (parser.methods[name] = [PGMethodImpl methodWithSelector:sel forObject:object]) : nil);
}

#define FOO(t, m) (*((t)((m).f)))

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

        if(name && object) {
            [self.lck lock];
            @try {
                if((method = self.methods[name])) {
                    if(method.obj != object) {
                        [self.methods removeObjectForKey:name];
                        method = _getMethod(self, name, method.sel, object);
                    }
                }
                else {
                    method = _getMethod(self, name, [self selectorForMethodName:nameEnum], object);
                }
            }
            @finally { [self.lck unlock]; }
        }

        return method;
    }

    -(nullable SEL)selectorForMethodName:(PGXMLMethodNames)nameEnum {
        switch(nameEnum) { // @f:0
            case PGXMLFoundNoteDeclMethod:   return @selector(parser:foundNotationDeclarationWithName:publicID:systemID:);
            case PGXMLFoundUnpEntDeclMethod: return @selector(parser:foundUnparsedEntityDeclarationWithName:publicID:systemID:notationName:);
            case PGXMLFoundAttrDeclMethod:   return @selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:);
            case PGXMLFoundElemDeclMethod:   return @selector(parser:foundElementDeclarationWithName:model:);
            case PGXMLFoundIntEntDeclMethod: return @selector(parser:foundInternalEntityDeclarationWithName:value:);
            case PGXMLFoundExtEntDeclMethod: return @selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:);
            case PGXMLDidStartDocMethod:     return @selector(parserDidStartDocument:);
            case PGXMLDidEndDocMethod:       return @selector(parserDidEndDocument:);
            case PGXMLDidStartElemMethod:    return @selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:);
            case PGXMLDidEndElemMethod:      return @selector(parser:didEndElement:namespaceURI:qualifiedName:);
            case PGXMLDidStartMapPfxMethod:  return @selector(parser:didStartMappingPrefix:toURI:);
            case PGXMLDidEndMapPfxMethod:    return @selector(parser:didEndMappingPrefix:);
            case PGXMLFoundCharsMethod:      return @selector(parser:foundCharacters:);
            case PGXMLFoundIgnWhitespMethod: return @selector(parser:foundIgnorableWhitespace:);
            case PGXMLFoundProcInstMethod:   return @selector(parser:foundProcessingInstructionWithTarget:data:);
            case PGXMLFoundCommentMethod:    return @selector(parser:foundComment:);
            case PGXMLFoundCDATAMethod:      return @selector(parser:foundCDATA:);
            case PGXMLParseErrMethod:        return @selector(parser:parseErrorOccurred:);
            case PGXMLValidationErrMethod:   return @selector(parser:validationErrorOccurred:);
            case PGXMLReslvExtEntMethod:     return @selector(parser:resolveExternalEntityName:systemID:);
            case PGXMLReslvIntEntMethod:     return @selector(parser:resolveInternalEntityForName:);
            case PGXMLReslvIntPEntMethod:    return @selector(parser:resolveInternalParameterEntityForName:);
            default: return nil; // @f:1
        }
    }

    -(void)_foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundNoteDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundNoteDeclFunc_t, m)(m.obj, m.sel, self, name, publicID, systemID);
    }

    -(void)_foundUnparsedEntityDeclarationWithName:(NSString *)name
                                          publicID:(NSString *)publicID
                                          systemID:(NSString *)systemID
                                      notationName:(NSString *)notationName
                                           hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundUnpEntDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundUnpEntDeclFunc_t, m)(m.obj, m.sel, self, name, publicID, systemID, notationName);
    }

    -(void)_foundAttributeDeclarationWithName:(NSString *)attributeName
                                   forElement:(NSString *)elementName
                                         type:(NSString *)type
                                 defaultValue:(NSString *)defaultValue
                                      hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundAttrDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundAttrDeclFunc_t, m)(m.obj, m.sel, self, attributeName, elementName, type, defaultValue);
    }

    -(void)_foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundElemDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundElemDeclFunc_t, m)(m.obj, m.sel, self, elementName, model);
    }

    -(void)_foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundIntEntDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundIntEntDeclFunc_t, m)(m.obj, m.sel, self, name, value);
    }

    -(void)_foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundExtEntDeclMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundExtEntDeclFunc_t, m)(m.obj, m.sel, self, name, publicID, systemID);
    }

    -(void)_didStartDocument:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLDidStartDocMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLDidStartDocFunc_t, m)(m.obj, m.sel, self);
    }

    -(void)_didEndDocument:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLDidEndDocMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLDidEndDocFunc_t, m)(m.obj, m.sel, self);
    }

    -(void)_didStartElement:(NSString *)elementName
               namespaceURI:(NSString *)namespaceURI
              qualifiedName:(NSString *)qName
                 attributes:(NSArray<PGXMLParserAttribute *> *)attributeDict
                    hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLDidStartElemMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLDidStartElemFunc_t, m)(m.obj, m.sel, self, elementName, namespaceURI, qName, attributeDict);
    }

    -(void)_didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLDidEndElemMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLDidEndElemFunc_t, m)(m.obj, m.sel, self, elementName, namespaceURI, qName);
    }

    -(void)_didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLDidStartMapPfxMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLDidStartMapPfxFunc_t, m)(m.obj, m.sel, self, prefix, namespaceURI);
    }

    -(void)_didEndMappingPrefix:(NSString *)prefix hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLDidEndMapPfxMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLDidEndMapPfxFunc_t, m)(m.obj, m.sel, self, prefix);
    }

    -(void)_foundCharacters:(NSString *)string hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundCharsMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundCharsFunc_t, m)(m.obj, m.sel, self, string);
    }

    -(void)_foundIgnorableWhitespace:(NSString *)whitespaceString hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundIgnWhitespMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundIgWhitespFunc_t, m)(m.obj, m.sel, self, whitespaceString);
    }

    -(void)_foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundProcInstMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundProcInstFunc_t, m)(m.obj, m.sel, self, target, data);
    }

    -(void)_foundComment:(NSString *)comment hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundCommentMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundCommentFunc_t, m)(m.obj, m.sel, self, comment);
    }

    -(void)_foundCDATA:(NSData *)CDATABlock hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLFoundCDATAMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLFoundCDATAFunc_t, m)(m.obj, m.sel, self, CDATABlock);
    }

    -(void)_parseErrorOccurred:(NSError *)parseError hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLParseErrMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLParseErrFunc_t, m)(m.obj, m.sel, self, parseError);
    }

    -(void)_validationErrorOccurred:(NSError *)validationError hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLValidationErrMethod];
        if(setImplFlag(hasImpl, (m != nil))) FOO(PGXMLValidationErrFunc_t, m)(m.obj, m.sel, self, validationError);
    }

    -(NSData *)_resolveExternalEntityForName:(NSString *)name systemID:(NSString *)systemID hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLReslvExtEntMethod];
        return (setImplFlag(hasImpl, (m != nil)) ? FOO(PGXMLResolveExtEntFunc_t, m)(m.obj, m.sel, self, name, systemID) : nil);
    }

    -(NSString *)_resolveInternalEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLReslvIntEntMethod];
        return (setImplFlag(hasImpl, (m != nil)) ? FOO(PGXMLReslvIntEntFunc_t, m)(m.obj, m.sel, self, name) : nil);
    }

    -(NSString *)_resolveInternalParameterEntityForName:(NSString *)name hasImpl:(BOOL *)hasImpl {
        PGMethodImpl *m = [self methodForName:PGXMLReslvIntPEntMethod];
        return (setImplFlag(hasImpl, (m != nil)) ? FOO(PGXMLReslvIntEntFunc_t, m)(m.obj, m.sel, self, name) : nil);
    }

@end
