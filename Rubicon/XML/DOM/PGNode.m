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

#import "PGNode.h"
#import "PGNamedNodeMap.h"
#import "PGNodeList.h"

@interface PGNamedNodeMap()

	+(PGNamedNodeMap *)instance;

@end

@interface PGNodeList()

	+(PGNodeList *)instance;

@end

@implementation PGNode {
		NSMutableDictionary *_userData;
	}

	@synthesize parentNode = _parentNode;
	@synthesize ownerDocument = _ownerDocument;

	-(instancetype)init {
		self = [super init];

		if(self) {
			_userData = [NSMutableDictionary dictionary];
		}

		return self;
	}

	-(PGDOMNodeTypes)nodeType {
		return PGDOMUnknownNode;
	}

	-(NSString *)prefix {
		return nil;
	}

	-(void)setPrefix:(NSString *)prefix {
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

	-(PGNamedNodeMap *)attributes {
		return [PGNamedNodeMap instance];
	}

	-(PGNodeList *)childNodes {
		return [PGNodeList instance];
	}

	-(NSString *)baseURI {
		return nil;
	}

	-(NSString *)localName {
		return nil;
	}

	-(NSString *)namespaceURI {
		return nil;
	}

	-(NSString *)nodeName {
		return nil;
	}

	-(BOOL)hasChildNodes {
		return NO;
	}

	-(BOOL)hasAttributes {
		return NO;
	}

	-(PGNode *)firstChild {
		return nil;
	}

	-(PGNode *)lastChild {
		return nil;
	}

	-(PGNode *)nextSibling {
		return nil;
	}

	-(PGNode *)previousSibling {
		return nil;
	}

	-(NSString *)nodeTypeName:(PGDOMNodeTypes)nodeType {
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
		return [self nodeTypeName:self.nodeType];
	}

	-(id)copyWithZone:(NSZone *)zone {
		PGNode *copy = ((PGNode *)[[[self class] allocWithZone:zone] init]);

		if(copy != nil) {
			copy->_ownerDocument = _ownerDocument;
		}

		return copy;
	}

	-(id)copy:(BOOL)deep {
		return [self copy];
	}

	-(PGNode *)appendNode:(PGNode *)newNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(NSInteger)compareDocumentPosition:(PGNode *)node {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(NSString *)feature:(NSString *)feature version:(NSString *)version {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(id)userData:(NSString *)name {
		@synchronized(self) {
			return _userData[name];
		}
	}

	-(void)setUserData:(id)obj forName:(NSString *)name {
		@synchronized(self) {
			_userData[name] = obj;
		}
	}

	-(PGNode *)insertNode:(PGNode *)newNode before:(PGNode *)referenceNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(BOOL)isDefaultNamespace:(NSString *)namespaceURI {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(BOOL)isSupported:(NSString *)feature version:(NSString *)version {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(NSString *)lookupNamespaceURI:(NSString *)prefix {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(NSString *)lookupPrefix:(NSString *)namespaceURI {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(void)normalize {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGNode *)removeChild:(PGNode *)oldNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(PGNode *)replaceChild:(PGNode *)oldNode newNode:(PGNode *)newNode {
		@throw [NSException exceptionWithName:PGDOMException reason:@"Function not implemented." userInfo:nil];
	}

	-(BOOL)isEqualNode:(PGNode *)other {
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

	-(BOOL)isSameNode:(PGNode *)node {
		return (self == node);
	}

	-(BOOL)isEqual:(id)other {
		return [self isSameNode:other];
	}

@end
