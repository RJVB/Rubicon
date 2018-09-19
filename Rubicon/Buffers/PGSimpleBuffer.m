/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSimpleBuffer.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
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

#import "PGSimpleBuffer.h"
#import "NSException+PGException.h"

#define PGThrowZeroBufferLengthException @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGErrorMsgZeroLengthBuffer]

BOOL rotateBuffer(uint8_t *buffer, BOOL left, NSUInteger delta, NSUInteger length);

@implementation PGSimpleBuffer {
        NSRecursiveLock *_lock;
    }

    @synthesize buffer = _buffer;
    @synthesize length = _length;

    -(instancetype)initWithLength:(NSUInteger)length {
        self = [super init];

        if(self) {
            if(!length) PGThrowZeroBufferLengthException;
            _length = length;
            _buffer = PGMalloc(_length);
        }

        return self;
    }

    -(instancetype)initWithBytes:(voidp)bytes length:(NSUInteger)length {
        self = [self initWithLength:length];

        if(self) {
            if(bytes) {
                memcpy(_buffer, bytes, length);
            }
            else {
                [self freeBuffer];
                PGThrowNullPointerException;
            }
        }

        return self;
    }

    +(instancetype)bufferWithLength:(NSUInteger)length {
        return [[self alloc] initWithLength:length];
    }

    +(instancetype)bufferWithBytes:(voidp)bytes length:(NSUInteger)length {
        return [[self alloc] initWithBytes:bytes length:length];
    }

    -(BOOL)_setBufferLength:(NSUInteger)length {
        BOOL change = (length != _length);

        if(change) {
            /*
             * If an insufficient-memory exception is thrown then nothing is changed.
             */
            _buffer = PGRealloc(_buffer, length);
            _length = length;
        }

        return change;
    }

    -(BOOL)__setBufferLength:(NSUInteger)length {
        [self lock];
        @try { return [self _setBufferLength:length]; } @finally { [self unlock]; }
    }

    -(void)setBufferLength:(NSUInteger)length {
        if(!length) PGThrowZeroBufferLengthException;
        if([self __setBufferLength:length]) [self postDataChangedNotification];
    }

    -(BOOL)_setBuffer:(const void *)buffer {
        BOOL change = (_buffer != buffer);
        if(change) memmove(_buffer, buffer, _length);
        return change;
    }

    -(BOOL)_setBuffer:(const void *)buffer length:(NSUInteger)length {
        [self lock];
        @try {
            BOOL change = [self _setBufferLength:length];
            return ([self _setBuffer:buffer] || change);
        }
        @finally { [self unlock]; }
    }

    -(void)setBuffer:(voidp)buffer length:(NSUInteger)length {
        if(!length) PGThrowZeroBufferLengthException;
        if(!buffer) PGThrowNullPointerException;
        if([self _setBuffer:buffer length:length]) [self postDataChangedNotification];
    }

    -(void)freeBuffer {
        if(_buffer) free(_buffer);
        _buffer = NULL;
        _length = 0;
    }

    -(void)dealloc {
        [[NSNotificationCenter defaultCenter] postNotificationName:PGSimpleBufferDeallocNotification object:self];
        [self freeBuffer];
    }

    -(BOOL)_isEqualToBuffer:(PGSimpleBuffer *)buffer {
        [self lock];
        [buffer lock];
        @try {
            return ((_length == buffer.length) && (memcmp(_buffer, buffer.buffer, _length) == 0));
        }
        @finally {
            [buffer unlock];
            [self unlock];
        }
    }

    -(BOOL)isEqualToBuffer:(PGSimpleBuffer *)buffer {
        return (buffer && ((self == buffer) || [self _isEqualToBuffer:buffer]));
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self _isEqualToBuffer:other])));
    }

    -(NSUInteger)hash {
        [self lock];
        @try { return PGHash(_buffer, _length); } @finally { [self unlock]; }
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        PGSimpleBuffer *copy = nil;
        [self lock];
        @try { copy = [((PGSimpleBuffer *)[[self class] allocWithZone:zone]) initWithBytes:_buffer length:_length]; } @finally { [self unlock]; }
        return copy;
    }

    -(void)lock {
        PGSETIFNIL(self, self->_lock, [NSRecursiveLock new]);
        [_lock lock];
    }

    -(void)unlock {
        [_lock unlock];
    }

    -(void)zeroBuffer {
        [self fillBuffer:0];
    }

    -(void)fillBuffer:(uint8_t)value {
        [self lock];
        @try { memset(_buffer, value, _length); } @finally { [self unlock]; }
        [self postDataChangedNotification];
    }

    -(void)rotateByCount:(NSInteger)count {
        if(count) {
            BOOL change;
            [self lock];
            @try { change = rotateBuffer(_buffer, (count < 0), ((NSUInteger)(labs(count)) % _length), _length); } @finally { [self unlock]; }
            if(change) [self postDataChangedNotification];
        }
    }

    -(void)postDataChangedNotification {
        [[NSNotificationCenter defaultCenter] postNotificationName:PGSimpleBufferDataChangedNotification object:self];
    }

    -(NSUInteger)getBytes:(void **)buffer maxLength:(NSUInteger)length {
        if(buffer) {
            [self lock];
            @try {
                uint8_t    *tmpbuf = *buffer;
                NSUInteger buflen  = MIN(_length, length);

                if(!tmpbuf) (*buffer) = tmpbuf = PGMalloc(buflen);
                memmove(tmpbuf, _buffer, buflen);
                return buflen;
            }
            @finally { [self unlock]; }
        }

        PGThrowNullPointerException;
    }

