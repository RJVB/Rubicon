/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGStack.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/19/17 3:51 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved. *
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

#ifndef __Rubicon_PGStack_H_
#define __Rubicon_PGStack_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGStack<__covariant T> : NSObject<NSLocking, NSCopying>

    @property(atomic, readonly) NSUInteger count;
    @property(nonatomic, readonly) BOOL    isNotEmpty;

    -(instancetype)init;

    -(instancetype)initWithItem:(T)item;

    -(instancetype)initWithStack:(PGStack<T> *)stack;

    -(instancetype)initWithNSArray:(NSArray<T> *)array;

    -(nullable T)peek;

    -(nullable T)pop;

    -(void)push:(T)item;

    -(void)pushAllFromNSEnumerator:(NSEnumerator<T> *)enumerator;

    -(void)pushAllFromNSArray:(NSArray<T> *)array;

    -(void)pushAllFromStack:(PGStack<T> *)stack;

    -(void)clear;

    -(NSArray<T> *)popAll;

    -(NSArray<T> *)peekAll;

    -(id)copyWithZone:(nullable NSZone *)zone;

    -(BOOL)isEqual:(id)other;

    -(BOOL)isEqualToStack:(PGStack<T> *)stack;

    -(NSUInteger)hash;

    -(NSEnumerator<T> *)objectEnumerator;

    -(NSEnumerator<T> *)reverseObjectEnumerator;

@end

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGStack_H_
