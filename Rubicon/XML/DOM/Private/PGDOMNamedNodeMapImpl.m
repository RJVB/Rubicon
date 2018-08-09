/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNamedNodeMapImpl.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/3/18
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

#import "PGDOMPrivate.h"

typedef BOOL (^PGDOMCacheSrchPred)(NSString *key, NSNumber *obj, BOOL *stop);

@implementation PGDOMNamedNodeMapImpl {
        NSMutableDictionary<NSString *, NSNumber *> *_nodeNameCache;
        NSMutableDictionary<NSString *, NSNumber *> *_nodeNSCache;
    }

    -(instancetype)init {
        self = [super init];

        if(self) {
            _nodeNameCache = [NSMutableDictionary new];
            _nodeNSCache   = [NSMutableDictionary new];
        }

        return self;
    }

    -(instancetype)initWithOwnerNode:(PGDOMNode *)ownerNode {
        self = [super initWithOwnerNode:ownerNode];

        if(self) {
            _nodeNameCache = [NSMutableDictionary new];
            _nodeNSCache   = [NSMutableDictionary new];
        }

        return self;
    }

    -(void)nodeListChangeListener:(NSNotification *)notification {
        [self clearCaches];
        [super nodeListChangeListener:notification];
    }

    -(PGDOMNode *)itemWithName:(NSString *)nodeName {
        return [self item:[self indexOfItemWithName:nodeName]];
    }

    -(PGDOMNode *)itemWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return [self item:[self indexOfItemWithLocalName:localName namespaceURI:namespaceURI]];
    }

    -(PGDOMNode *)addItem:(PGDOMNode *)node {
        NSString   *name    = node.nodeName;
        NSUInteger idxOther = [self.items indexOfObjectIdenticalTo:node];

        if(idxOther == NSNotFound) {
            if((idxOther = [self indexOfItemWithName:name]) == NSNotFound) {
                idxOther = self.items.count;
                [self.items addObject:node];
            }
            else {
                PGDOMNode *other = node;
                node = self.items[idxOther];
                self.items[idxOther] = other;
            }

            _nodeNameCache[name] = @(idxOther);
            /*
             * If we're just adding a new item to the list then we don't need to clear the cache.
             * Just sending the notification is all that is needed.
             */
            [self.nc postNotificationName:PGDOMNodeListChangedNotification object:self];
        }

        return node;
    }

    -(PGDOMNode *)addItemNS:(PGDOMNode *)node {
        NSString   *localName    = (node.localName ?: node.nodeName);
        NSString   *namespaceURI = node.namespaceURI;
        NSUInteger idxOther      = [self.items indexOfObjectIdenticalTo:node];

        if(idxOther == NSNotFound) {
            if((idxOther = [self indexOfItemWithLocalName:localName namespaceURI:namespaceURI]) == NSNotFound) {
                idxOther = self.items.count;
                [self.items addObject:node];
            }
            else {
                PGDOMNode *other = node;
                node = self.items[idxOther];
                self.items[idxOther] = other;
            }

            NSString *key = (localName.length ? PGFormat(@"%@:%@", (namespaceURI ?: @""), localName) : nil);
            if(key) _nodeNSCache[key] = @(idxOther);
            /*
             * If we're just adding a new item to the list then we don't need to clear the cache.
             * Just sending the notification is all that is needed.
             */
            [self.nc postNotificationName:PGDOMNodeListChangedNotification object:self];
        }

        return node;
    }

    -(PGDOMNode *)removeItemWithName:(NSString *)nodeName {
        return [self removeNodeAtIndex:[self indexOfItemWithName:nodeName]];
    }

    -(PGDOMNode *)removeItemWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return [self removeNodeAtIndex:[self indexOfItemWithLocalName:localName namespaceURI:namespaceURI]];
    }

    -(PGDOMNode *)removeItem:(PGDOMNode *)node {
        NSUInteger idx = [self.items indexOfObjectIdenticalTo:node];
        return [self removeNodeAtIndex:((idx == NSNotFound) ? [self indexOfItemWithName:node.nodeName] : idx)];
    }

    -(PGDOMNode *)removeItemNS:(PGDOMNode *)node {
        NSUInteger idx = [self.items indexOfObjectIdenticalTo:node];
        return [self removeNodeAtIndex:((idx == NSNotFound) ? [self indexOfSimilarNodeNS:node] : idx)];
    }

    -(NSUInteger)getCachedIndexForKey:(NSString *)key map:(NSMutableDictionary<NSString *, NSNumber *> *)map predicate:(PGDOMSrchPred)pred {
        NSUInteger idx = NSNotFound;

        if(pred && key.notEmpty && ((idx = (map[key] ?: @(NSNotFound)).unsignedLongValue) == NSNotFound)) {
            if((idx = [self findItem:pred]) == NSNotFound) [map removeObjectForKey:key]; else map[key] = @(idx);
        }

        return idx;
    }

    -(NSUInteger)indexOfItemWithName:(NSString *)name {
        PGDOMSrchPred pred = ^BOOL(PGDOMNode *_obj, NSUInteger _idx, BOOL *_stop) { return PGStringsEqual(name, _obj.nodeName); };
        return [self getCachedIndexForKey:name map:_nodeNameCache predicate:pred];
    }

    -(NSUInteger)indexOfItemWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        NSString      *key = (localName.length ? PGFormat(@"%@:%@", (namespaceURI ?: @""), localName) : nil);
        PGDOMSrchPred pred = ^BOOL(PGDOMNode *_obj, NSUInteger _idx, BOOL *_stop) {
            return (namespaceURI.length ?
                    (PGStringsEqual(namespaceURI, _obj.namespaceURI) && PGStringsEqual(localName, _obj.localName)) :
                    ((_obj.namespaceURI.isEmpty) && PGStringsEqual(localName, (_obj.localName ?: _obj.nodeName))));
        };
        return [self getCachedIndexForKey:key map:_nodeNSCache predicate:pred];
    }

    -(NSUInteger)indexOfSimilarNode:(PGDOMNode *)node {
        return [self indexOfItemWithName:node.nodeName];
    }

    -(NSUInteger)indexOfSimilarNodeNS:(PGDOMNode *)node {
        return [self indexOfItemWithLocalName:(node.localName ?: node.nodeName) namespaceURI:node.namespaceURI];
    }

    -(PGDOMNode *)removeNodeAtIndex:(NSUInteger)idx {
        if(idx == NSNotFound) return nil;
        PGDOMNode *dnode = self.items[idx];
        [self.items removeObjectAtIndex:idx];
        [self postChangeNotification];
        return dnode;
    }

    -(NSUInteger)findItem:(PGDOMSrchPred)pred {
        return [self.items indexOfObjectPassingTest:pred];
    }

    -(void)postChangeNotification {
        [self clearCaches];
        [self.nc postNotificationName:PGDOMNodeListChangedNotification object:self];
    }

    -(void)clearCaches {
        [_nodeNameCache removeAllObjects];
        [_nodeNSCache removeAllObjects];
    }

    -(void)addItem:(PGDOMNode *)node forIndex:(NSUInteger)idx {
        if(idx == NSNotFound) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid Node Index."];
        if(node == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Node is null."];
        if((node.localName.isEmpty) && (node.nodeName.isEmpty)) @throw [NSException exceptionWithName:PGDOMException reason:@"Node has no name."];

        NSString           *nodeName = (node.nodeName ?: @"");
        NSString           *nsKey    = [self createNSKeyWithLocalName:node.localName namespaceURI:node.namespaceURI nodeName:nodeName];
        PGDOMCacheSrchPred pred      = ^BOOL(NSString *key, NSNumber *obj, BOOL *stop) { return (obj.unsignedLongValue == idx); };

        [_nodeNameCache removeAllObjectsPassingTest:pred];
        [_nodeNSCache removeAllObjectsPassingTest:pred];
        _nodeNSCache[nsKey] = _nodeNameCache[nodeName] = @(idx);
    }

    -(NSString *)createNSKeyWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI nodeName:(NSString *)nodeName {
        NSUInteger lnlen = localName.length;
        return (((lnlen == 0) && (nodeName.isEmpty)) ? nil : PGFormat(@"%@:%@", (namespaceURI ?: @""), (lnlen ? localName : nodeName)));
    }

@end
