/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMElement.m
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

#import "PGDOMElement.h"
#import "PGDOMPrivate.h"

@implementation PGDOMElement {
    }

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithNodeType:PGDOMNodeTypeElement ownerDocument:ownerDocument qualifiedName:qualifiedName namespaceURI:namespaceURI];

        if(self) {
        }

        return self;
    }

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument localName:(NSString *)localName prefix:(NSString *)prefix namespaceURI:(NSString *)namespaceURI {
        self = [super initWithNodeType:PGDOMNodeTypeElement ownerDocument:ownerDocument localName:localName prefix:prefix namespaceURI:namespaceURI];

        if(self) {
        }

        return self;
    }

    -(NSString *)tagName {
        return super.nodeName;
    }

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap {
        return [[PGDOMAttributeMap alloc] initWithOwnerNode:self];
    }

    -(nullable NSString *)attributeWithName:(NSString *)name {
        return [self.attributes itemWithName:name].value;
    }

    -(nullable NSString *)attributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return [self.attributes itemWithLocalName:localName namespaceURI:namespaceURI].value;
    }

    -(nullable PGDOMAttr *)attributeNodeWithName:(NSString *)name {
        return [self.attributes itemWithName:name];
    }

    -(nullable PGDOMAttr *)attributeNodeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return [self.attributes itemWithLocalName:localName namespaceURI:namespaceURI];
    }

    -(BOOL)hasAttributeWithName:(NSString *)name {
        return ([self.attributes itemWithName:name] != nil);
    }

    -(BOOL)hasAttributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return ([self.attributes itemWithLocalName:localName namespaceURI:namespaceURI] != nil);
    }

    -(void)setAttributeValue:(NSString *)value name:(NSString *)name {
        PGDOMAttr *attr = [self.attributes itemWithName:name];

        if(attr) {
            attr.value = value;
            [self.ownerDocument.notificationCenter postNotificationName:PGDOMNodeListChangedNotification object:self];
        }
        else {
            [self _setAttribute:[[PGDOMAttr alloc] initWithOwnerDocument:self.ownerDocument ownerElement:self name:name value:value isSpecified:NO isID:NO]];
        }
    }

    -(void)setAttributeValue:(NSString *)value qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        PGDOMAttr *attr = [self.attributes itemWithLocalName:qualifiedName.namespaceLocalName namespaceURI:namespaceURI];

        if(attr) {
            attr.value = value;
            [self.ownerDocument.notificationCenter postNotificationName:PGDOMNodeListChangedNotification object:self];
        }
        else {
            [self _setAttributeNS:[[PGDOMAttr alloc]
                                              initWithOwnerDocument:self.ownerDocument
                                                       ownerElement:self
                                                      qualifiedName:qualifiedName
                                                       namespaceURI:namespaceURI
                                                              value:value
                                                        isSpecified:NO
                                                               isID:NO]];
        }
    }

    -(PGDOMAttr *)_setAttribute:(PGDOMAttr *)attr {
        PGDOMAttr *oattr = [self.attributes addItem:attr];
        oattr.ownerElement = nil;
        [self.ownerDocument.notificationCenter postNotificationName:PGDOMNodeListChangedNotification object:self];
        return oattr;
    }

    -(PGDOMAttr *)_setAttributeNS:(PGDOMAttr *)attr {
        PGDOMAttr *oattr = [self.attributes addItemNS:attr];
        oattr.ownerElement = nil;
        [self.ownerDocument.notificationCenter postNotificationName:PGDOMNodeListChangedNotification object:self];
        return oattr;
    }

    -(nullable PGDOMAttr *)setAttribute:(PGDOMAttr *)attr {
        if(self.ownerDocument == attr.ownerDocument) attr.ownerElement = self;
        return [self _setAttribute:attr];
    }

    -(nullable PGDOMAttr *)setAttributeNS:(PGDOMAttr *)attr {
        if(self.ownerDocument == attr.ownerDocument) attr.ownerElement = self;
        return [self _setAttributeNS:attr];
    }

    -(void)removeAttributeWithName:(NSString *)name {
        PGDOMAttr *attr = [self.attributes removeItemWithName:name];
        attr.ownerElement = nil;
    }

    -(void)removeAttributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        PGDOMAttr *attr = [self.attributes removeItemWithLocalName:localName namespaceURI:namespaceURI];
        attr.ownerElement = nil;
    }

    -(nullable PGDOMAttr *)removeAttribute:(PGDOMAttr *)attr {
        PGDOMAttr *tattr = (attr.ownerElement == self) ? [self.attributes removeItemWithName:attr.name] : nil;
        tattr.ownerElement = nil;
        return tattr;
    }

    -(nullable PGDOMAttr *)removeAttributeNS:(PGDOMAttr *)attr {
        PGDOMAttr *tattr = (attr.ownerElement == self) ? [self.attributes removeItemWithLocalName:attr.localName namespaceURI:attr.namespaceURI] : nil;
        tattr.ownerElement = nil;
        return tattr;
    }

    -(void)setID:(BOOL)isID attributeWithName:(NSString *)name {
        PGDOMAttr *attr = [self.attributes itemWithName:name];
        attr.isID = isID;
    }

    -(void)setID:(BOOL)isID attributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        PGDOMAttr *attr = [self.attributes itemWithLocalName:localName namespaceURI:namespaceURI];
        attr.isID = isID;
    }

    -(void)setID:(BOOL)isID attribute:(PGDOMAttr *)attr {
        if(attr.ownerElement == self) attr.isID = isID;
    }

    -(PGDOMNodeList<PGDOMElement *> *)getElementsByTagName:(NSString *)tagName {
        return [[PGDOMElementNodeList alloc] initWithOwnerNode:self tagName:tagName];
    }

    -(PGDOMNodeList<PGDOMElement *> *)getElementsByLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return [[PGDOMElementNodeList alloc] initWithOwnerNode:self localName:localName namespaceURI:namespaceURI];
    }

@end
