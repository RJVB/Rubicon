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

typedef BOOL (^PGDynamicBufferOpBlock)(NSBytePtr buffer, NSUInteger size, NSUInteger *pHead, NSUInteger *pTail);

@interface PGDynamicByteQueue : NSObject<NSCopying>

    @property(nonatomic, readonly) NSUInteger head;
    @property(nonatomic, readonly) NSUInteger tail;
    @property(nonatomic, readonly) NSUInteger size;
    @property(nonatomic, readonly) NSUInteger count;
    @property(nonatomic, readonly) NSUInteger available;
    @property(nonatomic, readonly) BOOL       isEmtpy;
    @property(nonatomic, readonly) BOOL       isFull;
    @property(nonatomic, readonly) NSBytePtr  buffer;

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithBytesNoCopy:(NSBytePtr)bytes count:(NSUInteger)cnt length:(NSUInteger)len freeWhenDone:(BOOL)freeWhenDone NS_DESIGNATED_INITIALIZER;

    -(id)copyWithZone:(nullable NSZone *)zone;

    -(NSInteger)peekHead;

    -(NSInteger)peekTail;

    -(void)queue:(NSByte)byte;

    -(void)queue:(const NSBytePtr)bytes length:(NSUInteger)len;

    -(void)queue:(const NSBytePtr)bytes startingAt:(NSUInteger)index length:(NSUInteger)len;

    -(void)requeue:(NSByte)byte;

    -(void)requeue:(const NSBytePtr)bytes length:(NSUInteger)len;

    -(void)requeue:(const NSBytePtr)bytes startingAt:(NSUInteger)index length:(NSUInteger)len;

    -(NSInteger)dequeue;

    -(NSUInteger)dequeue:(NSBytePtr)buffer maxLength:(NSUInteger)len;

    -(BOOL)bulkOperationUsingBlock:(PGDynamicBufferOpBlock)opBlock restoreOnFailure:(BOOL)restoreOnFailure;

    -(BOOL)bulkOperationUsingBlock:(PGDynamicBufferOpBlock)opBlock;

    -(NSData *)data;

    -(void)push:(NSByte)byte;

    -(NSInteger)pop;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERS_H
