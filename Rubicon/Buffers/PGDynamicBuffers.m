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

#define nextIdx(i, s) (((i) + 1) % (s))
#define prevIdx(i, s) (((i) ?: (s)) - 1)

@interface PGDynamicByteQueue()

    @property(nonatomic, readonly) BOOL       freeWhenDone;
    @property(nonatomic, readonly) BOOL       isFull;
    @property(nonatomic, readonly) NSUInteger capacity;

    -(void)relocateHead:(NSUInteger)newHead;

    -(void)normalizeQueue:(PGNormalizeType)norm;

    -(void)grow:(NSUInteger)needRoomFor normalize:(PGNormalizeType)norm;

    -(void)grow;

@end

@implementation PGDynamicByteQueue {
        NSBytePtr  byteQueue;
        NSUInteger head;
        NSUInteger tail;
        NSUInteger size;
    }

    @synthesize freeWhenDone = _freeWhenDone;

    -(instancetype)init {
        return (self = [self initWithInitialSize:0]);
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];

        if(self) {
            _freeWhenDone = YES;
            size          = (initialSize ?: (64 * 1024));
            head          = 0;
            tail          = 0;
            byteQueue     = PGRealloc(NULL, size);
        }

        return self;
    }

    -(instancetype)initWithBytesNoCopy:(NSBytePtr)bytes count:(NSUInteger)cnt length:(NSUInteger)len freeWhenDone:(BOOL)freeWhenDone {
        self = [super init];

        if(self) {
            _freeWhenDone = freeWhenDone;
            size          = len;
            head          = 0;
            tail          = cnt;
            byteQueue     = bytes;
        }

        return self;
    }

    -(instancetype)initWithNSData:(NSData *)data {
        self = [super init];

        if(self) {
            _freeWhenDone = YES;
            head          = 0;
            tail          = data.length;
            size          = MAX((64 * 1024), tail + 1);
            byteQueue = PGRealloc(NULL, size);
            if(tail) [data getBytes:byteQueue length:tail];
        }

        return self;
    }

    +(instancetype)queueWithInitialSize:(NSUInteger)initialSize {
        return [[self alloc] initWithInitialSize:initialSize];
    }

    +(instancetype)queueWithBytesNoCopy:(NSBytePtr)bytes count:(NSUInteger)cnt length:(NSUInteger)len freeWhenDone:(BOOL)freeWhenDone {
        return [[self alloc] initWithBytesNoCopy:bytes count:cnt length:len freeWhenDone:freeWhenDone];
    }

    +(instancetype)queueWithNSData:(NSData *)data {
        return [[self alloc] initWithNSData:data];
    }

    -(void)dealloc {
        if(self.freeWhenDone && (byteQueue != NULL)) free(byteQueue);
        size      = 0;
        head      = 0;
        tail      = 0;
        byteQueue = NULL;
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        NSUInteger count   = 0;
        NSBytePtr  bytePtr = [self copyBuffer:&count trim:NO];
        return [(PGDynamicByteQueue *)[[self class] allocWithZone:zone] initWithBytesNoCopy:bytePtr count:count length:size freeWhenDone:YES];
    }

