/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMAttr.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/29/18
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

#import "PGDOMPrivate.h"

@implementation PGDOMAttr {
    }

    @synthesize isSpecified = _isSpecified;
    @synthesize isID = _isID;
    @synthesize ownerElement = _ownerElement;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                                    name:(NSString *)name
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID {
        self = [super initWithNodeType:PGDOMNodeTypeAttribute ownerDocument:ownerDocument nodeName:name];

        if(self) {
            _ownerElement = ownerElement;
            _isSpecified  = isSpecified;
            _isID         = isID;
            self.isReadOnly      = NO;
            if(value) self.value = value;
        }

        return self;
    }

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                           qualifiedName:(NSString *)qualifiedName
                            namespaceURI:(NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID {
        self = [super initWithNodeType:PGDOMNodeTypeAttribute ownerDocument:ownerDocument qualifiedName:qualifiedName namespaceURI:namespaceURI];

        if(self) {
            _ownerElement = ownerElement;
            _isSpecified  = isSpecified;
            _isID         = isID;
            self.isReadOnly      = NO;
            if(value) self.value = value;
        }

        return self;
    }

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                               localName:(NSString *)localName
                                  prefix:(NSString *)prefix
                            namespaceURI:(NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID {
        self = [super initWithNodeType:PGDOMNodeTypeAttribute ownerDocument:ownerDocument localName:localName prefix:prefix namespaceURI:namespaceURI];

        if(self) {
            _ownerElement = ownerElement;
            _isSpecified  = isSpecified;
            _isID         = isID;
            self.isReadOnly      = NO;
            if(value) self.value = value;
        }

        return self;
    }

    -(BOOL)canAcceptNode:(PGDOMNode *)node {
        PGDOMNodeTypes t = node.nodeType;
        return ((t == PGDOMNodeTypeText) || (t == PGDOMNodeTypeEntityReference));
    }

    -(NSString *)name {
        return super.nodeName;
    }

    -(NSString *)value {
        return super.textContent;
    }

    -(void)setValue:(NSString *)value {
        super.textContent = value;
    }

    -(void)setOwnerElement:(PGDOMElement *)ownerElement {
        if(_ownerElement != ownerElement) {
            if(_ownerElement) [_ownerElement removeAttributeNS:self];
            _ownerElement = ownerElement;
        }
    }

@end
