/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMElement.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/29/18
 *  VISIBILITY: Private
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

#ifndef RUBICON_PGDOMELEMENT_H
#define RUBICON_PGDOMELEMENT_H

#import <Rubicon/PGDOMNamespaceAware.h>
#import <Rubicon/PGDOMAttr.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGDOMElement : PGDOMNamespaceAware

    @property(nonatomic, readonly, copy) NSString *tagName;

    -(nullable NSString *)attributeWithName:(NSString *)name;

    -(nullable NSString *)attributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

    -(nullable PGDOMAttr *)attributeNodeWithName:(NSString *)name;

    -(nullable PGDOMAttr *)attributeNodeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

    -(BOOL)hasAttributeWithName:(NSString *)name;

    -(BOOL)hasAttributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

    -(void)setAttributeValue:(NSString *)value name:(NSString *)name;

    -(void)setAttributeValue:(NSString *)value qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI;

    -(nullable PGDOMAttr *)setAttribute:(PGDOMAttr *)attr;

    -(nullable PGDOMAttr *)setAttributeNS:(PGDOMAttr *)attr;

    -(void)removeAttributeWithName:(NSString *)name;

    -(void)removeAttributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

    -(nullable PGDOMAttr *)removeAttribute:(PGDOMAttr *)attr;

    -(nullable PGDOMAttr *)removeAttributeNS:(PGDOMAttr *)attr;

    -(void)setID:(BOOL)isID attributeWithName:(NSString *)name;

    -(void)setID:(BOOL)isID attributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

    -(void)setID:(BOOL)isID attribute:(PGDOMAttr *)attr;

    -(PGDOMNodeList<PGDOMElement *> *)getElementsByTagName:(NSString *)tagName;

    -(PGDOMNodeList<PGDOMElement *> *)getElementsByLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMELEMENT_H
