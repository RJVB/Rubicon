/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMImplementationList.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/12/18
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

@implementation PGDOMImplementationList {
    }

    @synthesize list = _list;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _list = [NSMutableArray new];
        }

        return self;
    }

    -(PGDOMImplementation *)objectAtIndexedSubscript:(NSUInteger)idx {
        return _list[idx];
    }

    -(void)setObject:(PGDOMImplementation *)obj atIndexedSubscript:(NSUInteger)idx {
        _list[idx] = obj;
    }

    -(nullable PGDOMImplementation *)item:(NSUInteger)idx {
        return ((idx < _list.count) ? _list[idx] : nil);
    }

    -(NSUInteger)count {
        return _list.count;
    }

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {
        return [_list countByEnumeratingWithState:state objects:buffer count:len];
    }

    +(PGDOMImplementationList *)instance {
        static NSMutableDictionary<NSString *, PGDOMImplementationList *> *_instanceMap = nil;

        @synchronized([PGDOMImplementationList class]) {
            NSString                *_className = NSStringFromClass([self class]);
            PGDOMImplementationList *_instance  = nil;

            if(_instanceMap == nil) _instanceMap = [[NSMutableDictionary alloc] initWithCapacity:5]; else _instance = _instanceMap[_className];
            if(_instance == nil) _instanceMap[_className] = _instance = [(PGDOMImplementationList *)[[self class] alloc] init];
            return _instance;
        }
    }

@end
