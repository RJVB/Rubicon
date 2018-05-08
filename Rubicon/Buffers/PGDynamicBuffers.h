/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDynamicBuffers.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/5/18
 *  VISIBILITY: Private
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

#ifndef RUBICON_PGDYNAMICBUFFERS_H
#define RUBICON_PGDYNAMICBUFFERS_H

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const NSUInteger PGDynByteQueueDefaultInitialSize;

typedef NSInteger (^PGDynamicByteBufferOpBlock)(NSBytePtr buffer, NSUInteger size, NSUInteger *pHead, NSUInteger *pTail, NSError **error);

@interface PGDynamicByteQueue : NSObject<NSCopying, NSLocking>

    @property(readonly) NSUInteger count;
    @property(readonly) BOOL       isEmpty;

    -(instancetype)init NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize NS_DESIGNATED_INITIALIZER;

    -(BOOL)isEqualToQueue:(PGDynamicByteQueue *)other;

    -(void)queue:(NSByte)byte;

    -(void)queue:(const NSBytePtr)buffer offset:(NSUInteger)offset length:(NSUInteger)length;

    -(void)queue:(const NSBytePtr)buffer length:(NSUInteger)length;

    -(void)requeue:(NSByte)byte;

    -(void)requeue:(const NSBytePtr)buffer offset:(NSUInteger)offset length:(NSUInteger)length;

    -(void)requeue:(const NSBytePtr)buffer length:(NSUInteger)length;

    -(NSInteger)dequeue;

    -(NSInteger)unqueue;

    -(NSInteger)dequeue:(NSBytePtr)buffer maxLength:(NSUInteger)length;

    -(NSInteger)unqueue:(NSBytePtr)buffer maxLength:(NSUInteger)length;

    -(void)normalize;

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock restoreOnExceptionOrError:(BOOL)restoreFlag error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERS_H
