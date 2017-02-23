/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/15/17 7:01 PM
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

#import "PGDOMNode.h"
#import "PGTools.h"

@implementation PGDOMNode {
	}

	-(PGDOMNodeTypes)nodeType {
		return PGDOMNodeTypeProcessingInstruction;
	}

	-(instancetype)init {
		return (self = [super init]);
	}

	-(NSString *)nodeName {
		return nil;
	}

	-(NSString *)nodeValue {
		return nil;
	}

	-(void)setNodeValue:(NSString *)nodeValue {
	}

	-(NSString *)prefix {
		return nil;
	}

	-(void)setPrefix:(NSString *)prefix {
	}

	-(NSString *)textContent {
		return nil;
	}

	-(void)setTextContent:(NSString *)textContent {
	}

	-(NSString *)baseURI {
		return nil;
	}

	-(NSString *)namespaceURI {
		return nil;
	}

	-(NSString *)localName {
		return nil;
	}

	-(PGDOMNode *)parentNode {
		return nil;
	}

	-(PGDOMDocument *)ownerDocument {
		return nil;
	}

	-(PGDOMNode *)firstChild {
		return nil;
	}

	-(PGDOMNode *)lastChild {
		return nil;
	}

	-(PGDOMNamedNodeMap *)attributes {
		return nil;
	}

	-(PGDOMNodeList *)childNodes {
		return nil;
	}

	-(PGDOMNode *)nextSibling {
		return nil;
	}

	-(PGDOMNode *)previousSibling {
		return nil;
	}

	-(BOOL)hasChildNodes {
		return NO;
	}

	-(BOOL)hasAttributes {
		return NO;
	}

	-(PGDOMNode *)appendChild:(PGDOMNode *)newChild {
		return nil;
	}

	-(PGDOMNode *)insertChild:(PGDOMNode *)newChild before:(PGDOMNode *)referenceChild {
		return nil;
	}

	-(PGDOMNode *)removeChild:(PGDOMNode *)oldChild {
		return nil;
	}

	-(PGDOMNode *)replaceChild:(PGDOMNode *)oldChild withNode:(PGDOMNode *)newChild {
		return nil;
	}

	-(BOOL)isEqual:(id)other {
		return (other && ((self == other) || ([other isMemberOfClass:[self class]] && [self isSameNode:other])));
	}

	-(BOOL)isSameNode:(PGDOMNode *)other {
		return (self == other);
	}

	-(BOOL)isEqualToNode:(PGDOMNode *)other {
		return (other &&
				((self == other) ||
				 ((self.nodeType == other.nodeType) &&
				  PGObjectsEqual(self.nodeName, other.nodeName) &&
				  PGObjectsEqual(self.nodeValue, other.nodeValue) &&
				  PGObjectsEqual(self.prefix, other.prefix) &&
				  PGObjectsEqual(self.localName, other.localName) &&
				  PGObjectsEqual(self.namespaceURI, other.namespaceURI) &&
				  PGObjectsEqual(self.attributes, other.attributes) &&
				  PGObjectsEqual(self.childNodes, other.childNodes))));
	}

	-(BOOL)isDefaultNamespace:(NSString *)namespaceURI {
		return NO;
	}

	-(NSString *)lookupNamespaceURI:(NSString *)prefix {
		return nil;
	}

	-(NSString *)lookupPrefix:(NSString *)namespaceURI {
		return nil;
	}

	-(id)userDataForKey:(NSString *)key {
		return nil;
	}

	-(id)setUserData:(id)object forKey:(NSString *)key {
		return nil;
	}

	-(void)normalize {
	}

	-(id)copyWithZone:(NSZone *)zone {
		return nil;
	}

	-(id)copy {
		return [self copy:NO];
	}

	-(id)copy:(BOOL)deep {
		return [super copy];
	}

@end
