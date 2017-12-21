/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGQueue.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/20/17 11:11 AM
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

#ifndef __Rubicon_PGQueue_H_
#define __Rubicon_PGQueue_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGQueue<__covariant T> : NSObject<NSLocking, NSCopying, NSFastEnumeration>

    @property(atomic, readonly) NSUInteger count;

    -(instancetype)init;

    -(instancetype)initWithItem:(T)item;

    -(instancetype)initWithNSArray:(NSArray<T> *)array;

    -(instancetype)initWithQueue:(PGQueue<T> *)queue;

    -(void)queue:(T)item;

    -(void)requeue:(T)item;

    -(nullable T)peekQueue;

    -(nullable T)dequeue;

    -(void)queueAllFromEnumerator:(NSEnumerator<T> *)enumerator;

    -(void)queueAllFromNSArray:(NSArray<T> *)array;

    -(void)queueAllFromQueue:(PGQueue<T> *)queue;

    -(NSArray<T> *)dequeueAll;

    -(NSArray<T> *)peekQueueAll;

    -(NSEnumerator<T> *)objectEnumerator;

    -(NSEnumerator<T> *)reverseObjectEnumerator;

    -(void)clear;

    -(id)copyWithZone:(nullable NSZone *)zone;

    -(BOOL)isEqual:(id)other;

    -(BOOL)isEqualToQueue:(PGQueue<T> *)queue;

    -(NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGQueue_H_
