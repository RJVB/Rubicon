/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGByteQueueTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/13/18
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

#import "PGByteQueueTools.h"
#import "PGInternal.h"

NSBytePtr _copyToBuffer(const PGQueueDataStruct *src, NSUInteger *size, NSUInteger *count, BOOL trim) {
    (*count)         = QueueTop(src);
    (*size)          = (trim ? QueueCount(src) : src->size);
    NSBytePtr buffer = PGRealloc(NULL, (*size));

    memcpy(buffer, (src->queue + src->head), (*count));

    if(HasFrontData(src)) {
        memcpy((buffer + (*count)), src->queue, src->tail);
        (*count) += src->tail;
    }

    return buffer;
}

void relocateHead(NSUInteger newHead, PGQueueDataStruct *q) {
    // Don't bother if we're already in the correct position...
    if(newHead != q->head) {
        NSString *fmt = @"%@ value is greater than buffer size: %lu >= %lu";
        if(newHead >= q->size) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(fmt, @"Head", newHead, q->size)];

        NSUInteger length  = QueueCount(q);
        NSUInteger newTail = (newHead + length);

        if(newTail >= q->size) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(fmt, @"Tail", newTail, q->size)];
        }
        else if(length) {
            NSBytePtr p1 = (q->queue + newHead);
            NSBytePtr p2 = (q->queue + q->head);

            if((q->head <= q->tail) || (q->tail == 0)) {
                memmove(p1, p2, length);
            }
            else {
                NSUInteger top  = QueueTop(q);
                NSBytePtr  tbuf = PGRealloc(NULL, q->tail);

                memcpy(tbuf, q->queue, q->tail);
                memmove(p1, p2, top);
                memcpy((p1 + top), tbuf, q->tail);
                free(tbuf);
            }
        }

        q->head = newHead;
        q->tail = newTail;
    }
}

void normalizeQueue(PGNormalizeType norm, PGQueueDataStruct *q) {
    switch(norm) {
        case PGNormalizeBeginning: {
            relocateHead(0, q);
            break;
        }
        case PGNormalizeEnd: {
            relocateHead(QueueCapacity(q), q);
            break;
        }
        default: break; // Do nothing...
    }
}

void rawCopy(PGQueueDataStruct *dest, const PGQueueDataStruct *src, BOOL normFront) {
    if(normFront) {
        dest->head = 0;
        _copyToBuffer(src, &dest->size, &dest->tail, NO);
    }
    else {
        dest->head  = src->head;
        dest->tail  = src->tail;
        dest->size  = src->size;
        dest->queue = PGMemDup(src->queue, src->size);
    }
}

NSBytePtr copyToBuffer(PGRawByteBuffer *dest, const PGQueueDataStruct *src, BOOL trim) {
    return (dest->buffer = _copyToBuffer(src, &dest->size, &dest->count, trim));
}

void ensureCapacity(PGQueueDataStruct *q, NSUInteger length) {
    if(QueueCapacity(q) < length) {
        NSUInteger newSize = (q->size * 2);
        NSUInteger cc      = (QueueCount(q) + 1);

        while((newSize - cc) < length) newSize *= 2;
        q->queue = PGRealloc(q->queue, newSize);

        if(q->tail < q->head) {
            if(q->tail) memcpy((q->queue + q->size), q->queue, q->tail);
            q->tail += q->size;
        }

        q->size = newSize;
    }
}

