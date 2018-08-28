/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDynamicBufferTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/9/18
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

PGByteBufferPtr PGByteBufferCreate(NSUInteger size) PG_OVERLOADABLE {
    if(size == 0) PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
    PGByteBufferPtr bbuf = PGCalloc(1, sizeof(PGByteBuffer));
    bbuf->bytes = malloc((bbuf->size = size));
    if(bbuf->bytes) return bbuf;
    PGThrowOutOfMemoryException;
}

PGByteBufferPtr PGByteBufferCreate(NSByte *b, NSUInteger length) PG_OVERLOADABLE {
    PGByteBufferPtr bbuf = PGByteBufferCreate(length);
    memcpy(bbuf->bytes, b, (bbuf->length = length));
    return bbuf;
}

PGByteBufferPtr PGByteBufferCreate(NSData *data, NSUInteger length) PG_OVERLOADABLE {
    PGByteBufferPtr bbuf = PGByteBufferCreate(length);
    if((bbuf->length = MIN(data.length, length))) [data getBytes:bbuf->bytes length:bbuf->length];
    return bbuf;
}

PGByteBufferPtr PGByteBufferCreate(NSData *data) PG_OVERLOADABLE {
    return PGByteBufferCreate(data, data.length);
}

PGByteBufferPtr PGByteBufferCopy(PGByteBufferPtr b) {
    if(!b) PGThrowNullPointerException;
    PGByteBufferPtr bbuf = PGByteBufferCreate(b->size);
    bbuf->length = b->length;
    bbuf->aux1   = b->aux1;
    bbuf->aux2   = b->aux2;
    memcpy(bbuf->bytes, b->bytes, bbuf->length);
    return bbuf;
}

void PGByteBufferDestroy(PGByteBufferPtr bb, BOOL secure) {
    if(bb) {
        if(bb->bytes) {
            if(secure) {
#pragma clang diagnostic push
#pragma ide diagnostic ignored "CannotResolve"
                getrandom(bb->bytes, bb->size, 0);
#pragma clang diagnostic pop
            }

            free(bb->bytes);
        }

        getentropy(bb, sizeof(PGByteBuffer));
        free(bb);
    }
}

BOOL PGByteBufferCompare(PGByteBufferPtr b1, PGByteBufferPtr b2) {
    return NO;
}

NSUInteger PGByteBufferHash(PGByteBufferPtr b) {
    return (b ? PGHash(b->bytes, b->length) : 0);
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b, NSUInteger maxLength) PG_OVERLOADABLE {
    if(!b) PGThrowNullPointerException;
    NSUInteger cc = MIN(b->size, MIN(b->length, maxLength));
    return (cc ? [[NSData alloc] initWithBytes:b->bytes length:cc] : [NSData new]);
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b) PG_OVERLOADABLE {
    return PGByteBufferGetNSData(b, (b ? MIN(b->length, b->size) : 0));
}

#define PGByteQueueNeedReset(q) ((q)->qhead && ((q)->qhead == (q)->qtail))

NS_INLINE NSUInteger PGByteQueueIncTail(PGByteQueuePtr q, NSUInteger delta) {
    NSUInteger t = q->qtail;
    if(delta) q->qtail = ((q->qtail + delta) % q->qsize);
    return t;
}

NS_INLINE NSUInteger PGByteQueueDecTail(PGByteQueuePtr q, NSUInteger delta) {
    return (q->qtail = (delta ? (((q->qtail < delta) ? (q->qsize + q->qtail) : q->qtail) - delta) : q->qtail));
}

NS_INLINE NSUInteger PGByteQueueIncHead(PGByteQueuePtr q, NSUInteger delta) {
    NSUInteger h = q->qhead;
    if(delta) q->qhead = ((q->qhead + delta) % q->qsize);
    return h;
}

NS_INLINE NSUInteger PGByteQueueDecHead(PGByteQueuePtr q, NSUInteger delta) {
    return (q->qhead = (delta ? (((q->qhead < delta) ? (q->qsize + q->qhead) : q->qhead) - delta) : q->qhead));
}

