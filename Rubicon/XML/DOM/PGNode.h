/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNode.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/31/17 7:49 PM
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

#ifndef __Rubicon_PGNode_H_
#define __Rubicon_PGNode_H_

#import <Rubicon/PGTools.h>

@class PGNamedNodeMap;
@class PGDocument;
@class PGNodeList;

typedef enum _pg_domnodetypes {
	PGDOMUnknownNode,
	PGDOMAttributeNode,
	PGDOMCDataSectionNode,
	PGDOMCommentNode,
	PGDOMDocumentFragmentNode,
	PGDOMDocumentNode,
	PGDOMDocumentTypeNode,
	PGDOMElementNode,
	PGDOMEntityNode,
	PGDOMEntityReferenceNode,
	PGDOMNotationNode,
	PGDOMProcessingInstructionNode,
	PGDOMTextNode
} PGDOMNodeTypes;

@interface PGNode : NSObject<NSCopying>

	@property(nonatomic, readonly) PGDOMNodeTypes nodeType;
	@property(nonatomic, readonly) NSString       *nodeTypeName;
	@property(nonatomic, copy) NSString           *prefix;
	@property(nonatomic, copy) NSString           *nodeValue;
	@property(nonatomic, copy) NSString           *textContent;
	@property(nonatomic, readonly) PGNamedNodeMap *attributes;
	@property(nonatomic, readonly) PGNodeList     *childNodes;
	@property(nonatomic, readonly) NSString       *baseURI;
	@property(nonatomic, readonly) NSString       *localName;
	@property(nonatomic, readonly) NSString       *namespaceURI;
	@property(nonatomic, readonly) NSString       *nodeName;
	@property(nonatomic, readonly) BOOL           hasChildNodes;
	@property(nonatomic, readonly) BOOL           hasAttributes;
	@property(nonatomic, readonly) PGNode         *firstChild;
	@property(nonatomic, readonly) PGNode         *lastChild;
	@property(nonatomic, readonly) PGNode         *nextSibling;
	@property(nonatomic, readonly) PGNode         *previousSibling;
	@property(nonatomic, readonly) PGNode         *parentNode;
	@property(nonatomic, readonly) PGDocument     *ownerDocument;

	-(instancetype)init;

	-(NSString *)nodeTypeName:(PGDOMNodeTypes)nodeType;

	-(PGNode *)appendNode:(PGNode *)newNode;

	-(id)copyWithZone:(NSZone *)zone;

	-(id)copy:(BOOL)deep;

	-(NSInteger)compareDocumentPosition:(PGNode *)node;

	-(NSString *)feature:(NSString *)feature version:(NSString *)version;

	-(id)userData:(NSString *)name;

	-(void)setUserData:(id)obj forName:(NSString *)name;

	-(PGNode *)insertNode:(PGNode *)newNode before:(PGNode *)referenceNode;

	-(BOOL)isDefaultNamespace:(NSString *)namespaceURI;

	-(BOOL)isSupported:(NSString *)feature version:(NSString *)version;

	-(NSString *)lookupNamespaceURI:(NSString *)prefix;

	-(NSString *)lookupPrefix:(NSString *)namespaceURI;

	-(void)normalize;

	-(PGNode *)removeChild:(PGNode *)oldNode;

	-(PGNode *)replaceChild:(PGNode *)oldNode newNode:(PGNode *)newNode;

	-(BOOL)isEqualNode:(PGNode *)node;

	-(BOOL)isSameNode:(PGNode *)node;

	-(BOOL)isEqual:(id)other;

@end

#endif //__Rubicon_PGNode_H_
