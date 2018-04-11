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

typedef NS_ENUM(NSByte, PGNormalizeType) {
    PGNormalizeNone = 0,  // Don't move the data.
    PGNormalizeBeginning, // Move the data to the beginning of the queue.
    PGNormalizeEnd        // Move the data to the end of the queue.
};

typedef BOOL (^PGDynamicBufferOpBlock)(NSBytePtr buffer, NSUInteger size, NSUInteger *pHead, NSUInteger *pTail);

@interface PGDynamicByteQueue : NSObject<NSCopying>

    @property(nonatomic, readonly) NSUInteger count;
    @property(nonatomic, readonly) BOOL       isEmtpy;

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithBytesNoCopy:(NSBytePtr)bytes count:(NSUInteger)cnt length:(NSUInteger)len freeWhenDone:(BOOL)freeWhenDone NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithNSData:(NSData *)data NS_DESIGNATED_INITIALIZER;

    -(NSBytePtr)copyBuffer:(NSUInteger *)cnt trim:(BOOL)trimFlag;

    -(NSInteger)dequeue;

    -(NSUInteger)dequeue:(NSBytePtr)buffer maxLength:(NSUInteger)len;

    -(NSInteger)pop;

    -(NSUInteger)pop:(NSBytePtr)buffer maxLength:(NSUInteger)len;

    -(void)queue:(NSByte)byte;

    -(void)queue:(NSBytePtr)buffer length:(NSUInteger)len;

    -(void)queueString:(NSString *)string;

    -(void)queueFromQueue:(PGDynamicByteQueue *)queue length:(NSUInteger)length;

    -(void)requeue:(NSByte)byte;

    -(void)requeue:(NSBytePtr)buffer length:(NSUInteger)len;

    -(void)requeueString:(NSString *)string;

    -(void)requeueFromQueue:(PGDynamicByteQueue *)queue length:(NSUInteger)length;

    -(NSData *)data;

    -(NSMutableData *)appendToData:(NSMutableData *)mdata;

    -(NSString *)string;

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock normalizeBefore:(PGNormalizeType)normalizeType restoreOnFailure:(BOOL)restoreOnFailure;

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock restoreOnFailure:(BOOL)restoreOnFailure;

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock;

    +(instancetype)queueWithInitialSize:(NSUInteger)initialSize;

    +(instancetype)queueWithBytesNoCopy:(NSBytePtr)bytes count:(NSUInteger)cnt length:(NSUInteger)len freeWhenDone:(BOOL)freeWhenDone;

    +(instancetype)queueWithNSData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERS_H
