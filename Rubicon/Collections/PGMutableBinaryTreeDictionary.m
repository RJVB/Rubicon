/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMutableBinaryTreeDictionary.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/26/18
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

#import "PGInternal.h"
#import "PGRedBlackNodePrivate.h"

@interface PGKeyBinaryTreeKeyEnumerator : NSEnumerator

    @property(readonly, retain) id owner;

    -(instancetype)initWithOwner:(id)owner rootNode:(PGRedBlackNode *)rootNode;

@end

@interface PGMutableBinaryTreeDictionary()

    -(void)_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end

@implementation PGMutableBinaryTreeDictionary {
        PGRedBlackNode *_rootNode;
    }

    -(instancetype)init {
        self = [super init];
        if(self) _rootNode = nil;
        return self;
    }

    -(instancetype)initWithCapacity:(NSUInteger)numItems {
        self = [super init];
        if(self) _rootNode = nil;
        return self;
    }

    -(instancetype)initWithCoder:(NSCoder *)aDecoder {
        self = [super init];

        if(self) {
            NSDictionary *dict = [[NSDictionary alloc] initWithCoder:aDecoder];

            if(dict) {
                _rootNode = nil;
                [self addEntriesFromDictionary:dict];
            }
            else self = nil;
        }

        return self;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

    -(instancetype)initWithObject:(id)anObject forKey:(id<NSCopying>)aKey {
        self = [self init];

        if(self) {
            if(aKey == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key is NULL."];
            if(anObject == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Object is NULL."];
            [self _setObject:anObject forKey:aKey];
        }

        return self;
    }

#pragma clang diagnostic pop

    -(instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
        self = [self init];

        if(self) {
            for(NSUInteger i = 0; i < cnt; i++) {
                id<NSCopying> aKey     = keys[i];
                id            anObject = objects[i];

                if(aKey == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(@"key at index %lu is NULL.", i)];
                if(anObject == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(@"object at index %lu is NULL.", i)];

                [self _setObject:anObject forKey:aKey];
            }
        }

        return self;
    }

    -(instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
        self = [self init];

        if(self) {
            [self addEntriesFromDictionary:otherDictionary];
        }

        return self;
    }

    -(instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
        self = [self init];

        if(self) {
            [self addEntriesFromDictionary:otherDictionary copyItems:flag];
        }

        return self;
    }

    -(instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
        self = [self init];

        if(self) {
            if(objects.count == keys.count) {
                for(NSUInteger i = 0, j = objects.count; i < j; i++) [self _setObject:objects[i] forKey:keys[i]];
            }
            else {
                NSString *r = PGFormat(@"objects and keys arrays do not have the same number of items: %lu != %lu", objects.count, keys.count);
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:r];
            }
        }
        return self;
    }

    -(instancetype)initWithContentsOfFile:(NSString *)path {
        return (self = [self initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:path]]);
    }

    -(instancetype)initWithContentsOfURL:(NSURL *)url {
        return (self = [self initWithDictionary:[NSDictionary dictionaryWithContentsOfURL:url]]);
    }

    -(void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
        for(id<NSCopying> aKey in otherDictionary.keyEnumerator) {
            [self _setObject:otherDictionary[aKey] forKey:aKey];
        }
    }

    -(void)addEntriesFromDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
        if(flag) {
            [self addEntriesFromDictionary:otherDictionary];
        }
        else {
            for(id<NSCopying> aKey in otherDictionary.keyEnumerator) {
                [self _setObject:[otherDictionary[aKey] copy] forKey:aKey];
            }
        }
    }

    -(void)removeObjectForKey:(id)aKey {
        if(_rootNode) {
            PGRedBlackNode *node = [_rootNode findNodeWithKey:aKey];
            if(node) _rootNode = node.delete;
        }
    }

    -(void)_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
        if(_rootNode) {
            _rootNode = [_rootNode insertValue:anObject forKey:aKey].rootNode;
        }
        else {
            _rootNode = [[PGRedBlackNode alloc] initWithValue:anObject forKey:aKey];
            _rootNode.isRed = NO;
        }
    }

    -(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
        [self _setObject:anObject forKey:aKey];
    }

    -(void)removeAllObjects {
        if(_rootNode) {
            [_rootNode clearTree];
            _rootNode = nil;
        }
    }

    -(NSUInteger)count {
        return _rootNode.count;
    }

    -(id)objectForKey:(id)aKey {
        return [_rootNode findNodeWithKey:aKey].value;
    }

    -(NSEnumerator<id> *)keyEnumerator {
        return [[PGKeyBinaryTreeKeyEnumerator alloc] initWithOwner:self rootNode:_rootNode];
    }

    -(void)dealloc {
        [self removeAllObjects];
    }