#define queueCount ((head <= tail) ? (tail - head) : ((size - head) + tail))

    -(NSUInteger)count {
        return queueCount;
    }

    -(NSUInteger)capacity {
        return (size - queueCount - 1);
    }

    -(BOOL)isEmtpy {
        return (head == tail);
    }

    -(BOOL)isFull {
        return (head == nextIdx(tail, size));
    }

    -(void)relocateHead:(NSUInteger)newHead {
        // Don't bother if we're already in the correct position...
        if(newHead != head) {
            NSString *fmt = @"%@ value is greater than buffer size: %lu >= %lu";
            if(newHead >= size) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(fmt, @"Head", newHead, size)];

            BOOL       nowrap  = (head <= tail);
            NSUInteger top     = ((nowrap ? tail : size) - head);
            NSUInteger length  = (nowrap ? top : (top + tail));
            NSUInteger newTail = (newHead + length);

            if(newTail >= size) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(fmt, @"Tail", newTail, size)];
            }
            else if(length) {
                NSBytePtr p1 = (byteQueue + newHead);
                NSBytePtr p2 = (byteQueue + head);

                if(nowrap || (tail == 0)) {
                    memmove(p1, p2, length);
                }
                else {
                    NSBytePtr tbuf = PGRealloc(NULL, tail);
                    memcpy(tbuf, byteQueue, tail);
                    memmove(p1, p2, top);
                    memcpy((p1 + top), tbuf, tail);
                    free(tbuf);
                }
            }

            head = newHead;
            tail = newTail;
        }
    }

    -(void)normalizeQueue:(PGNormalizeType)norm {
        switch(norm) {
            case PGNormalizeBeginning: {
                [self relocateHead:0];
                break;
            }
            case PGNormalizeEnd: {
                [self relocateHead:self.capacity];
                break;
            }
            default: break; // Do nothing...
        }
    }

    -(void)grow:(NSUInteger)needRoomFor normalize:(PGNormalizeType)norm {
        NSUInteger newSize = (size * 2);
        NSUInteger cc      = (self.count + 1);

        while((newSize - cc) < needRoomFor) newSize *= 2;
        byteQueue = PGRealloc(byteQueue, newSize);

        if(tail < head) {
            if(tail) memcpy((byteQueue + size), byteQueue, tail);
            tail += size;
        }

        if(norm != PGNormalizeNone) [self normalizeQueue:norm];
        size = newSize;
    }

    -(void)grow {
        [self grow:1 normalize:PGNormalizeNone];
    }

    -(void)ensure:(NSUInteger)length {
        if(self.capacity < length) [self grow:length normalize:PGNormalizeNone];
    }

    -(NSBytePtr)copyBuffer:(NSUInteger *)cnt trim:(BOOL)trimFlag {
        NSBytePtr bytePtr = PGRealloc(NULL, (trimFlag ? queueCount : size));
        *cnt = (((head <= tail) ? tail : size) - head);

        memcpy(bytePtr, byteQueue + head, *cnt);
        if((tail < head) && (tail > 0)) {
            memcpy(bytePtr + *cnt, byteQueue, tail);
            *cnt += tail;
        }

        return bytePtr;
    }

    -(NSInteger)dequeue {
        NSUInteger ohead = head;
        if(ohead == tail) return EOF;
        head = nextIdx(ohead, size);
        return byteQueue[ohead];
    }

    -(NSUInteger)dequeue:(NSBytePtr)buffer maxLength:(NSUInteger)len {
        NSUInteger count = 0;

        if(buffer && len && (head != tail)) {
            if(head <= tail) {
                count = MIN(len, (tail - head));
                memcpy(buffer, (byteQueue + head), count);
                head = ((head + count) % size);
            }
            else {
                count = MIN(len, (size - head));
                memcpy(buffer, (byteQueue + head), count);
                head = ((head + count) % size);
                return (count + [self dequeue:(buffer + count) maxLength:(len - count)]);
            }
        }

        return count;
    }

    -(NSInteger)pop {
        if(head == tail) return EOF;
        return byteQueue[(tail = prevIdx(tail, size))];
    }

    -(NSUInteger)pop:(NSBytePtr)buffer maxLength:(NSUInteger)len {
        NSUInteger c = MIN(len, queueCount);
        NSUInteger l = c;
        while(c) buffer[--c] = byteQueue[(tail = prevIdx(tail, size))];
        return l;
    }

    -(void)queue:(NSByte)byte {
        [self ensure:1];
        byteQueue[tail] = byte;
        tail = nextIdx(tail, size);
    }

    -(void)queue:(NSBytePtr)buffer length:(NSUInteger)len {
        NSUInteger count = 0;

        if(buffer && len) {
            [self ensure:len];

            while(count < len) {
                byteQueue[tail] = buffer[count++];
                tail = nextIdx(tail, size);
            }
        }
    }

    -(void)queueFromQueue:(PGDynamicByteQueue *)queue length:(NSUInteger)length {
        NSUInteger count = MIN(length, queue.count);
        if(count) {
            [self ensure:count];
            for(NSUInteger i = 0; i < count; i++) [self queue:((NSByte)(queue.dequeue & 0x00ff))];
        }
    }

    -(void)requeue:(NSByte)byte {
        [self ensure:1];
        byteQueue[(head = prevIdx(head, size))] = byte;
    }

    -(void)requeue:(NSBytePtr)buffer length:(NSUInteger)len {
        NSUInteger count = 0;

        if(buffer && len) {
            [self ensure:len];

            while(len) {
                byteQueue[(head = prevIdx(head, size))] = buffer[--len];
                count++;
            }
        }
    }

    -(void)requeueFromQueue:(PGDynamicByteQueue *)queue length:(NSUInteger)length {
        NSUInteger count = MIN(length, queue.count);
        if(count) {
            [self ensure:count];
            for(NSUInteger i = 0; i < count; i++) [self requeue:((NSByte)(queue.pop & 0x00ff))];
        }
    }

    -(void)queueString:(NSString *)string {
        const char *cstr = (string.length ? string.UTF8String : nil);
        if(cstr) [self queue:(NSBytePtr)cstr length:strlen(cstr)];
    }

    -(void)requeueString:(NSString *)string {
        const char *cstr = (string.length ? string.UTF8String : nil);
        if(cstr) [self requeue:(NSBytePtr)cstr length:strlen(cstr)];
    }

    -(NSString *)string {
        NSUInteger len  = 0;
        NSBytePtr  cstr = [self copyBuffer:&len trim:YES];
        return [[NSString alloc] initWithBytesNoCopy:cstr length:len encoding:NSUTF8StringEncoding freeWhenDone:YES];
    }

    -(NSData *)data {
        if(head == tail) return [NSData new];
        NSUInteger length = 0;
        NSBytePtr  bytes  = [self copyBuffer:&length trim:YES];
        return [[NSData alloc] initWithBytesNoCopy:bytes length:length freeWhenDone:YES];
    }

    -(NSMutableData *)appendToData:(NSMutableData *)mdata {
        NSUInteger count = queueCount;

        if(!mdata) mdata = (count ? [NSMutableData dataWithCapacity:count] : [NSMutableData new]);

        if(count) {
            [mdata appendBytes:(byteQueue + head) length:(((head <= tail) ? tail : size) - head)];
            if((tail < head) && (tail > 0)) [mdata appendBytes:byteQueue length:tail];
        }

        return mdata;
    }

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock normalizeBefore:(PGNormalizeType)normalizeType restoreOnFailure:(BOOL)restoreOnFailure {
        [self normalizeQueue:normalizeType];

        if(restoreOnFailure) {
            NSUInteger _head      = head;
            NSUInteger _tail      = tail;
            NSBytePtr  _byteQueue = PGRealloc(NULL, size);
            BOOL       success;

            @try {
                memcpy(_byteQueue, byteQueue, size);
                success = opBlock(_byteQueue, size, &_head, &_tail);

                if(success) {
                    memcpy(byteQueue, _byteQueue, size);
                    head = _head;
                    tail = _tail;
                }
            }
            @finally {
                free(_byteQueue);
            }

            return success;
        }

        return opBlock(byteQueue, size, &head, &tail);
    }

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock restoreOnFailure:(BOOL)restoreOnFailure {
        return [self queueOperationWithBlock:opBlock normalizeBefore:PGNormalizeNone restoreOnFailure:restoreOnFailure];
    }

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock {
        return [self queueOperationWithBlock:opBlock restoreOnFailure:NO];
    }

@end
