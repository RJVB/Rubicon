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

#import "PGDynamicBuffers.h"
#import "PGDynamicBufferTools.h"
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
                NSUInteger pages = (bb->size / 256);
                NSUInteger overg = (pages * 256);

                for(NSUInteger i = 0; i < pages; ++i) getentropy((bb->bytes + (i * 256)), 256);
                if(overg < bb->size) getentropy((bb->bytes + overg), (bb->size - overg));
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
    return 0;
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b, NSUInteger maxLength) PG_OVERLOADABLE {
    return nil;
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b) PG_OVERLOADABLE {
    return nil;
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
    return NULL;
}

PGByteQueuePtr PGByteQueueCopy(PGByteQueuePtr dest, PGByteQueuePtr src) {
    return NULL;
}

void PGByteQueueNormalize(PGByteQueuePtr q) {
}

NSUInteger PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta) {
    return 0;
}

NSUInteger PGByteQueueResize(PGByteQueuePtr q, NSUInteger spaceNeeded) {
    return 0;
}

BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2) {
    return NO;
}

void PGByteQueueDestroy(PGByteQueuePtr q, BOOL secure) {
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
