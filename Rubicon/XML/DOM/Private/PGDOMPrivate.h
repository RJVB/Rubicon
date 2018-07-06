/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMPrivate.h
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

#ifndef RUBICON_PGDOMPRIVATE_H
#define RUBICON_PGDOMPRIVATE_H

#import "PGInternal.h"
#import "PGDOMNode.h"
#import "PGDOMParent.h"
#import "PGDOMNamespaceAware.h"
#import "PGDOMAttr.h"
#import "PGDOMElement.h"
#import "PGDOMNodeList.h"
#import "PGDOMNamedNodeMap.h"
#import "PGDOMNotifiedContainer.h"
#import "PGDOMNodeContainer.h"
#import "PGDOMAttributeMap.h"
#import "PGDOMNamedNodeMapImpl.h"

typedef PGMutableBinaryTreeDictionary<NSString *, PGDOMNode *>   *PGDOMNodeTree;
typedef PGMutableBinaryTreeDictionary<NSString *, PGDOMNodeTree> *PGDOMNodeNodeTree;

NS_ASSUME_NONNULL_BEGIN

@interface PGDOMNode()

    @property(nonatomic, readonly, nullable) NSString  *nodeTypeDescription;
    @property(nonatomic, nullable) /*     */ PGDOMNode *parentNode;
    @property(nonatomic, nullable) /*     */ PGDOMNode *previousSibling;
    @property(nonatomic, nullable) /*     */ PGDOMNode *nextSibling;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(nullable PGDOMDocument *)ownerDocument;

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap;

@end

@interface PGDOMParent()

    -(NSException *)createException:(NSString *)reason;

    -(void)testNewChildNode:(PGDOMNode *)node;

    -(void)postChildListChangeNotification;

@end

@interface PGDOMDocument()

    @property(nonatomic, readonly) NSNotificationCenter *notificationCenter;

@end

@interface PGDOMNamespaceAware()

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(PGDOMDocument *)ownerDocument
                      qualifiedName:(NSString *)qualifiedName
                       namespaceURI:(NSString *)namespaceURI;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(PGDOMDocument *)ownerDocument
                          localName:(NSString *)localName
                             prefix:(NSString *)prefix
                       namespaceURI:(NSString *)namespaceURI;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(PGDOMDocument *)ownerDocument nodeName:(NSString *)nodeName;

    -(NSException *)createException:(NSString *)reason;

    +(NSRegularExpression *)validationRegex;

    -(void)validateCharacters:(NSString *)name;

    -(void)validateCharacters:(NSString *)localName prefix:(NSString *)prefix;

    -(void)validateNames;

    -(void)validateLocalName:(NSString *)lnm prefix:(NSString *)pfx namespaceURI:(NSString *)uri;

@end

@interface PGDOMAttr()

    @property(nonatomic) /*     */ BOOL         isSpecified;
    @property(nonatomic) /*     */ BOOL         isID;
    @property(nonatomic, nullable) PGDOMElement *ownerElement;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                                    name:(NSString *)name
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                           qualifiedName:(NSString *)qualifiedName
                            namespaceURI:(NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                               localName:(NSString *)localName
                                  prefix:(NSString *)prefix
                            namespaceURI:(NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

@end

@interface PGDOMElement()

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument localName:(NSString *)localName prefix:(NSString *)prefix namespaceURI:(NSString *)namespaceURI;

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap;

    -(PGDOMAttr *)_setAttribute:(PGDOMAttr *)attr;

    -(PGDOMAttr *)_setAttributeNS:(PGDOMAttr *)attr;
@end

@interface PGDOMNotifiedContainer()

    @property(nonatomic, readonly, nullable) PGDOMNode            *ownerNode;
    @property(nonatomic, readonly, nullable) PGDOMDocument        *ownerDocument;
    @property(nonatomic, readonly) /*     */ NSNotificationCenter *nc;

    -(instancetype)initWithOwnerNode:(nullable PGDOMNode *)ownerNode notificationName:(NSNotificationName)notificationName;

@end

@interface PGDOMNodeContainer<T:PGDOMNode *>()

    @property(nonatomic, readonly) NSMutableArray<T> *items;

    -(instancetype)init;

    -(instancetype)initWithOwnerNode:(nullable PGDOMNode *)ownerNode;

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nullable])buffer count:(NSUInteger)len;

    -(T)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface PGDOMNodeList<T:PGDOMNode *>()

@end

@interface PGDOMNamedNodeMap<T:PGDOMNode *>()

@end

@interface PGDOMNamedNodeMapImpl<T:PGDOMNode *>()

    @property(nonatomic, readonly) PGDOMNodeTree     nodeNameCache;
    @property(nonatomic, readonly) PGDOMNodeNodeTree localNameCache;

    -(void)clearCaches;

    -(nullable T)removeNode:(nullable T)node;

    -(nullable T)replaceNode:(nullable T)oldNode withNode:(T)newNode;

@end

@interface PGDOMAttributeMap()

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMPRIVATE_H
