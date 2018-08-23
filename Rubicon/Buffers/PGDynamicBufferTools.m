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

void PGByteQueueNormalize(PGByteQueuePtr q) {
    if(q) {
        if(q->qhead == q->qtail) {
            q->qhead = q->qtail = 0;
        }
        else if((q->qtail < q->qhead)) {
            NSUInteger topSize  = (q->qsize - q->qhead);
            NSUInteger dataSize = (q->qtail + topSize);
            NSByte     *tbuf    = PGMalloc(q->qsize);

            memcpy(tbuf, (q->qbuffer + q->qhead), topSize);
            if(q->qtail) memcpy((tbuf + topSize), q->qbuffer, q->qtail);
            free(q->qbuffer);
            q->qbuffer = tbuf;
            q->qhead   = 0;
            q->qtail   = dataSize;
        }
        else if(q->qhead) {
            NSUInteger dataSize = (q->qtail - q->qhead);
            memmove(q->qbuffer, (q->qbuffer + q->qhead), dataSize);
            q->qhead = 0;
            q->qtail = dataSize;
        }
    }
    else { PGThrowNullPointerException; }
}

PGByteQueuePtr PGByteQueueCreate(NSUInteger initialSize) {
    if(initialSize == 0) PGThrow(NSInvalidArgumentException, PGErrorMsgZeroLengthBuffer);
    PGByteQueuePtr q = malloc(sizeof(PGByteQueue));

    if(q) {
        q->qinit = q->qsize = MAX(initialSize, PGDynByteQueueMinSize);
        q->qhead   = q->qtail = 0;
        q->qbuffer = malloc(q->qsize);

        if(q->qbuffer) return q;

        free(q);
    }

    PGThrowOutOfMemoryException;
}

void PGByteQueueDestroy(PGByteQueuePtr q, BOOL secure) {
    if(q) {
        if(q->qbuffer) {
            if(secure) memset(q->qbuffer, 0, q->qsize);
            free(q->qbuffer);
        }

        if(secure) memset(q, 0, sizeof(PGByteQueue));
        free(q);
    }
}

NSUInteger PGByteQueueResize(PGByteQueuePtr q, NSUInteger spaceNeeded) {
    if(q) {
        NSUInteger nsize = q->qsize;

        if(nsize <= spaceNeeded) {
            /* Take the current size and keep doubling it until we have enough room. */
            do { nsize *= 2; } while(nsize <= spaceNeeded);

            /* Reallocate the buffer to the new size. */
            q->qbuffer = PGRealloc(q->qbuffer, nsize);

            /* If the data was wrapped then unwrap it. */
            if(q->qtail < q->qhead) {
                PGMemMove((q->qbuffer + q->qsize), q->qbuffer, q->qtail);
                q->qtail += q->qsize;
            }

            q->qsize = nsize;
        }

        return q->qsize;
    }
    else { PGThrowNullPointerException; }
}

NSUInteger PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta) {
    if(q) { return ((PGByteQueueRoomRemaining(q) < delta) ? PGByteQueueResize(q, (PGByteQueueCount(q) + delta)) : q->qsize); } else { PGThrowNullPointerException; }
}

BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2) {
    if(q1 == q2) return YES;
    if(q1 && q2) {
        NSUInteger bc1 = PGByteQueueCount(q1);
        NSUInteger bc2 = PGByteQueueCount(q2);

        if(bc1 == bc2) {
            if(bc1 == 0) return YES;

            NSUInteger q1head   = q1->qhead; /* The index of queue 1's head pointer. */
            NSUInteger q2head   = q2->qhead; /* The index of queue 2's head pointer. */
            NSUInteger q1tail   = q1->qtail; /* The index of queue 1's tail pointer. */
            NSUInteger q2tail   = q2->qtail; /* The index of queue 2's tail pointer. */
            NSUInteger q1top    = (q1->qsize - q1head); /* The distance from queue 1's head pointer to the top of the buffer. */
            NSUInteger q2top    = (q2->qsize - q2head); /* The distance from queue 2's head pointer to the top of the buffer. */
            NSUInteger q2toprem = (q2top - q1top);
            NSUInteger q1toprem = (q1top - q2top);

            NSByte *pq1buff = q1->qbuffer;
            NSByte *pq2buff = q2->qbuffer;
            NSByte *pq1head = (pq1buff + q1head);
            NSByte *pq2head = (pq2buff + q2head);
            NSByte *p2      = (pq2head + q1top);
            NSByte *p3      = (pq1buff + q2toprem);
            NSByte *p4      = (pq1head + q2top);
            NSByte *p5      = (pq2buff + q1toprem);

            BOOL norm1 = (q1head < q1tail); /* True if queue 1 is NOT wrapped. */
            BOOL norm2 = (q2head < q2tail); /* True if queue 2 is NOT wrapped. */
            /*
             * We have 6 use cases:
             */
            BOOL case1 = (norm1 && norm2);
            /*
             * 1) Neither queue is wrapped.
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 1 -> |   |   | A | B | C | D | E | F | G | H |   |   |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *                      |H|                             |T|
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 2 -> | A | B | C | D | E | F | G | H |   |   |   |   |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *              |H|                             |T|
             */
            BOOL case2 = norm1;
            /*
             * 2) Only the second queue is wrapped.
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 1 -> |   |   | A | B | C | D | E | F | G | H |   |   |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *                      |H|                             |T|
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 2 -> | G | H |   |   |   |   | A | B | C | D | E | F |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *                      |T|             |H|
             */
            BOOL case3 = norm2;
            /*
             * 3) Only the first queue is wrapped.
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 1 -> | G | H |   |   |   |   | A | B | C | D | E | F |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *                      |T|             |H|
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 2 -> |   |   | A | B | C | D | E | F | G | H |   |   |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *                      |H|                             |T|
             */
            BOOL case4 = (q1top == q2top);
            /*
             * 4) Both queues are wrapped but at the exact same point. (Their head pointers are the same.)
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 1 -> | G | H |   |   |   |   | A | B | C | D | E | F |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *                      |T|             |H|
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 2 -> | G | H |   |   |   |   | A | B | C | D | E | F |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *                      |T|             |H|
             */
            BOOL case5 = (q1top < q2top);
            /*
             * 5) Both queues are wrapped with the 1st queue's top portion smaller than the 2nd queue's.
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 1 -> | D | E | F | G | H |   |   |   |   | A | B | C |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *             |           |       ||T|            ||H|        |
             *             \__________/\______/                \__________/
             *               q2toprem   q2tail                    q1top
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 2 -> | G | H |   |   |   |   | A | B | C | D | E | F |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *             |       ||T|            ||H|        |           |
             *             \______/                \__________/\__________/
             *              q2tail                    q1top      q2toprem
             */
            /*
             * 6) Both queues are wrapped with the 1st queue's top portion larger than the 2nd queue's.
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 1 -> | G | H |   |   |   |   | A | B | C | D | E | F |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *             |       ||T|            ||H|        |           |
             *             \______/                \__________/\__________/
             *              q1tail                    q2top      q1toprem
             *
             *               0   1   2   3   4   5   6   7   8   9   10  11
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *  Queue 2 -> | D | E | F | G | H |   |   |   |   | A | B | C |
             *             +---+---+---+---+---+---+---+---+---+---+---+---+
             *             |           |       ||T|            ||H|        |
             *             \__________/\______/                \__________/
             *               q1toprem   q1tail                    q2top
             */
            /**/ if(case1) return PGMemEqu(pq1head, pq2head, bc1);
            else if(case2) return (PGMemEqu(pq1head, pq2head, q2top) && PGMemEqu(p4, pq2buff, q2tail));
            else if(case3) return (PGMemEqu(pq2head, pq1head, q1top) && PGMemEqu(p2, pq1buff, q1tail));
            else if(case4) return (PGMemEqu(pq1head, pq2head, q1top) && PGMemEqu(pq1buff, pq2buff, q1tail));
            else if(case5) return (PGMemEqu(pq1head, pq2head, q1top) && PGMemEqu(pq1buff, p2, q2toprem) && PGMemEqu(p3, pq2buff, q2tail));
            else /*     */ return (PGMemEqu(pq2head, pq2head, q2top) && PGMemEqu(pq2buff, p4, q1toprem) && PGMemEqu(p5, pq1buff, q1tail));
        }
    }

    return NO;
}

void PGByteQueueQueue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
    if(q) {
        if(buffer && length) {
            if(length == 1) {
                PGByteQueueQueue(q, *buffer);
            }
            else {
                PGByteQueueEnsureRoom(q, length);
                if(PGByteQueueNeedReset(q)) q->qhead = q->qtail = 0;
                NSUInteger lim                       = ((q->qtail < q->qhead) ? length : MIN(length, (q->qsize - q->qtail)));
                NSUInteger rem = (length - lim);
                PGMemCopy((q->qbuffer + PGByteQueueIncTail(q, lim)), buffer, lim);
                PGMemCopy((q->qbuffer + PGByteQueueIncTail(q, rem)), (buffer + lim), rem);
            }
        }
        else if(length) PGThrowNullPointerException;
    }
    else { PGThrowNullPointerException; }
}