@end

@implementation PGKeyBinaryTreeKeyEnumerator {
        NSMutableArray<PGRedBlackNode *> *_stack;
    }

    @synthesize owner = _owner;

    -(instancetype)initWithOwner:(id)owner rootNode:(PGRedBlackNode *)rootNode {
        self = [super init];

        if(self) {
            _owner = owner;
            _stack = [NSMutableArray arrayWithCapacity:10];

            for(PGRedBlackNode *node = rootNode; node != nil; node = node.leftChildNode) [_stack addObject:rootNode];
        }

        return self;
    }

    -(id)nextObject {
        PGRedBlackNode *nextNode = [_stack popLastObject];
        id             val       = nil;

        if(nextNode) {
            val = nextNode.value;
            for(PGRedBlackNode *node = nextNode.rightChildNode; node != nil; node = node.leftChildNode) [_stack addObject:node];
        }

        return val;
    }

@end

@implementation NSMutableDictionary(PGMutableBinaryTreeDictionary)

    +(instancetype)binaryTreeDictionary {
        return [[PGMutableBinaryTreeDictionary alloc] init];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

    +(instancetype)binaryTreeDictionaryWithObject:(id)anObject forKey:(id)aKey {
        return [[PGMutableBinaryTreeDictionary alloc] initWithObject:anObject forKey:aKey];
    }

    +(instancetype)binaryTreeDictionaryWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
        return [[PGMutableBinaryTreeDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }

#pragma clang diagnostic pop

    +(instancetype)binaryTreeDictionaryWithObjectsAndKeys:(id)firstObject, ... {
        NSMutableDictionary *dict = nil;
        va_list             args;
        va_start(args, firstObject);
        dict = [self binaryTreeDictionaryWithObjectsAndKeys:firstObject args:args];
        va_end(args);
        return dict;
    }

    +(instancetype)binaryTreeDictionaryWithObjectsAndKeys:(id)firstObject args:(va_list)args {
        PGMutableBinaryTreeDictionary *dict = (PGMutableBinaryTreeDictionary *)[self binaryTreeDictionary];
        NSUInteger                    i     = 1;

        for(id anObject = firstObject; anObject != nil; anObject = va_arg(args, id)) {
            id<NSCopying> aKey = va_arg(args, id);
            if(aKey == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(@"key #%lu is NULL.", i)];
            i++;
            [dict _setObject:anObject forKey:aKey];
        }

        return dict;
    }

    +(instancetype)binaryTreeDictionaryWithDictionary:(NSDictionary *)dict {
        return [[PGMutableBinaryTreeDictionary alloc] initWithDictionary:dict];
    }

    +(instancetype)binaryTreeDictionaryWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
        return [[PGMutableBinaryTreeDictionary alloc] initWithObjects:objects forKeys:keys];
    }

    +(instancetype)binaryTreeDictionaryWithContentsOfFile:(NSString *)path {
        return [[PGMutableBinaryTreeDictionary alloc] initWithContentsOfFile:path];
    }

    +(instancetype)binaryTreeDictionaryWithContentsOfURL:(NSURL *)url {
        return [[PGMutableBinaryTreeDictionary alloc] initWithContentsOfURL:url];
    }

@end
