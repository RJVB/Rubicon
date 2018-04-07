/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDynamicBuffers.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/5/18
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

#import "PGInternal.h"

NS_INLINE NSVoidPtr PGRealloc(NSVoidPtr _ptr, size_t _cnt, size_t _sz) {
    size_t    nsz  = (_cnt * _sz);
    NSVoidPtr nptr = (_ptr ? realloc(_ptr, nsz) : malloc(nsz));
    if(nptr) return nptr;
    else @throw [NSException exceptionWithName:NSMallocException reason:@"Out of memory"];
}

NS_INLINE NSUInteger nextIdx(NSUInteger idx, NSUInteger sz) {
    return ((idx + 1) % sz);
}

NS_INLINE NSUInteger prevIdx(NSUInteger idx, NSUInteger sz) {
    return ((idx ?: sz) - 1);
}

@interface PGDynamicByteQueue()

    @property(nonatomic) /*     */ NSUInteger head;
    @property(nonatomic) /*     */ NSUInteger tail;
    @property(nonatomic) /*     */ NSUInteger size;
    @property(nonatomic) /*     */ NSBytePtr  buffer;
    @property(nonatomic, readonly) NSUInteger realSize;

    -(NSUInteger)growBuffer;

@end

@implementation PGDynamicByteQueue {
    }

    @synthesize head = _head;
    @synthesize tail = _tail;
    @synthesize size = _size;
    @synthesize buffer = _buffer;

    -(instancetype)init {
        return (self = [self initWithInitialSize:0]);
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];

        if(self) {
            NSUInteger is = (initialSize ?: (64 * 1024));
            _size   = (is - 1);
            _head   = 0;
            _tail   = 0;
            _buffer = PGRealloc(NULL, is, sizeof(NSByte));
        }

        return self;
    }

    -(NSUInteger)realSize {
        return (self.size + 1);
    }

    -(NSUInteger)count {
        NSUInteger h = self.head;
        NSUInteger t = self.tail;
        return ((h <= t) ? (t - h) : ((self.realSize - h) + t));
    }

    -(NSUInteger)available {
        return (self.size - self.count);
    }

    -(BOOL)isEmtpy {
        return (self.head == self.tail);
    }

    -(BOOL)isFull {
        return (self.head == nextIdx(self.tail, self.realSize));
    }

    -(void)dealloc {
        if(_buffer) {
            free(_buffer);
            _buffer = NULL;
        }
        _head = _tail = _size = 0;
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        PGDynamicByteQueue *copy = [((PGDynamicByteQueue *)[[self class] allocWithZone:zone]) init];

        if(copy) {
            NSUInteger rsz = self.realSize;
            NSBytePtr  cb  = PGRealloc(NULL, rsz, sizeof(NSByte));
            NSBytePtr  b   = self.buffer;
            NSUInteger h   = self.head;
            NSUInteger t   = self.tail;
            NSUInteger ct  = (((h <= t) ? t : rsz) - h);

            if(ct) {
                memcpy(cb, (b + h), ct);

                if((t < h) && (t > 0)) {
                    memcpy(cb + ct, b, t);
                    ct += t;
                }
            }

            copy.buffer = cb;
            copy.head   = 0;
            copy.tail   = ct;
            copy.size   = self.size;
        }

        return copy;
    }

    -(NSUInteger)growBuffer {
        NSUInteger oldSize = self.realSize;
        NSUInteger newSize = (oldSize * 2);
        NSBytePtr  newBuff = PGRealloc(self.buffer, newSize, sizeof(NSByte));
        NSUInteger tail    = self.tail;

        if(tail < self.head) {
            if(tail) memcpy(newBuff + oldSize, newBuff, tail);
            self.tail = (tail + oldSize);
        }

        self.size   = (newSize - 1);
        self.buffer = newBuff;
        return self.tail;
    }

    -(NSInteger)peekHead {
        NSUInteger head = self.head;
        return ((head == self.tail) ? (-1) : ((NSInteger)self.buffer[head]));
    }

    -(NSInteger)peekTail {
        NSUInteger tail = self.tail;
        return ((self.head == self.tail) ? (-1) : ((NSInteger)self.buffer[prevIdx(tail, self.realSize)]));
    }

    -(void)queue:(NSByte)byte {
        NSUInteger tail = self.tail;

        if(self.head == nextIdx(tail, self.realSize)) tail = [self growBuffer];
        self.buffer[tail] = byte;
        self.tail = nextIdx(tail, self.realSize);
    }

    -(void)queue:(const NSBytePtr)bytes length:(NSUInteger)len {
        [self queue:bytes startingAt:0 length:len];
    }

    -(void)queue:(const NSBytePtr)bytes startingAt:(NSUInteger)index length:(NSUInteger)len {
        if(len) {
            if(bytes) {
                for(NSUInteger i = 0, j = index; i < len; i++) [self queue:bytes[j++]];
            }
            else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"bytes is NULL."];
            }
        }
    }

    -(void)requeue:(NSByte)byte {
        NSUInteger head = prevIdx(self.head, self.realSize);

        if(head == self.tail) {
            [self growBuffer];
            head = prevIdx(self.head, self.realSize);
        }

        self.buffer[head] = byte;
        self.head = head;
    }

    -(void)requeue:(const NSBytePtr)bytes length:(NSUInteger)len {
        [self requeue:bytes startingAt:0 length:len];
    }

    -(void)requeue:(const NSBytePtr)bytes startingAt:(NSUInteger)index length:(NSUInteger)len {
        if(len) {
            if(bytes) {
                for(NSUInteger i = 0, j = (index + len); i < len; i++) [self requeue:bytes[--j]];
            }
            else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"bytes is NULL."];
            }
        }
    }

    -(void)push:(NSByte)byte {
        [self queue:byte];
    }

    -(NSInteger)dequeue {
        NSUInteger head = self.head;
        if(head == self.tail) return -1;
        self.head = nextIdx(head, self.realSize);
        return (NSInteger)self.buffer[head];
    }

    -(NSInteger)pop {
        NSUInteger tail = self.tail;
        if(self.head == tail) return -1;
        self.tail = tail = prevIdx(tail, self.realSize);
        return self.buffer[tail];
    }

    -(NSUInteger)dequeue:(NSBytePtr)buffer maxLength:(NSUInteger)len {
        NSUInteger cnt  = 0;
        NSUInteger head = self.head;
        NSUInteger tail = self.tail;
        NSUInteger size = self.realSize;
        NSBytePtr  buff = self.buffer;

        while((head != tail) && (cnt < len)) {
            buffer[cnt++] = buff[head];
            head = ((head + 1) % size);
        }

        self.head = head;
        return cnt;
    }

    -(BOOL)bulkOperationUsingBlock:(PGDynamicBufferOpBlock)opBlock restoreOnFailure:(BOOL)restoreOnFailure {
        BOOL success = NO;

        if(opBlock) {
            NSUInteger head = self.head;
            NSUInteger tail = self.tail;

            if(restoreOnFailure) {
                NSBytePtr workBuffer = PGRealloc(NULL, self.realSize, sizeof(NSByte));
                memcpy(workBuffer, self.buffer, self.realSize);

                @try {
                    success = opBlock(self.buffer, self.realSize, &head, &tail);
                }
                @finally {
                    if(success) {
                        self.head = head;
                        self.tail = tail;
                        free(workBuffer);
                    }
                    else {
                        free(self.buffer);
                        self.buffer = workBuffer;
                    }
                }
            }
            else {
                success = opBlock(self.buffer, self.realSize, &head, &tail);
                self.head = head;
                self.tail = tail;
            }
        }

        return success;
    }

    -(BOOL)bulkOperationUsingBlock:(PGDynamicBufferOpBlock)opBlock {
        return [self bulkOperationUsingBlock:opBlock restoreOnFailure:NO];
    }

    -(NSData *)data {
        NSUInteger count = self.count;

        if(count) {
            NSBytePtr  buf  = PGRealloc(NULL, count, sizeof(NSByte));
            NSBytePtr  obuf = self.buffer;
            NSUInteger head = self.head;
            NSUInteger tail = self.tail;
            NSUInteger top  = (((head <= tail) ? tail : self.realSize) - head);

            memcpy(buf, (obuf + head), top);

            if((head > tail) && (tail > 0)) {
                memcpy((buf + top), obuf, tail);
                top += tail;
            }

            return [[NSData alloc] initWithBytesNoCopy:buf length:top freeWhenDone:YES];
        }
        else {
            return [NSData new];
        }
    }

@end