@end

BOOL rotateBuffer2L(uint8_t *tmpbuf, uint8_t *buffer, NSUInteger delta, NSUInteger offset) {
    memcpy(tmpbuf, buffer, delta);
    memmove(buffer, (buffer + delta), offset);
    memcpy((buffer + offset), tmpbuf, delta);
    return YES;
}

BOOL rotateBuffer2R(uint8_t *tmpbuf, uint8_t *buffer, NSUInteger delta, NSUInteger offset) {
    memcpy(tmpbuf, (buffer + offset), delta);
    memmove((buffer + delta), buffer, offset);
    memcpy(buffer, tmpbuf, delta);
    return YES;
}

BOOL rotateBuffer1L(uint8_t *buffer, NSUInteger offset) {
    uint8_t tmpbuf = buffer[0];
    memmove(buffer, (buffer + 1), offset);
    buffer[offset] = tmpbuf;
    return YES;
}

BOOL rotateBuffer1R(uint8_t *buffer, NSUInteger offset) {
    uint8_t tmpbuf = buffer[offset];
    memmove((buffer + 1), buffer, offset);
    buffer[0] = tmpbuf;
    return YES;
}

NS_INLINE BOOL rotateBuffer2(uint8_t *tmpbuf, uint8_t *buffer, BOOL left, NSUInteger delta, NSUInteger offset) {
    @try { return ((left ? rotateBuffer2L : rotateBuffer2R)(tmpbuf, buffer, delta, offset)); } @finally { free(tmpbuf); }
}

NS_INLINE BOOL rotateBuffer1(uint8_t *buffer, BOOL left, NSUInteger offset) {
    return ((left ? rotateBuffer1L : rotateBuffer1R)(buffer, offset));
}

NS_INLINE BOOL rotateMultiElementBuffer(uint8_t *buffer, BOOL left, NSUInteger delta, NSUInteger offset) {
    return (((delta == 1) && rotateBuffer1(buffer, left, offset)) || rotateBuffer2(PGMalloc(delta), buffer, left, delta, offset));
}

NS_INLINE BOOL rotateTwoElementBuffer(uint8_t *buffer) {
    uint8_t tmpbuf = buffer[0];
    buffer[0] = buffer[1];
    buffer[1] = tmpbuf;
    return YES;
}

BOOL rotateBuffer(uint8_t *buffer, BOOL left, NSUInteger delta, NSUInteger length) {
    return ((delta > 0) && (((length == 2) && rotateTwoElementBuffer(buffer)) || ((length > 2) && rotateMultiElementBuffer(buffer, left, delta, (length - delta)))));
}

