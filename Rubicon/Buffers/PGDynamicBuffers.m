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
#import "PGByteQueueTools.h"

@interface PGDynamicByteQueue()

    -(instancetype)initWithBuffer:(PGRawByteBuffer *)buffer NS_DESIGNATED_INITIALIZER;

    -(void)_queueString:(NSString *)string;

    -(void)_queueData:(NSData *)data range:(NSRange)range;

    -(void)_requeueString:(NSString *)string;

    -(void)_requeueData:(NSData *)data range:(NSRange)range;

@end

@implementation PGDynamicByteQueue {
        PGQueueDataStruct byteQueue;
        BOOL              freeWhenDone;
    }

#pragma mark Initializers

    -(instancetype)init {
        return (self = [self initWithInitialSize:0]);
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];

        if(self) {
            freeWhenDone = YES;
            byteQueue.size  = (initialSize ?: DefaultBufferInitialSize);
            byteQueue.head  = 0;
            byteQueue.tail  = 0;
            byteQueue.queue = PGRealloc(NULL, byteQueue.size);
        }

        return self;
    }

    -(instancetype)initWithBytesNoCopy:(NSBytePtr)bytes count:(NSUInteger)cnt length:(NSUInteger)len freeWhenDone:(BOOL)shouldFree {
        self = [super init];

        if(self) {
            freeWhenDone = shouldFree;
            byteQueue.size  = len;
            byteQueue.head  = 0;
            byteQueue.tail  = cnt;
            byteQueue.queue = bytes;
        }

        return self;
    }

    -(instancetype)initWithBuffer:(PGRawByteBuffer *)buffer {
        self = [super init];

        if(self) {
            freeWhenDone = YES;
            byteQueue.size  = buffer->size;
            byteQueue.queue = buffer->buffer;
            byteQueue.head  = 0;
            byteQueue.tail  = buffer->count;
        }

        return self;
    }

    -(instancetype)initWithNSData:(NSData *)data {
        self = [super init];

        if(self) {
            freeWhenDone = YES;
            byteQueue.head = 0;
            byteQueue.tail = data.length;
            byteQueue.size = MAX(DefaultBufferInitialSize, byteQueue.tail + 1);
            byteQueue.queue = PGRealloc(NULL, byteQueue.size);

            if(byteQueue.tail) [data getBytes:byteQueue.queue length:byteQueue.tail];
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

#pragma mark Overridden Methods

    -(void)dealloc {
        if(freeWhenDone && (byteQueue.queue != NULL)) free(byteQueue.queue);
        memset(&byteQueue, 0, SizeOfPGQueueDataStruct);
        freeWhenDone = NO;
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        PGRawByteBuffer buffer;
        copyToBuffer(&buffer, &byteQueue, NO);
        return [(PGDynamicByteQueue *)[[self class] allocWithZone:zone] initWithBuffer:&buffer];
    }

#pragma mark Informational Methods

    -(NSUInteger)count {
        return QueueCount(&byteQueue);
    }

    -(BOOL)isEmtpy {
        return (byteQueue.head == byteQueue.tail);
    }

#pragma mark Getting data off the head...

    -(NSInteger)dequeue {
        if(byteQueue.head == byteQueue.tail) return EOF;
        return byteQueue.queue[postIncHead(&byteQueue, 1)];
    }

    -(NSUInteger)dequeue:(NSBytePtr)buffer maxLength:(NSUInteger)len {
        NSUInteger count = 0;

        if(buffer && len && (byteQueue.head != byteQueue.tail)) {
            count = MIN(len, QueueTop(&byteQueue));
            memcpy(buffer, (byteQueue.queue + postIncHead(&byteQueue, count)), count);
            if((count < len) && HasFrontData(&byteQueue)) count += [self dequeue:(buffer + count) maxLength:(len - count)];
        }

        return count;
    }

    -(NSString *)string {
        PGRawByteBuffer buffer;
        NSBytePtr       cstr = copyToBuffer(&buffer, &byteQueue, YES);
        return [[NSString alloc] initWithBytesNoCopy:cstr length:buffer.count encoding:NSUTF8StringEncoding freeWhenDone:YES];
    }

    -(NSData *)data {
        if(byteQueue.head == byteQueue.tail) return [NSData new];
        PGRawByteBuffer buffer;
        NSBytePtr       bytes = copyToBuffer(&buffer, &byteQueue, YES);
        return [[NSData alloc] initWithBytesNoCopy:bytes length:buffer.count freeWhenDone:YES];
    }

    -(NSMutableData *)appendToData:(NSMutableData *)mdata {
        NSUInteger count = QueueCount(&byteQueue);

        if(!mdata) mdata = (count ? [NSMutableData dataWithCapacity:count] : [NSMutableData new]);

        if(count) {
            [mdata appendBytes:(byteQueue.queue + byteQueue.head) length:QueueTop(&byteQueue)];
            if(HasFrontData(&byteQueue)) [mdata appendBytes:byteQueue.queue length:byteQueue.tail];
        }

        return mdata;
    }

#pragma mark Getting data off the tail...

    -(NSInteger)pop {
        if(byteQueue.head == byteQueue.tail) return EOF;
        return byteQueue.queue[preDec(&byteQueue.tail, 1, byteQueue.size)];
    }

    -(NSUInteger)pop:(NSBytePtr)buffer maxLength:(NSUInteger)len {
        NSUInteger c = MIN(len, QueueCount(&byteQueue));
        NSUInteger l = c;
        while(c) buffer[--c] = byteQueue.queue[preDec(&byteQueue.tail, 1, byteQueue.size)];
        return l;
    }

#pragma mark Queuing data...

    -(void)queue:(NSByte)byte {
        ensureCapacity(&byteQueue, 1);
        byteQueue.queue[postIncTail(&byteQueue, 1)] = byte;
    }

    -(void)queue:(const NSBytePtr)buffer length:(NSUInteger)len {
        if(buffer && len) {
            ensureCapacity(&byteQueue, len);

            if(byteQueue.head == byteQueue.tail) {
                // Happy path...
                byteQueue.head = 0;
                byteQueue.tail = len;
                memcpy(byteQueue.queue, buffer, len);
            }
            else if(byteQueue.head < byteQueue.tail) {
                // Ugly path...
                NSUInteger cnt = appendBuffer(&byteQueue, buffer, len, byteQueue.size);
                [self queue:(buffer + cnt) length:(len - cnt)];
            }
            else {
                appendBuffer(&byteQueue, buffer, len, byteQueue.head);
            }
        }
    }

    -(void)queueFromQueue:(PGDynamicByteQueue *)queue length:(NSUInteger)length {
        if(queue && length) {
            PGQueueDataStruct *bq = &queue->byteQueue;
            NSUInteger        l1  = MIN(length, QueueTop(bq));

            [self queue:(bq->queue + postIncHead(bq, l1)) length:l1];

            if((l1 < length) && (bq->tail > 0)) {
                NSUInteger l2 = MIN((length - l1), bq->tail);
                [self queue:(bq->queue + postIncHead(bq, l2)) length:l2];
            }
        }
    }

    -(void)queueString:(NSString *)string {
        if(string.length) [self _queueString:string];
    }

    -(void)queueString:(NSString *)string range:(NSRange)range {
        if(string) [self queueString:[string substringWithRange:range]];
    }

    -(void)queueData:(NSData *)data {
        if(data.length) [self _queueData:data range:NSMakeRange(0, data.length)];
    }

    -(void)queueData:(NSData *)data range:(NSRange)range {
        if(data) [self _queueData:data range:range];
    }

    -(void)_queueString:(NSString *)string {
        const char *cstr = (string.length ? string.UTF8String : nil);
        if(cstr) [self queue:(NSBytePtr)cstr length:strlen(cstr)];
    }

    -(void)_queueData:(NSData *)data range:(NSRange)range {
        if(range.length) {
            NSBytePtr ptr = PGRealloc(NULL, range.length);
            [data getBytes:ptr range:range];
            [self queue:ptr length:range.length];
            free(ptr);
        }
    }

#pragma mark Requeuing data...

    -(void)requeue:(NSByte)byte {
        ensureCapacity(&byteQueue, 1);
        byteQueue.queue[preDec(&byteQueue.head, 1, byteQueue.size)] = byte;
    }

    -(void)requeue:(const NSBytePtr)buffer length:(NSUInteger)len {
        NSUInteger count = 0;
        /*
         * TODO: Rewrite...
         */

        if(buffer && len) {
            ensureCapacity(&byteQueue, len);

            while(len) {
                byteQueue.queue[preDec(&byteQueue.head, 1, byteQueue.size)] = buffer[--len];
                count++;
            }
        }
    }

    -(void)requeue:(const NSBytePtr)buffer range:(NSRange)range {
        [self requeue:(buffer + range.location) length:range.length];
    }

    -(void)requeueFromQueue:(PGDynamicByteQueue *)queue length:(NSUInteger)length {
        /*
         * TODO: Rewrite...
         */
        NSUInteger count = MIN(length, queue.count);
        if(count) {
            ensureCapacity(&byteQueue, count);
            for(NSUInteger i = 0; i < count; i++) [self requeue:CastByte(queue.pop)];
        }
    }

    -(void)requeueString:(NSString *)string {
        if(string.length) {
            [self _requeueString:string];
        }
    }

    -(void)requeueString:(NSString *)string range:(NSRange)range {
        if(string.length) [self _requeueString:[string substringWithRange:range]];
    }

    -(void)requeueData:(NSData *)data {
        if(data.length) [self _requeueData:data range:NSMakeRange(0, data.length)];
    }

    -(void)requeueData:(NSData *)data range:(NSRange)range {
        if(data.length) [self _requeueData:data range:range];
    }

    -(void)_requeueString:(NSString *)string {
        const char *cstr = (string.length ? string.UTF8String : nil);
        if(cstr) [self requeue:(NSBytePtr)cstr length:strlen(cstr)];
    }

    -(void)_requeueData:(NSData *)data range:(NSRange)range {
        if(range.length) {
            NSBytePtr ptr = PGRealloc(NULL, range.length);
            [data getBytes:ptr range:range];
            [self requeue:ptr length:range.length];
            free(ptr);
        }
    }

#pragma mark Block operations...

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock normalizeBefore:(PGNormalizeType)normalizeType restoreOnFailure:(BOOL)restoreOnFailure {
        if(restoreOnFailure) {
            PGQueueDataStruct _q;
            BOOL              success;

            rawCopy(&_q, &byteQueue, NO);

            @try {
                normalizeQueue(normalizeType, &_q);
                success = opBlock(_q.queue, _q.size, &_q.head, &_q.tail);

                if(success) {
                    NSBytePtr old = byteQueue.queue;
                    memcpy(&byteQueue, &_q, SizeOfPGQueueDataStruct);
                    _q.queue = old;
                }
            }
            @finally {
                free(_q.queue);
            }

            return success;
        }

        normalizeQueue(normalizeType, &byteQueue);
        return opBlock(byteQueue.queue, byteQueue.size, &byteQueue.head, &byteQueue.tail);
    }

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock restoreOnFailure:(BOOL)restoreOnFailure {
        return [self queueOperationWithBlock:opBlock normalizeBefore:PGNormalizeNone restoreOnFailure:restoreOnFailure];
    }

    -(BOOL)queueOperationWithBlock:(PGDynamicBufferOpBlock)opBlock {
        return [self queueOperationWithBlock:opBlock restoreOnFailure:NO];
    }

@end
