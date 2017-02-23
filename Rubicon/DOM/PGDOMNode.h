/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNode.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 2/15/17 7:01 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017  Project Galen. All rights reserved.
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
 *******************************************************************************/

#ifndef __Rubicon_PGDOMNode_H_
#define __Rubicon_PGDOMNode_H_

#import <Cocoa/Cocoa.h>
#import <Rubicon/PGDOM.h>

@class PGDOMDocument;
@class PGDOMNamedNodeMap;
@class PGDOMNodeList;

@interface PGDOMNode : NSObject<NSCopying>

	@property(readonly) PGDOMNodeTypes    nodeType;
	@property(readonly) NSString          *nodeName;
	@property(copy) NSString              *nodeValue;
	@property(copy) NSString              *prefix;
	@property(copy) NSString              *textContent;
	@property(readonly) NSString          *baseURI;
	@property(readonly) NSString          *namespaceURI;
	@property(readonly) NSString          *localName;
	@property(readonly) PGDOMNode         *parentNode;
	@property(readonly) PGDOMDocument     *ownerDocument;
	@property(readonly) PGDOMNode         *firstChild;
	@property(readonly) PGDOMNode         *lastChild;
	@property(readonly) PGDOMNamedNodeMap *attributes;
	@property(readonly) PGDOMNodeList     *childNodes;
	@property(readonly) PGDOMNode         *nextSibling;
	@property(readonly) PGDOMNode         *previousSibling;
	@property(readonly) BOOL              hasChildNodes;
	@property(readonly) BOOL              hasAttributes;

	-(instancetype)init;

	-(PGDOMNode *)appendChild:(PGDOMNode *)newChild;

	-(PGDOMNode *)insertChild:(PGDOMNode *)newChild before:(PGDOMNode *)referenceChild;

	-(PGDOMNode *)removeChild:(PGDOMNode *)oldChild;

	-(PGDOMNode *)replaceChild:(PGDOMNode *)oldChild withNode:(PGDOMNode *)newChild;

	-(BOOL)isSameNode:(PGDOMNode *)other;

	-(BOOL)isEqualToNode:(PGDOMNode *)other;

	-(BOOL)isDefaultNamespace:(NSString *)namespaceURI;

	-(NSString *)lookupNamespaceURI:(NSString *)prefix;

	-(NSString *)lookupPrefix:(NSString *)namespaceURI;

	-(id)userDataForKey:(NSString *)key;

	-(id)setUserData:(id)object forKey:(NSString *)key;

	-(void)normalize;

	-(id)copyWithZone:(NSZone *)zone;

	-(id)copy;

	-(id)copy:(BOOL)deep;

@end

#endif //__Rubicon_PGDOMNode_H_
