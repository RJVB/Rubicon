/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGNestedEnumerator.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/20/17 3:16 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * "It can hardly be a coincidence that no language on Earth has ever produced the expression 'As pretty as an airport.' Airports
 * are ugly. Some are very ugly. Some attain a degree of ugliness that can only be the result of special effort."
 * - Douglas Adams from "The Long Dark Tea-Time of the Soul"
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "PGInternal.h"
#import "PGNestedEnumerator.h"

@implementation PGNestedEnumerator {
        id           _owner;
        NSEnumerator *_enumerator;
    }

    -(instancetype)initWithOwner:(id)owner andEnumerator:(NSEnumerator *)enumerator {
        self = [super init];

        if(self) {
            _owner      = (enumerator ? owner : nil);
            _enumerator = enumerator;
        }

        return self;
    }

    +(instancetype)enumeratorWithOwner:(id)owner andEnumerator:(NSEnumerator *)enumerator {
        return [[self alloc] initWithOwner:owner andEnumerator:enumerator];
    }

    -(id)nextObject {
        id item = nil;

        if(_enumerator) {
            item = [_enumerator nextObject];

            if(item == nil) {
                _owner      = nil;
                _enumerator = nil;
            }
        }

        return item;
    }

    -(NSArray *)allObjects {
        if(_enumerator) {
            NSArray *array = _enumerator.allObjects;
            _enumerator = nil;
            _owner      = nil;
            return array;
        }
        else {
            return [NSArray new];
        }
    }

    -(void)dealloc {
        _owner      = nil;
        _enumerator = nil;
    }

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {
        NSUInteger count = [_enumerator countByEnumeratingWithState:state objects:buffer count:len];
        if(count == 0) _owner = _enumerator = nil;
        return count;
    }

@end
