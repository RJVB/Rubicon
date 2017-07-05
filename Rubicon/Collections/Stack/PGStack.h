/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGStack.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/4/17 9:44 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017  Project Galen. All rights reserved.
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

#ifndef __Rubicon_PGStack_H_
#define __Rubicon_PGStack_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGStack<__covariant T> : NSObject

    @property(readonly) NSUInteger count;
    @property(readonly) BOOL       isEmpty;

    -(instancetype)init;

    -(instancetype)initWithNSArray:(NSArray<T> *)objs;

    -(instancetype)initWithObjects:(const T _Nonnull[_Nullable])objects count:(NSUInteger)cnt;

    -(void)push:(T)obj;

    -(nullable T)pop;

    -(nullable T)peek;

    -(NSArray<T> *)popAll;

    -(NSArray<T> *)peekAll;

    -(void)pushAll:(NSArray<T> *)objs;

    -(void)pushAllObjects:(const T _Nonnull[_Nullable])objects count:(NSUInteger)cnt;

    -(void)removeAll;

    -(NSEnumerator<T> *)objectEnumerator;

    +(instancetype)stack;

    +(instancetype)stackWithArray:(NSArray<T> *)array;

    +(instancetype)stackWithObjects:(const T _Nonnull[_Nullable])objects count:(NSUInteger)cnt;

@end

NS_ASSUME_NONNULL_END
#endif //__Rubicon_PGStack_H_
