/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMElement.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/8/17 10:27 PM
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
#import "PGDOMNodeList.h"
#import "PGDOMNamedNodeMap.h"

@implementation PGDOMElement {
	}

	-(NSString *)tagName {
		return self.nodeName;
	}

	-(void)setTagName:(NSString *)tagName {
		self.nodeName = tagName;
	}

	-(PGDOMNodeTypes)nodeType {
		return PGDOMElementNode;
	}

	-(PGDOMNode *)childAfter:(PGDOMNode *)child {
		if(child) {
			PGDOMNodeList *children = self.childNodes;
			NSUInteger    cc        = children.count - 1;

			for(NSUInteger i = 0; i < cc; i++) {
				if([child isSameNode:[children item:i]]) {
					return [children item:i + 1];
				}
			}
		}

		return nil;
	}

	-(PGDOMNode *)childBefore:(PGDOMNode *)child {
		if(child) {
			PGDOMNodeList *children = self.childNodes;
			NSUInteger    cc        = children.count;

			for(NSUInteger i = 1; i < cc; i++) {
				if([child isSameNode:[children item:i]]) {
					return [children item:i - 1];
				}
			}
		}

		return nil;
	}

	-(PGDOMNamedNodeMap *)attributes {
		return nil;
	}

	-(PGDOMNodeList *)childNodes {
		return nil;
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

@end
