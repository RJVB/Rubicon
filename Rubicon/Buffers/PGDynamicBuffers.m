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
    @property(nonatomic, readonly) BOOL       freeWhenDone;
    @property(nonatomic, readonly) NSUInteger realSize;

    -(NSBytePtr)copyBuffer:(BOOL)trim count:(NSUInteger *)cnt size:(NSUInteger *)size;

    -(NSUInteger)growBuffer;

@end

@implementation PGDynamicByteQueue {
    }

    @synthesize head = _head;
    @synthesize tail = _tail;
    @synthesize size = _size;
    @synthesize buffer = _buffer;
    @synthesize freeWhenDone = _freeWhenDone;

    -(instancetype)init {
        return (self = [self initWithInitialSize:0]);
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];

        if(self) {
            NSUInteger is = (initialSize ?: (64 * 1024));
            _size         = (is - 1);
            _head         = 0;
            _tail         = 0;
            _buffer       = PGRealloc(NULL, is, sizeof(NSByte));
            _freeWhenDone = YES;
        }

        return self;
    }

    -(instancetype)initWithBytesNoCopy:(NSBytePtr)bytes count:(NSUInteger)cnt length:(NSUInteger)len freeWhenDone:(BOOL)freeWhenDone {
        self = [super init];

        if(self) {
            _size         = (len - 1);
            _head         = 0;
            _tail         = cnt;
            _buffer       = bytes;
            _freeWhenDone = freeWhenDone;
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
        if(self.freeWhenDone && self.buffer) {
            free(self.buffer);
            self.buffer = NULL;
        }
        self.head = self.tail = self.size = 0;
    }

    -(NSBytePtr)copyBuffer:(BOOL)trim count:(NSUInteger *)cnt size:(NSUInteger *)size {
        NSBytePtr  buf   = NULL;
        NSUInteger count = self.count;
        NSUInteger rsize = self.realSize;

        if(count || !trim) {
            buf = PGRealloc(NULL, (trim ? count : rsize), sizeof(NSByte));

            if(count) {
                NSBytePtr  obuf   = self.buffer;
                NSUInteger head   = self.head;
                NSUInteger tail   = self.tail;
                BOOL       normal = (head <= tail);
                NSUInteger top    = ((normal ? tail : rsize) - head);

                memcpy(buf, (obuf + head), top);
                if(tail && !normal) memcpy((buf + top), obuf, tail);
            }
        }

        if(size) *size = rsize;
        if(cnt) *cnt   = count;
        return buf;
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        NSUInteger         count = 0;
        NSUInteger         size  = 0;
        NSBytePtr          buf   = [self copyBuffer:NO count:&count size:&size];
        PGDynamicByteQueue *copy = [((PGDynamicByteQueue *)[[self class] allocWithZone:zone]) initWithBytesNoCopy:buf count:count length:size freeWhenDone:YES];

        if(!copy) free(buf);
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
        return ((head == self.tail) ? (EOF) : ((NSInteger)self.buffer[head]));
    }

    -(NSInteger)peekTail {
        NSUInteger tail = self.tail;
        return ((self.head == tail) ? (EOF) : ((NSInteger)self.buffer[prevIdx(tail, self.realSize)]));
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
        if(head == self.tail) return EOF;
        self.head = nextIdx(head, self.realSize);
        return (NSInteger)self.buffer[head];
    }

    -(NSInteger)pop {
        NSUInteger tail = self.tail;
        if(self.head == tail) return EOF;
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
        NSUInteger length = 0;
        NSBytePtr  cpybuf = [self copyBuffer:YES count:&length size:NULL];
        return (length ? [[NSData alloc] initWithBytesNoCopy:cpybuf length:length freeWhenDone:YES] : [NSData new]);
    }

@end
