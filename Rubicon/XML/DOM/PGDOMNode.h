/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNode.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
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

#ifndef RUBICON_PGDOMNODE_H
#define RUBICON_PGDOMNODE_H

#import <Rubicon/PGDOMDefines.h>
#import <Rubicon/PGDOMNodeList.h>
#import <Rubicon/PGDOMNamedNodeMap.h>

@class PGDOMDocument;
@class PGDOMUserDataHandler;

NS_ASSUME_NONNULL_BEGIN

@interface PGDOMNode : NSObject<NSFastEnumeration>

    @property(nonatomic, readonly, copy) /*     */ NSString                   *nodeName;
    @property(nonatomic, nullable, copy) /*     */ NSString                   *nodeValue;
    @property(nonatomic, readonly, copy) /*     */ NSString                   *localName;
    @property(nonatomic, nullable, copy) /*     */ NSString                   *prefix;
    @property(nonatomic, nullable, readonly, copy) NSString                   *namespaceURI;
    @property(nonatomic, nullable, readonly, copy) NSString                   *baseURI;
    @property(nonatomic, nullable, copy) /*     */ NSString                   *textContent;
    @property(nonatomic, readonly) /*           */ PGDOMNodeTypes             nodeType;
    @property(nonatomic, readonly, nullable) /* */ PGDOMNode                  *parentNode;
    @property(nonatomic, readonly, nullable) /* */ PGDOMNode                  *previousSibling;
    @property(nonatomic, readonly, nullable) /* */ PGDOMNode                  *nextSibling;
    @property(nonatomic, readonly, nullable) /* */ PGDOMNode                  *firstChild;
    @property(nonatomic, readonly, nullable) /* */ PGDOMNode                  *lastChild;
    @property(nonatomic, readonly, nullable) /* */ PGDOMDocument              *ownerDocument;
    @property(nonatomic, readonly) /*           */ PGDOMNodeList<PGDOMNode *> *childNodes;
    @property(nonatomic, readonly) /*           */ BOOL                       hasNamespace;

    -(PGDOMNode *)appendChild:(PGDOMNode *)newNode;

    -(PGDOMNode *)insertChild:(PGDOMNode *)newNode before:(nullable PGDOMNode *)refNode;

    -(PGDOMNode *)replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode;

    -(PGDOMNode *)removeChild:(PGDOMNode *)oldNode;

    -(nullable id)userDataForKey:(NSString *)key;

    -(nullable id)setUserData:(nullable id)data forKey:(NSString *)key handler:(nullable PGDOMUserDataHandler *)handler;

    -(NSEnumerator<PGDOMNode *> *)childNodeEnumerator;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMNODE_H