NS_INLINE NSUInteger PGByteQueueWhenEmpty(PGByteQueuePtr q, NSUInteger delta) {
    q->qtail         = delta;
    return (q->qhead = 0);
}

PGByteQueuePtr PGByteQueueCreate(NSUInteger initialSize) {
    if(initialSize == 0) PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
    PGByteQueuePtr q = PGCalloc(1, sizeof(PGByteQueue));
    q->qbuffer = malloc(q->qsize = q->qinit = MAX(initialSize, 2)); // Enough to hold at least one byte...
    if(q->qbuffer) return q;
    free(q);
    PGThrowOutOfMemoryException;
}

PGByteQueuePtr PGByteQueueCopy(PGByteQueuePtr dest, PGByteQueuePtr src) {
    if(!src) PGThrowNullPointerException;

    if(dest) {
        dest->qhead = dest->qtail = 0;
        PGByteQueueEnsureRoom(dest, PGByteQueueCount(src));
    }
    else {
        dest = PGByteQueueCreate(src->qsize);
        dest->qinit = src->qinit;
    }

    if(PGByteQueueCount(src)) {
        NSByte *srchead = (src->qbuffer + src->qhead);
        dest->qtail = PGByteQueueCount(src);

        if(src->qhead <= src->qtail) {
            memcpy(dest->qbuffer, srchead, (src->qtail - src->qhead));
        }
        else {
            NSUInteger cc = (src->qsize - src->qhead);

            memcpy(dest->qbuffer, srchead, cc);
            if(src->qtail) memcpy((dest->qbuffer + cc), src->qbuffer, src->qtail);
        }
    }

    return dest;
}

void PGByteQueueNormalize(PGByteQueuePtr q) {
}

NSUInteger PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta) {
    if(!q) PGThrowNullPointerException;
    if(delta) {
        NSUInteger ns     = q->qsize;
        NSUInteger needed = (PGByteQueueCount(q) + delta);

        if(ns <= needed) {
            do { ns *= 2; } while(ns <= needed);
            q->qbuffer = PGRealloc(q->qbuffer, ns);
            if(q->qtail < q->qhead) {
                if(q->qtail) memmove((q->qbuffer + q->qsize), q->qbuffer, q->qtail);
                q->qtail += q->qsize;
            }
            q->qsize   = ns;
        }
    }
    return q->qsize;
}

NSUInteger PGByteQueueResize(PGByteQueuePtr q, NSUInteger spaceNeeded) {
    return 0;
}

BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2) {
    return NO;
}

void PGByteQueueDestroy(PGByteQueuePtr q, BOOL secure) {
    if(q) {
        if(q->qbuffer) {
#pragma clang diagnostic push
#pragma ide diagnostic ignored "CannotResolve"
            if(secure) getrandom(q->qbuffer, q->qsize, 0);
#pragma clang diagnostic pop
            free(q->qbuffer);
        }
        memset(q, 0, sizeof(PGByteQueue));
        free(q);
    }
}

void PGByteQueueQueue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
}

void PGByteQueueQueue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
}

void PGByteQueueRequeue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
}

void PGByteQueueRequeue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
}

NSInteger PGByteQueueDequeue(PGByteQueuePtr q) PG_OVERLOADABLE {
    return 0;
}

NSUInteger PGByteQueueDequeue(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    return 0;
}

NSInteger PGByteQueuePop(PGByteQueuePtr q) PG_OVERLOADABLE {
    return 0;
}

NSUInteger PGByteQueuePop(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    return 0;
}

NSString *PGByteQueueGetNSString(PGByteQueue *q, NSStringEncoding encoding) PG_OVERLOADABLE {
    return nil;
}

NSString *PGByteQueueGetNSString(PGByteQueue *q, NSStringEncoding encoding, NSUInteger length) PG_OVERLOADABLE {
    return nil;
}

NSData *PGByteQueueGetNSData(PGByteQueue *q, NSUInteger length) PG_OVERLOADABLE {
    return nil;
}

NSData *PGByteQueueGetNSData(PGByteQueue *q) PG_OVERLOADABLE {
    return nil;
}
