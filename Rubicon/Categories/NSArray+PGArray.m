/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSArray(PGArray).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/10/17 3:45 PM
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
 *********************************************************************************************************************************/

#import "NSArray+PGArray.h"

@implementation NSArray(PGArray)

    -(BOOL)containsIdenticalObjectsOutOfOrderAsArray:(NSArray<id> *)array {
        if(array) {
            if(array == self) return YES;

            NSUInteger c = self.count;

            if(array.count == c) {
                for(NSUInteger i = 0; i < c; i++) {
                    if([array indexOfObjectIdenticalTo:self[i]] == NSNotFound) return NO;
                }

                return YES;
            }
        }

        return NO;
    }

    -(BOOL)containsIdenticalObjectsAsArray:(NSArray<id> *)array {
        if(array) {
            if(array == self) return YES;

            NSUInteger i = array.count;
            NSUInteger j = self.count;

            if(i == j) {
                for(NSUInteger x = 0; x < j; x++) {
                    if(self[x] != array[x]) return NO;
                }

                return YES;
            }
        }

        return NO;
    }

    -(NSString *)_componentsJoinedByString:(NSString *)string fromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
        NSMutableString *str = [NSMutableString new];

        if(!string) string = @"";

        if(from < to) {
            [str appendString:self[from++]];
            while(from < to) {
                [str appendString:string];
                [str appendString:self[from++]];
            }
        }

        return str;
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator fromIndex:(NSUInteger)fromIdx {
        return [self _componentsJoinedByString:separator fromIndex:fromIdx toIndex:self.count];
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator toIndex:(NSUInteger)toIdx {
        return [self _componentsJoinedByString:separator fromIndex:0 toIndex:MIN(self.count, toIdx)];
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator fromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx {
        return [self _componentsJoinedByString:separator fromIndex:fromIdx toIndex:MIN(self.count, toIdx)];
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator inRange:(NSRange)range {
        return [self _componentsJoinedByString:separator fromIndex:range.location toIndex:(range.location + range.length)];
    }

    -(NSArray *)arrayWithContentsReversed {
        NSUInteger i = self.count;

        if(i) {
            NSMutableArray *ar = [NSMutableArray arrayWithCapacity:i];

            do {
                [ar addObject:self[--i]];
            } while(i > 0);

            return ar;
        }
        else {
            return @[];
        }
    }

@end
