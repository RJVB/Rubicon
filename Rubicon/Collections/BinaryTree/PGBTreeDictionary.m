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
#import "PGBTreeNode.h"
#import "PGKeyValueData.h"
#import "PGTools.h"
#import "PGEmptyEnumerator.h"
#import "PGStack.h"

@interface PGBTreeKVNode : PGBTreeNode

    @property(readonly) id key;
    @property(readonly) id value;

    -(instancetype)initWithValue:(const id)value forKey:(const id<NSCopying>)key;

    -(instancetype)insertValue:(const id)value forKey:(const id<NSCopying>)key;

@end

@interface PGBTreeDictionary()

    @property(retain) PGBTreeKVNode *root;

    -(void)setObject:(const id)object forKey:(const id<NSCopying>)key;

    -(void)removeObjectForKey:(id)aKey;

    -(void)removeAllObjects;
@end

@interface PGBTreeMutableDictionary()

    @property(retain, readonly) PGBTreeDictionary *treeDictionary;

@end

@interface PGBTreeDictionaryKeyEnumerator : NSEnumerator

    @property(retain) PGBTreeDictionary *dictionary;
    @property(retain) PGBTreeKVNode     *current;
    @property(retain) PGStack           *stack;

    -(instancetype)initWithBTreeDictionary:(PGBTreeDictionary *)dict;

    -(PGBTreeKVNode *)driveLeft:(PGBTreeKVNode *)node;

    -(id)nextObject;

    -(NSArray *)allObjects;
@end

@implementation PGBTreeDictionary {
    }

    @synthesize root = _root;

    -(instancetype)init { return (self = [super init]); }

    -(instancetype)initWithDictionary:(NSDictionary *)dict {
        self = [super init];

        if(self) {
            for(id key in dict.allKeys) {
                [self setObject:dict[key] forKey:key];
            }
        }

        return self;
    }

    -(instancetype)initWithObject:(const id)object forKey:(const id<NSCopying>)key {
        self = [super init];

        if(self) {
            [self setObject:object forKey:key];
        }

        return self;
    }

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
        self = [super init];

        if(self) {
            if(cnt) {
                if(objects) {
                    if(keys) {
                        for(NSUInteger i = 0; i < cnt; i++) {
                            [self setObject:objects[i] forKey:keys[i]];
                        }
                    }
                    else {
                        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"keys cannot be null." userInfo:nil];
                    }
                }
                else {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"objects cannot be null." userInfo:nil];
                }
            }
        }

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

    -(NSEnumerator *)keyEnumerator {
        return (self.root ? [[PGBTreeDictionaryKeyEnumerator alloc] initWithBTreeDictionary:self] : [PGEmptyEnumerator emptyEnumerator]);
    }

    -(void)setObject:(const id)object forKey:(const id<NSCopying>)key {
        self.root = (self.root ? [[self.root insertValue:object forKey:key] root] : [[PGBTreeKVNode alloc] initWithValue:object forKey:key]);
    }

    -(id)objectForKey:(id)aKey { return [self.root find:aKey].value; }

    -(NSUInteger)count { return self.root.count; }

    -(void)removeObjectForKey:(id)aKey { if(aKey) self.root = [[self.root find:aKey] remove]; }

    -(void)removeAllObjects {
        [self.root clearTree];
        self.root = nil;
    }

@end

@implementation PGBTreeMutableDictionary {
    }

    @synthesize treeDictionary = _treeDictionary;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _treeDictionary = [[PGBTreeDictionary alloc] init];
        }

        return self;
    }

    -(instancetype)initWithCapacity:(NSUInteger)numItems {
        self = [super init];

        if(self) {
            _treeDictionary = [[PGBTreeDictionary alloc] init];
        }

        return self;
    }

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
        self = [super init];

        if(self) {
            _treeDictionary = [[PGBTreeDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
        }

        return self;
    }

    -(instancetype)initWithObject:(const id)object forKey:(const id<NSCopying>)key {
        self = [super init];

        if(self) {
            _treeDictionary = [[PGBTreeDictionary alloc] initWithObject:object forKey:key];
        }

        return self;
    }

    -(instancetype)initWithCoder:(NSCoder *)coder {
        self = [super init];

        if(self) {
            _treeDictionary = [[PGBTreeDictionary alloc] initWithCoder:coder];
        }

        return self;
    }

    -(instancetype)initWithContentsOfFile:(NSString *)path {
        self = [super init];

        if(self) {
            _treeDictionary = [[PGBTreeDictionary alloc] initWithContentsOfFile:path];
        }

        return self;
    }

    -(instancetype)initWithContentsOfURL:(NSURL *)url {
        self = [super init];

        if(self) {
            _treeDictionary = [[PGBTreeDictionary alloc] initWithContentsOfURL:url];
        }

        return self;
    }

    -(NSUInteger)count { return self.treeDictionary.count; }

    -(id)objectForKey:(id)aKey { return self.treeDictionary[aKey]; }

    -(NSEnumerator *)keyEnumerator { return self.treeDictionary.keyEnumerator; }

    -(void)removeObjectForKey:(id)aKey { [self.treeDictionary removeObjectForKey:aKey]; }

    -(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey { [self.treeDictionary setObject:anObject forKey:aKey]; }

    -(void)removeAllObjects {
        [self.treeDictionary removeAllObjects];
    }

@end

@implementation PGBTreeKVNode {
    }

    -(id)key {
        return [(PGKeyValueData *)self.data key];
    }

    -(id)value {
        return [(PGKeyValueData *)self.data value];
    }

    -(instancetype)initWithValue:(const id)value forKey:(const id<NSCopying>)key {
        return (self = [super initWithData:[PGKeyValueData dataWithValue:value forKey:key]]);
    }

    -(instancetype)insertValue:(const id)value forKey:(const id<NSCopying>)key {
        return [self insert:[PGKeyValueData dataWithValue:value forKey:key]];
    }

    -(instancetype)find:(id)key {
        if(key) {
            switch(PGCompare(self.key, key)) {
                case NSOrderedAscending:
                    return [self.right find:key];
                case NSOrderedDescending:
                    return [self.left find:key];
                case NSOrderedSame:
                    return self;
            }
        }
        return nil;
    }

@end

@implementation PGBTreeDictionaryKeyEnumerator {
    }

    @synthesize dictionary = _dictionary;
    @synthesize current = _current;
    @synthesize stack = _stack;

    -(instancetype)initWithBTreeDictionary:(PGBTreeDictionary *)dict {
        self = [super init];

        if(self) {
            self.dictionary = dict;
            self.stack      = [[PGStack alloc] init];
            self.current    = [self driveLeft:self.dictionary.root];
        }

        return self;
    }

    -(PGBTreeKVNode *)driveLeft:(PGBTreeKVNode *)node {
        if(node && node.left) {
            [self.stack push:node];
            return [self driveLeft:node.left];
        }

        return node;
    }

    -(id)nextObject {
        id obj = nil;

        if(self.current) {
            obj = self.current.key;
            self.current = (self.current.right ? [self driveLeft:self.current.right] : [self.stack pop]);
        }

        return obj;
    }

    -(NSArray *)allObjects {
        NSMutableArray *array = [NSMutableArray array];
        id             obj    = self.nextObject;

        while(obj) {
            [array addObject:obj];
            obj = self.nextObject;
        }

        return array;
    }

@end
