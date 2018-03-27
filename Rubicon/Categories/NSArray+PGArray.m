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
 */

#import "PGInternal.h"

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

#define PGItem(idx)   ([self[idx] description])
#define PGRIdx(range) (range.location + range.length)
#define PGRLen(range) (self.count - range.location)

    -(NSString *)_componentsJoinedAsHarvardList:(NSString *)conjunction fromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx {
        /*
         * ASSUMPTION: All parameters have already been validated.
         */
        switch(toIdx - fromIdx) { // @f:0
            case 0:  return @"";
            case 1:  return [PGItem(fromIdx) copy];
            case 2:  return PGFormat(@"%@ %@ %@", PGItem(fromIdx), conjunction, PGItem(fromIdx + 1));
            default: return PGFormat(@"%@, %@ %@", [self _componentsJoinedByString:@", " fromIndex:fromIdx toIndex:toIdx - 1], conjunction, PGItem(toIdx - 1)); // @f:1
        }
    }

    -(NSString *)componentsJoinedAsHarvardList:(NSString *)conjunction fromIndex:(NSUInteger)fromIdx {
        return [self componentsJoinedAsHarvardList:conjunction fromIndex:fromIdx toIndex:self.count];
    }

    -(NSString *)componentsJoinedAsHarvardList:(NSString *)conjunction toIndex:(NSUInteger)toIdx {
        return [self componentsJoinedAsHarvardList:conjunction fromIndex:0 toIndex:toIdx];
    }

    -(NSString *)componentsJoinedAsHarvardList:(NSString *)conjunction fromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx {
        NSUInteger cc = self.count;
        if(fromIdx > cc) @throw [self invArgExc:PGFormat(@"Invalid starting index: %lu > %lu", fromIdx, cc)];
        if(toIdx > cc) @throw [self invArgExc:PGFormat(@"Invalid ending index: %lu > %lu", toIdx, cc)];
        if(toIdx < fromIdx) @throw [self invArgExc:PGFormat(@"Invalid ending index: %lu < %lu", toIdx, fromIdx)];
        return [self _componentsJoinedAsHarvardList:conjunction ? : @"and" fromIndex:fromIdx toIndex:toIdx];
    }

    -(NSString *)componentsJoinedAsHarvardList:(NSString *)conjunction inRange:(NSRange)range {
        if(range.location > self.count) @throw [self invArgExc:PGFormat(@"Invalid starting location: %lu > %lu", range.location, self.count)];
        if(PGRIdx(range) > self.count) @throw [self invArgExc:PGFormat(@"Invalid length: %lu > %lu", range.length, PGRLen(range))];
        return [self _componentsJoinedAsHarvardList:conjunction ? : @"and" fromIndex:range.location toIndex:PGRIdx(range)];
    }

    -(NSString *)componentsJoinedAsHarvardList:(NSString *)conjunction {
        return [self _componentsJoinedAsHarvardList:conjunction ? : @"and" fromIndex:0 toIndex:self.count];
    }

    -(NSString *)_componentsJoinedByString:(NSString *)string fromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx {
        /*
         * ASSUMPTION: All parameters have already been validated.
         */
        switch(toIdx - fromIdx) { // @f:0
            case 0: return @"";
            case 1: return [PGItem(fromIdx) copy];
            default:{
                NSMutableString *str = [NSMutableString stringWithString:PGItem(fromIdx++)];
                while(fromIdx < toIdx) {
                    [str appendString:string];
                    [str appendString:PGItem(fromIdx++)];
                }
                return str;
            } // @f:1
        }
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator fromIndex:(NSUInteger)fromIdx {
        return [self componentsJoinedByString:separator fromIndex:fromIdx toIndex:self.count];
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator toIndex:(NSUInteger)toIdx {
        return [self componentsJoinedByString:separator fromIndex:0 toIndex:toIdx];
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator fromIndex:(NSUInteger)fromIdx toIndex:(NSUInteger)toIdx {
        NSUInteger cc = self.count;
        if(fromIdx > cc) @throw [self invArgExc:PGFormat(@"Invalid starting index: %lu > %lu", fromIdx, cc)];
        if(toIdx < fromIdx) @throw [self invArgExc:PGFormat(@"Invalid ending index: %lu < %lu", toIdx, fromIdx)];
        if(toIdx > cc) @throw [self invArgExc:PGFormat(@"Invalid ending index: %lu > %lu", toIdx, cc)];
        return [self _componentsJoinedByString:separator ? : @"" fromIndex:fromIdx toIndex:toIdx];
    }

    -(NSString *)componentsJoinedByString:(NSString *)separator inRange:(NSRange)range {
        if(range.location > self.count) @throw [self invArgExc:PGFormat(@"Invalid starting location: %lu > %lu", range.location, self.count)];
        if(PGRIdx(range) > self.count) @throw [self invArgExc:PGFormat(@"Invalid length: %lu > %lu", range.length, PGRLen(range))];
        return [self _componentsJoinedByString:separator ? : @"" fromIndex:range.location toIndex:PGRIdx(range)];
    }

    -(NSException *)invArgExc:(NSString *)reason {
        return [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }

    -(NSArray *)arrayWithContentsReversed {
        NSUInteger i = self.count;
        switch(i) { // @f:0
            case 0: return @[];
            case 1: return @[ self[0] ];
            case 2: return @[ self[1], self[0] ];
            case 3: return @[ self[2], self[1], self[0] ];
            case 4: return @[ self[3], self[2], self[1], self[0] ];
            case 5: return @[ self[4], self[3], self[2], self[1], self[0] ];
            default: {
                NSMutableArray *ar = [NSMutableArray arrayWithCapacity:i];
                do { [ar addObject:self[--i]]; } while(i > 0);
                return ar;
            } // @f:1
        }
    }

@end

@implementation NSMutableArray(PGMutableArray)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

    -(BOOL)replaceObjectIdenticalTo:(NSObject *)oldObject withObject:(NSObject *)newObject {
        if(oldObject == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"\"oldObject\" is nil." userInfo:nil];
        if(newObject == nil) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"\"newObject\" is nil." userInfo:nil];

        NSUInteger index = [self indexOfObjectIdenticalTo:oldObject];
        BOOL       found = (index != NSNotFound);

        if(found) self[index] = newObject;
        return found;
    }

    -(id)popLastObject {
        id lo = nil;

        if(self.count) {
            lo = self.lastObject;
            [self removeLastObject];
        }

        return lo;
    }

#pragma clang diagnostic pop

@end
