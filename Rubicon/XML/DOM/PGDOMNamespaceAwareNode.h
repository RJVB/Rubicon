/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNamespaceAwareNode.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 2/2/17 8:13 PM
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

#ifndef __Rubicon_PGNamespaceAwareNode_H_
#define __Rubicon_PGNamespaceAwareNode_H_

#import <Rubicon/PGDOMNode.h>

@interface PGDOMNamespaceAwareNode : PGDOMChildNode

	-(BOOL)isDefaultNamespace:(NSString *)namespaceURI;

	-(NSString *)lookupNamespaceURI:(NSString *)prefix;

	-(NSString *)lookupPrefix:(NSString *)namespaceURI;

@end

#endif //__Rubicon_PGNamespaceAwareNode_H_
