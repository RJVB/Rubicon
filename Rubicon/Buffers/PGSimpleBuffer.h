/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSimpleBuffer.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
 *       NOTES: If you are working in a multi-threaded environment then it is advisable to lock this object before reading
 *              or writing to the byte buffer returned by the "buffer" property and then unlock it when done. The methods
 *              hash, isEqual:, isEqualToBuffer:, copy, copyWithZone:, and growBufferBy: automatically lock and unlock this
 *              object when called. Below is an example of locking and unlocking.
 *
 *              PGSimpleBuffer *buffer = [PGSimpleBuffer bufferWithLength:1024];
 *
 *              [buffer lock];
 *              @try {
 *                  void *bytes = buffer.buffer;
 *                  <write to the byte buffer>
 *              }
 *              @finally { [buffer unlock]; }
 *
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

#ifndef RUBICON_PGSIMPLEBUFFER_H
#define RUBICON_PGSIMPLEBUFFER_H

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGSimpleBuffer : NSObject<NSCopying, NSLocking>

    @property(readonly) voidp      buffer;
    @property(readonly) NSUInteger length;

    -(instancetype)initWithLength:(NSUInteger)length;

    -(instancetype)initWithBytes:(voidp)bytes length:(NSUInteger)length;

    -(BOOL)isEqualToBuffer:(PGSimpleBuffer *)other;

    -(BOOL)isEqual:(id)other;

    -(NSUInteger)hash;

    -(id)copyWithZone:(nullable NSZone *)zone;

    -(void)zeroBuffer;

    -(void)fillBuffer:(uint8_t)value;

    -(void)rotateByCount:(NSInteger)count;

    -(void)postDataChangedNotification;

    -(NSUInteger)getBytes:(void **)buffer maxLength:(NSUInteger)length;

    -(void)setBufferLength:(NSUInteger)newLength;

    -(void)setBuffer:(voidp)buffer length:(NSUInteger)length;

    +(instancetype)bufferWithLength:(NSUInteger)length;

    +(instancetype)bufferWithBytes:(voidp)bytes length:(NSUInteger)length;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGSIMPLEBUFFER_H
