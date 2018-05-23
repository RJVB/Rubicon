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
FOUNDATION_EXPORT const NSUInteger PGDynByteQueueMinSize;

typedef NSInteger (^PGDynamicByteBufferOpBlock)(NSByte *buffer, NSUInteger size, NSUInteger *pHead, NSUInteger *pTail, NSError **error);

@interface PGDynamicByteQueue : NSObject<NSCopying>

    @property(readonly) NSUInteger count;
    @property(readonly) BOOL       isEmpty;
    @property /*     */ BOOL       willShrink;

    -(instancetype)init NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithNSData:(NSData *)nsData;

    -(instancetype)initWithBytes:(NSByte *)bytes length:(NSUInteger)length;

    -(void)dealloc;

    -(BOOL)isEqual:(id)other;

    -(BOOL)isEqualToQueue:(PGDynamicByteQueue *)other;

    -(NSUInteger)hash;

    -(void)queue:(NSByte)byte;

    -(void)queue:(NSByte *)buffer length:(NSUInteger)length;

    -(void)requeue:(NSByte)byte;

    -(void)requeue:(NSByte *)buffer length:(NSUInteger)length;

    -(NSInteger)dequeue;

    -(NSInteger)unqueue;

    -(NSUInteger)dequeue:(NSByte *)buffer maxLength:(NSUInteger)length;

    -(NSUInteger)unqueue:(NSByte *)buffer maxLength:(NSUInteger)length;

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock restoreOnExceptionOrError:(BOOL)restoreFlag error:(NSError **)error;

    -(NSData *)getNSData;

    -(NSData *)getNSData:(NSUInteger)length;

    -(NSString *)getNSString:(NSStringEncoding)encoding;

    -(char *)getUTF8String:(NSUInteger)length;

    -(NSString *)getNSString:(NSUInteger)length encoding:(NSStringEncoding)encoding;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERS_H