void PGByteQueueRequeue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
    if(q) {
        if(buffer && length) {
            if(length == 1) {
                PGByteQueueRequeue(q, *buffer);
            }
            else if(q->qhead == q->qtail) {
                PGByteQueueQueue(q, buffer, length);
            }
            else {
                PGByteQueueEnsureRoom(q, length);
                NSUInteger lim = ((q->qtail < q->qhead) ? length : MIN(length, q->qhead));
                NSUInteger rem = (length - lim);
                PGMemCopy((q->qbuffer + PGByteQueueDecHead(q, lim)), (buffer + rem), lim);
                PGMemCopy((q->qbuffer + PGByteQueueDecHead(q, rem)), buffer, rem);
            }
        }
        else if(length) PGThrowNullPointerException;
    }
    else { PGThrowNullPointerException; }
}

NSUInteger PGByteQueueDequeue(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    if(q && buffer) {
        NSUInteger length = MIN(maxLength, PGByteQueueCount(q));
        if(length) {
            NSUInteger lim = ((q->qhead < q->qtail) ? length : (q->qsize - q->qhead));
            NSUInteger rem = (length - lim);
            PGMemCopy(buffer, (q->qbuffer + PGByteQueueIncHead(q, lim)), lim);
            PGMemCopy((buffer + lim), (q->qbuffer + PGByteQueueIncHead(q, rem)), rem);
        }
        return length;
    }
    else { PGThrowNullPointerException; }
}

NSUInteger PGByteQueuePop(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    if(q && buffer) {
        for(NSUInteger i = 0; i < maxLength; ++i) {
            NSInteger b = PGByteQueuePop(q);
            if(b == EOF) return i; else buffer[i] = (NSByte)b;
        }
        return maxLength;
    }
    else { PGThrowNullPointerException; }
}

PGByteQueuePtr PGByteQueueCopy(PGByteQueuePtr dest, PGByteQueuePtr src) {
    if(src) {
        if(dest == NULL) dest = PGCalloc(1, sizeof(PGByteQueue));
        dest->qbuffer = PGRealloc(dest->qbuffer, src->qsize);

        dest->qinit = src->qinit;
        dest->qsize = src->qsize;
        dest->qhead = src->qhead;
        NSUInteger zz = dest->qtail = src->qtail;

        if(src->qtail < src->qhead) {
            PGMemCopy(dest->qbuffer, src->qbuffer, src->qtail);
            zz = src->qsize;
        }

        PGMemCopy((dest->qbuffer + src->qhead), (src->qbuffer + src->qhead), (zz - src->qhead));
        return dest;
    }
    else { PGThrowNullPointerException; }
}

NSString *PGByteQueueGetNSString(PGByteQueue *q, NSStringEncoding encoding) PG_OVERLOADABLE {
    if(q) {
        NSUInteger length = PGByteQueueCount(q);

        if(length) {
            NSByte     *b = PGMalloc(length + 1);
            NSUInteger cc = PGByteQueueDequeue(q, b, length);
            b[cc] = 0;
            return [[NSString alloc] initWithBytesNoCopy:b length:cc encoding:encoding freeWhenDone:YES];
        }

        return @"";
    }
    else { PGThrowNullPointerException; }
}

NSString *PGByteQueueGetNSString(PGByteQueue *q, NSStringEncoding encoding, NSUInteger length) PG_OVERLOADABLE {
    if(q) {
        if(length == 0) return @"";
        NSString *str = PGByteQueueGetNSString(q, encoding);
        return ((str.length <= length) ? str : [str substringWithRange:NSMakeRange(0, length)]);
    }
    else { PGThrowNullPointerException; }
}

NS_INLINE NSData *PGByteQueueGetNSData3(PGByteQueue *q, NSByte *buffer, NSUInteger length) {
    return [[NSData alloc] initWithBytesNoCopy:buffer length:PGByteQueueDequeue(q, buffer, length) freeWhenDone:YES];
}

NS_INLINE NSData *PGByteQueueGetNSData2(PGByteQueue *q, NSUInteger length) {
    return PGByteQueueGetNSData3(q, PGMalloc(length), length);
}

NS_INLINE NSData *PGByteQueueGetNSData1(PGByteQueue *q, NSUInteger length) {
    return (length ? PGByteQueueGetNSData2(q, length) : PGGetEmptyNSDataSingleton());
}

NSData *PGByteQueueGetNSData(PGByteQueue *q, NSUInteger length) PG_OVERLOADABLE {
    if(q) { return PGByteQueueGetNSData1(q, MIN(length, PGByteQueueCount(q))); } else { PGThrowNullPointerException; }
}

NSData *PGByteQueueGetNSData(PGByteQueue *q) PG_OVERLOADABLE {
    return PGByteQueueGetNSData(q, NSUIntegerMax);
}

