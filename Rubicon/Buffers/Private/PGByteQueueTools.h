/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGByteQueueTools.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/13/18
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

#ifndef RUBICON_PGBYTEQUEUETOOLS_H
#define RUBICON_PGBYTEQUEUETOOLS_H

#import "PGDynamicBuffers.h"

NS_ASSUME_NONNULL_BEGIN

#define CastByte(i)                 ((NSByte)(i))
#define DefaultBufferInitialSize    ((NSUInteger)(64 * 1024))
#define SizeOfPGQueueDataStruct     (sizeof(PGQueueDataStruct))
#define SizeOfPGRawByteBuffer       (sizeof(PGRawByteBuffer))

typedef struct _pg_queue_data_struct {
    NSBytePtr  queue;
    NSUInteger head;
    NSUInteger tail;
    NSUInteger size;
} PGQueueDataStruct;

typedef struct _pg_raw_byte_buffer {
    NSBytePtr  buffer;
    NSUInteger size;
    NSUInteger count;
} PGRawByteBuffer;

NS_INLINE NSUInteger QueueTop(const PGQueueDataStruct *q) {
    return (((q->head <= q->tail) ? q->tail : q->size) - q->head);
}

NS_INLINE NSUInteger QueueCount(const PGQueueDataStruct *q) {
    return ((q->head <= q->tail) ? (q->tail - q->head) : ((q->size - q->head) + q->tail));
}

NS_INLINE NSUInteger QueueCapacity(const PGQueueDataStruct *q) {
    return (q->size - QueueCount(q) - 1);
}

NS_INLINE BOOL HasFrontData(const PGQueueDataStruct *q) {
    return ((q->head > q->tail) && (q->tail > 0));
}

NS_INLINE NSUInteger preDec(NSUInteger *idx, NSUInteger count, NSUInteger size) {
    while(count) {
        (*idx) = (((*idx) ?: size) - 1);
        count--;
    }
    return (*idx);
}

NS_INLINE NSUInteger preDecHead(PGQueueDataStruct *byteQueue, NSUInteger cnt) {
    return preDec(&byteQueue->head, cnt, byteQueue->size);
}

NS_INLINE NSUInteger preDecTail(PGQueueDataStruct *byteQueue, NSUInteger cnt) {
    return preDec(&byteQueue->tail, cnt, byteQueue->size);
}

NS_INLINE NSUInteger postInc(NSUInteger *idx, NSUInteger count, NSUInteger size) {
    NSUInteger x = *idx;
    *idx = (((*idx) + count) % size);
    return x;
}

NS_INLINE NSUInteger postIncTail(PGQueueDataStruct *byteQueue, NSUInteger cnt) {
    return postInc(&byteQueue->tail, cnt, byteQueue->size);
}

NS_INLINE NSUInteger postIncHead(PGQueueDataStruct *byteQueue, NSUInteger cnt) {
    return postInc(&byteQueue->head, cnt, byteQueue->size);
}

NS_INLINE NSUInteger appendBuffer(PGQueueDataStruct *byteQueue, const NSBytePtr buffer, NSUInteger len, NSUInteger top) {
    NSUInteger cnt = MIN(len, (top - byteQueue->tail));
    memcpy((byteQueue->queue + postIncTail(byteQueue, cnt)), buffer, cnt);
    return cnt;
}

FOUNDATION_EXPORT void ensureCapacity(PGQueueDataStruct *q, NSUInteger length);

FOUNDATION_EXPORT NSBytePtr copyToBuffer(PGRawByteBuffer *dest, const PGQueueDataStruct *src, BOOL trim);

FOUNDATION_EXPORT void rawCopy(PGQueueDataStruct *dest, const PGQueueDataStruct *src, BOOL normFront);

FOUNDATION_EXPORT void normalizeQueue(PGNormalizeType norm, PGQueueDataStruct *q);

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGBYTEQUEUETOOLS_H
