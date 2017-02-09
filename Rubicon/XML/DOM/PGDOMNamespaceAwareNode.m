/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNamespaceAwareNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/2/17 8:13 PM
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

@implementation PGDOMNamespaceAwareNode {
		NSString *_prefix;
		NSString *_baseURI;
		NSString *_namespaceURI;
		NSString *_nodeName;
	}

	-(instancetype)init {
		self = [super init];

		if(self) {
			// Init...
		}

		return self;
	}

	-(NSString *)localName {
		return nil;
	}

	-(NSString *)nodeName {
		return _nodeName;
	}

	-(void)setNodeName:(NSString *)nodeName {
		_nodeName = [nodeName copy];
	}

	-(NSString *)prefix {
		return _prefix;
	}

	-(void)setPrefix:(NSString *)prefix {
		_prefix = [prefix copy];
	}

	-(NSString *)baseURI {
		return _baseURI;
	}

	-(void)setBaseURI:(NSString *)baseURI {
		_baseURI = [baseURI copy];
	}

	-(NSString *)namespaceURI {
		return _namespaceURI;
	}

	-(void)setNamespaceURI:(NSString *)namespaceURI {
		_namespaceURI = [namespaceURI copy];
	}

	-(BOOL)isDefaultNamespace:(NSString *)namespaceURI {
		return [super isDefaultNamespace:namespaceURI];
	}

	-(NSString *)lookupNamespaceURI:(NSString *)prefix {
		return [super lookupNamespaceURI:prefix];
	}

	-(NSString *)lookupPrefix:(NSString *)namespaceURI {
		return [super lookupPrefix:namespaceURI];
	}

@end