void PGByteQueueQueue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
    if(q) {
        PGByteQueueEnsureRoom(q, 1);
        q->qbuffer[(PGByteQueueNeedReset(q) ? PGByteQueueWhenEmpty : PGByteQueueIncHead)(q, 1)] = byte;
    }
    else { PGThrowNullPointerException; }
}

void PGByteQueueRequeue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
    if(q) {
        PGByteQueueEnsureRoom(q, 1);
        q->qbuffer[(PGByteQueueNeedReset(q) ? PGByteQueueWhenEmpty : PGByteQueueDecHead)(q, 1)] = byte;
    }
    else { PGThrowNullPointerException; }
}

NSInteger PGByteQueueDequeue(PGByteQueuePtr q) PG_OVERLOADABLE {
    if(q) { return ((q->qhead == q->qtail) ? EOF : q->qbuffer[PGByteQueueIncHead(q, 1)]); } else { PGThrowNullPointerException; }
}

NSInteger PGByteQueuePop(PGByteQueuePtr q) PG_OVERLOADABLE {
    if(q) { return ((q->qhead == q->qtail) ? EOF : q->qbuffer[PGByteQueueDecTail(q, 1)]); } else { PGThrowNullPointerException; }
}

NSUInteger PGByteQueueHash(PGByteQueuePtr q) {
    if(q) {
        if(q->qhead <= q->qtail) return PGHash((q->qbuffer + q->qhead), (q->qtail - q->qhead));
    }

    return 0;
}

PGByteBufferPtr PGByteBufferCreate(NSUInteger size) PG_OVERLOADABLE {
    if(size == 0) PGThrow(NSInvalidArgumentException, PGErrorMsgZeroLengthBuffer);
    PGByteBufferPtr bb = calloc(1, sizeof(PGByteBuffer));

    if(bb) {
        bb->bytes = malloc(bb->size = size);
        if(bb->bytes) return bb;
        free(bb);
    }

    PGThrowOutOfMemoryException;
}

void PGByteBufferDestroy(PGByteBufferPtr bb, BOOL secure) {
    if(bb) {
        if(bb->bytes) {
            if(secure) memset(bb->bytes, 0, bb->size);
            free(bb->bytes);
        }
        memset(bb, 0, sizeof(PGByteBuffer));
        free(bb);
    }
}

BOOL PGByteBufferCompare(PGByteBufferPtr b1, PGByteBufferPtr b2) {
    return ((b1 == b2) || ((b1 && b2 && (b1->length == b2->length) && (memcmp(b1, b2, b1->length) == 0))));
}

NSUInteger PGByteBufferHash(PGByteBufferPtr b) {
    return (b ? PGHash(b->bytes, b->length) : 0);
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b, NSUInteger maxLength) PG_OVERLOADABLE {
    if(b) {
        NSUInteger length = MIN(maxLength, b->length);
        return (length ? [[NSData alloc] initWithBytes:b->bytes length:length] : PGGetEmptyNSDataSingleton());
    }
    else { PGThrowNullPointerException; }
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b) PG_OVERLOADABLE {
    return PGByteBufferGetNSData(b, NSUIntegerMax);
}

PGByteBufferPtr PGByteBufferCreate(NSByte *b, NSUInteger length) PG_OVERLOADABLE {
    if(b && length) {
        PGByteBufferPtr bc = PGByteBufferCreate(length);
        memcpy(bc->bytes, b, (bc->length = length));
        return bc;
    }
    else if(b) { PGThrowInvArgException(PGErrorMsgNoData); }
    else { PGThrowNullPointerException; }
}

PGByteBufferPtr PGByteBufferCreate(NSData *data, NSUInteger length) PG_OVERLOADABLE {
    NSUInteger maxLength = MIN(data.length, length);

    if(data && maxLength) {
        PGByteBufferPtr b = PGByteBufferCreate(maxLength);
        [data getBytes:b->bytes length:(b->length = maxLength)];
        return b;
    }
    else if(data) { PGThrowInvArgException(PGErrorMsgNoData); }
    else { PGThrowNullPointerException; }
}

PGByteBufferPtr PGByteBufferCreate(NSData *data) PG_OVERLOADABLE {
    return PGByteBufferCreate(data, data.length);
}

PGByteBufferPtr PGByteBufferCopy(PGByteBufferPtr b) {
    if(b) {
        PGByteBufferPtr bc = PGByteBufferCreate(b->size);
        bc->length = b->length;
        bc->aux1   = b->aux1;
        bc->aux2   = b->aux2;
        memcpy(bc->bytes, b->bytes, b->length);
        return bc;
    }
    else { PGThrowNullPointerException; }
}
