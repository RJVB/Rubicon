/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBTreeDictionary.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/31/17 2:10 PM
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

#import "PGBTreeDictionary.h"
#import "PGBTreeDictionaryKeyEnumerator.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@implementation PGBTreeDictionary {
        PGBTreeMutableDictionary *_treeDict;
    }

    -(instancetype)init {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] init];
        return self;
    }

    -(instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:NO];
        return self;
    }

    -(instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:YES];
        return self;
    }

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
        return self;
    }

    -(instancetype)initWithObject:(const id)object forKey:(const id)key {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] initWithObject:object forKey:key];
        return self;
    }

    -(instancetype)initWithCoder:(NSCoder *)coder {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] initWithCoder:coder];
        return self;
    }

    -(instancetype)initWithContentsOfFile:(NSString *)path {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] initWithContentsOfFile:path];
        return self;
    }

    -(instancetype)initWithContentsOfURL:(NSURL *)url {
        self = [super init];
        if(self) _treeDict = [[PGBTreeMutableDictionary alloc] initWithContentsOfURL:url];
        return self;
    }

    -(PGBTreeNode<PGKeyValueData *> *)root {
        return _treeDict.root;
    }

    -(NSUInteger)count {
        return [_treeDict count];
    }

    -(id)objectForKey:(id)aKey {
        return [_treeDict objectForKey:aKey];
    }

    -(NSEnumerator *)keyEnumerator {
        return [_treeDict keyEnumerator];
    }

    -(id)mutableCopyWithZone:(nullable NSZone *)zone {
        return [[PGBTreeMutableDictionary allocWithZone:zone] initWithDictionary:_treeDict];
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return [(PGBTreeDictionary *)[[self class] allocWithZone:zone] initWithDictionary:_treeDict];
    }

@end

@implementation PGBTreeMutableDictionary {
    }

    @synthesize root = _root;

    -(instancetype)init {
        return (self = [super init]);
    }

    -(instancetype)initWithCapacity:(NSUInteger)numItems {
        return (self = [super init]);
    }

    -(instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
        return (self = [self initWithDictionary:otherDictionary copyItems:NO]);
    }

    -(instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
        self = [super init];

        if(self) {
            for(id aKey in otherDictionary.allKeys) {
                id obj = otherDictionary[aKey];
                if(flag && [obj conformsToProtocol:@protocol(NSCopying)]) obj = [obj copy];
                [self setObject:obj forKey:aKey];
            }
        }

        return self;
    }

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
        self = [super init];
        if(self) for(NSUInteger i = 0; i < cnt; i++) [self setObject:objects[i] forKey:keys[i]];
        return self;
    }

    -(instancetype)initWithObject:(const id)object forKey:(const id)key {
        self = [super init];
        if(self) [self setObject:object forKey:key];
        return self;
    }

    -(instancetype)initWithCoder:(NSCoder *)coder {
        return (self = [self initWithDictionary:[[NSDictionary alloc] initWithCoder:coder]]);
    }

    -(instancetype)initWithContentsOfFile:(NSString *)path {
        return (self = [self initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:path]]);
    }

    -(instancetype)initWithContentsOfURL:(NSURL *)url {
        return (self = [self initWithDictionary:[NSDictionary dictionaryWithContentsOfURL:url]]);
    }

    -(void)setRoot:(PGBTreeNode<PGKeyValueData *> *)node {
        while(node.parent) node = node.parent;
        _root = node;
    }

    -(PGBTreeNode<PGKeyValueData *> *)findNode:(id)aKey {
        return ((_root && aKey) ? [_root findWithCompareBlock:^NSComparisonResult(PGKeyValueData *nodeData) { return [nodeData compareKeyTo:aKey]; }] : nil);
    }

    -(NSUInteger)count {
        return _root.count;
    }

    -(id)objectForKey:(id)aKey {
        return [self findNode:aKey].data.value;
    }

    -(NSEnumerator *)keyEnumerator {
        return (_root ? [[PGBTreeDictionaryKeyEnumerator alloc] initWithMutableBTreeDictionary:self] : [[PGEmptyEnumerator alloc] init]);
    }

    -(void)removeObjectForKey:(id)aKey {
        if(aKey == nil) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key is null." userInfo:nil];
        }
        else if(_root) {
            PGBTreeNode<PGKeyValueData *> *fnode = [self findNode:aKey];
            if(fnode) self.root = fnode.remove;
        }
    }

    -(void)setObject:(id)anObject forKey:(id)aKey {
        if(anObject == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key is null." userInfo:nil];
        else if(aKey == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Object is null." userInfo:nil];
        else if(_root) {
            NSComparisonResult (^compareBlock)(PGKeyValueData *)=^NSComparisonResult(PGKeyValueData *nodeData) { return [nodeData compareKeyTo:aKey]; };
            PGKeyValueData *(^dataBlock)()=^PGKeyValueData *() { return [PGKeyValueData dataWithValue:anObject forKey:aKey]; };

            self.root = [_root insertWithCompareBlock:compareBlock dataBlock:dataBlock];
        }
        else {
            self.root = [PGBTreeNode nodeWithData:[PGKeyValueData dataWithValue:anObject forKey:aKey]];
        }
    }

    -(void)removeAllObjects {
        if(_root) {
            [_root clearTree];
            _root = nil;
        }
    }

    -(void)dealloc {
        [self removeAllObjects];
    }

    -(id)mutableCopyWithZone:(nullable NSZone *)zone {
        return [(PGBTreeMutableDictionary *)[[self class] allocWithZone:zone] initWithDictionary:self];
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return [self mutableCopyWithZone:zone];
    }

@end

#pragma clang diagnostic pop
