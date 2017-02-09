/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/31/17 7:49 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
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

#import "PGDOMPrivate.h"
#import "PGDOMNamedNodeMap.h"
#import "PGDOMNodeList.h"

@interface PGDOMNamedNodeMap()

	+(PGDOMNamedNodeMap *)instance;

@end

@interface PGDOMNodeList()

	+(PGDOMNodeList *)instance;

@end

@implementation PGDOMNode {
		NSMutableDictionary *_userData;
	}

	@synthesize ownerDocument = _ownerDocument;

	-(instancetype)init {
		self = [super init];

		if(self) {
			_userData = [NSMutableDictionary dictionary];
		}

		return self;
	}

	-(void)setOwnerDocument:(PGDOMDocument *)ownerDocument {
		_ownerDocument = ownerDocument;
	}

	-(NSString *)nodeName {
		return nil;
	}

	-(PGDOMNodeTypes)nodeType {
		return PGDOMUnknownNode;
	}

	-(NSString *)nodeValue {
		return nil;
	}

	-(void)setNodeValue:(NSString *)nodeValue {
	}

	-(NSString *)textContent {
		return nil;
	}

	-(void)setTextContent:(NSString *)textContent {
	}

	-(NSString *)prefix {
		return nil;
	}

	-(void)setPrefix:(NSString *)prefix {
	}

	-(NSString *)localName {
		return nil;
	}

	-(NSString *)baseURI {
		return nil;
	}

	-(NSString *)namespaceURI {
		return nil;
	}

	-(BOOL)isDefaultNamespace:(NSString *)namespaceURI {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(NSString *)lookupNamespaceURI:(NSString *)prefix {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(NSString *)lookupPrefix:(NSString *)namespaceURI {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	+(NSString *)nodeTypeName:(PGDOMNodeTypes)nodeType {
		switch(nodeType) {
			case PGDOMAttributeNode:
				return @"PGDOMAttributeNode";
			case PGDOMCDataSectionNode:
				return @"PGDOMCDataSectionNode";
			case PGDOMCommentNode:
				return @"PGDOMCommentNode";
			case PGDOMDocumentFragmentNode:
				return @"PGDOMDocumentFragmentNode";
			case PGDOMDocumentNode:
				return @"PGDOMDocumentNode";
			case PGDOMDocumentTypeNode:
				return @"PGDOMDocumentTypeNode";
			case PGDOMElementNode:
				return @"PGDOMElementNode";
			case PGDOMEntityNode:
				return @"PGDOMEntityNode";
			case PGDOMEntityReferenceNode:
				return @"PGDOMEntityReferenceNode";
			case PGDOMNotationNode:
				return @"PGDOMNotationNode";
			case PGDOMProcessingInstructionNode:
				return @"PGDOMProcessingInstructionNode";
			case PGDOMTextNode:
				return @"PGDOMTextNode";
			default:
				return @"PGDOMUnknownNode";
		}
	}

	-(NSString *)nodeTypeName {
		return [[self class] nodeTypeName:self.nodeType];
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGDOMNode *copy = ((PGDOMNode *)[[[self class] allocWithZone:zone] init]);

		if(copy != nil) {
			copy->_ownerDocument = _ownerDocument;
		}

		return copy;
	}

	-(id)copy:(BOOL)deep {
		return [self copy];
	}

	-(NSInteger)compareDocumentPosition:(PGDOMNode *)node {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(NSString *)feature:(NSString *)feature version:(NSString *)version {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(id)userData:(NSString *)name {
		return _userData[name];
	}

	-(void)setUserData:(id)obj forName:(NSString *)name {
		_userData[name] = obj;
	}

	-(BOOL)isSupported:(NSString *)feature version:(NSString *)version {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(void)normalize {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGDOMNode *)parentNode {
		return nil;
	}

	-(PGDOMNode *)nextSibling {
		return nil;
	}

	-(PGDOMNode *)previousSibling {
		return nil;
	}

	-(PGDOMNode *)childAfter:(PGDOMNode *)child {
		return nil;
	}

	-(PGDOMNode *)childBefore:(PGDOMNode *)child {
		return nil;
	}

	-(PGDOMNamedNodeMap *)attributes {
		return [PGDOMNamedNodeMap instance];
	}

	-(PGDOMNodeList *)childNodes {
		return [PGDOMNodeList instance];
	}

	-(BOOL)hasChildNodes {
		return NO;
	}

	-(BOOL)hasAttributes {
		return NO;
	}

	-(PGDOMNode *)firstChild {
		return nil;
	}

	-(PGDOMNode *)lastChild {
		return nil;
	}

	-(PGDOMNode *)appendNode:(PGDOMNode *)newNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGDOMNode *)insertNode:(PGDOMNode *)newNode before:(PGDOMNode *)referenceNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGDOMNode *)removeChild:(PGDOMNode *)oldNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGDOMNode *)replaceChild:(PGDOMNode *)oldNode newNode:(PGDOMNode *)newNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(BOOL)isEqualNode:(PGDOMNode *)other {
		return (other &&
				([self isSameNode:other] ||
				 ((self.nodeType == other.nodeType) &&
				  PGObjectsEqual(self.nodeName, other.nodeName) &&
				  PGObjectsEqual(self.localName, other.localName) &&
				  PGObjectsEqual(self.namespaceURI, other.namespaceURI) &&
				  PGObjectsEqual(self.prefix, other.prefix) &&
				  PGObjectsEqual(self.nodeValue, other.nodeValue) &&
				  PGObjectsEqual(self.attributes, other.attributes) &&
				  PGObjectsEqual(self.childNodes, other.childNodes))));
	}

	-(BOOL)isSameNode:(PGDOMNode *)node {
		return (self == node);
	}

	-(BOOL)isEqual:(id)other {
		return [self isSameNode:other];
	}

@end

@implementation PGDOMChildNode {
		PGDOMNode *_parentNode;
	}

	-(PGDOMNode *)parentNode {
		return _parentNode;
	}

	-(void)setParentNode:(PGDOMNode *)node {
		_parentNode = node;
	}

	-(PGDOMNode *)nextSibling {
		return [self.parentNode childAfter:self];
	}

	-(PGDOMNode *)previousSibling {
		return [self.parentNode childBefore:self];
	}

@end

