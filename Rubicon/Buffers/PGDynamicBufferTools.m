/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDynamicBufferTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/9/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 ***************************************************************************/

#import "PGInternal.h"

#pragma mark SUPPORT

#define __pg_b_cmp(b1, l1, b2, l2) (((b1) == (b2)) || ((b1) && (b2) && ((l1) == (l2)) && PGMemEqu((b1), (b2), (l1))))
#define __qhead(q)             ((q)->qhead)
#define __qtail(q)             ((q)->qtail)
#define __qsize(q)             ((q)->qsize)
#define __qempty(q)            (__qhead(q) == __qtail(q))
#define __qwrpd(q)             (__qtail(q) < __qhead(q))
#define __qnorm(q)             (__qhead(q) <= __qtail(q))
#define __qheadsz(q)           (__qsize(q) - __qhead(q))
#define __qtailsz(q)           (__qsize(q) - __qtail(q))
#define __qnormsz(q)           (__qtail(q) - __qhead(q))
#define __qbuf(q)              ((q)->qbuffer)
#define __qbufcell(q, i)       __qbuf(q)[i]
#define __qbufoff(q, d)        (__qbuf(q) + (d))
#define __qbufhead(q)          __qbufoff(q, __qhead(q))
#define __qbufsize(q)          __qbufoff(q, __qsize(q))
#define __pg_ringinc(i, d, s)  ((i) = (((i) + (d)) % (s)))
#define __pg_ringdec(i, d, s)  ((i) = ((d) ? ((((i) < (d)) ? ((s) + (i)) : (i)) - (d)) : (i)))

NS_INLINE BOOL __qcmp4(const PGByteQueuePtr q1, const PGByteQueuePtr q2) {
    NSByte     *p1head = __qbufhead(q1);
    NSByte     *p2head = __qbufhead(q2);
    NSUInteger top2    = __qheadsz(q2);
    NSUInteger topd    = (__qhead(q2) - __qhead(q1));

    return (PGMemEqu(p1head, p2head, top2) && PGMemEqu((p1head + top2), __qbuf(q2), topd) && PGMemEqu(__qbuf(q1), __qbufoff(q2, topd), (__qtail(q2) - topd)));
}

NS_INLINE BOOL __qcmp3(const PGByteQueuePtr q1, const PGByteQueuePtr q2) {
    return (PGMemEqu(__qbufhead(q1), __qbufhead(q2), __qheadsz(q1)) && PGMemEqu(__qbuf(q1), __qbuf(q2), __qtail(q1)));
}

NS_INLINE BOOL __qcmp2(const PGByteQueuePtr q1, const PGByteQueuePtr q2) {
    NSByte     *ph1 = __qbufhead(q1);
    NSUInteger qt2  = __qheadsz(q2);

    return (PGMemEqu(ph1, __qbufhead(q2), qt2) && PGMemEqu((ph1 + qt2), __qbuf(q2), __qtail(q2)));
}

NS_INLINE BOOL __qcmp1(const PGByteQueuePtr q1, const PGByteQueuePtr q2) {
    return PGMemEqu(__qbufhead(q1), __qbufhead(q2), __qnormsz(q1));
}

NS_INLINE BOOL __qcmp0(const PGByteQueuePtr q1, const PGByteQueuePtr q2) {
    if(__qempty(q1)) return YES;
    else if(__qnorm(q1) && __qnorm(q2)) return __qcmp1(q1, q2);
    else if(__qnorm(q1)) return __qcmp2(q1, q2);
    else if(__qnorm(q2)) return __qcmp2(q2, q1);
    else if((__qhead(q1) == __qhead(q2))) return __qcmp3(q1, q2);
    else if((__qhead(q1) < __qhead(q2))) return __qcmp4(q1, q2);
    else return __qcmp4(q2, q1);
}

NS_INLINE NSUInteger __qunwrap1(NSByte *buffptr, NSUInteger head, NSUInteger tail, NSUInteger topsz) {
    memmove((buffptr + topsz), buffptr, tail);
    memmove(buffptr, (buffptr + head), topsz);
    return (tail + topsz);
}

NS_INLINE NSUInteger __qunwrap2(NSByte *buffptr, NSUInteger head, NSUInteger tail, NSUInteger topsz) {
    NSByte *freeptr = (buffptr + tail);
    memmove(freeptr, (buffptr + head), topsz);
    memmove((freeptr + topsz), buffptr, tail);
    memmove(buffptr, freeptr, (topsz + tail));
    return (tail + topsz);
}

NS_INLINE NSUInteger __qunwrap3(NSByte *p, NSUInteger h, NSUInteger t, NSUInteger z) {
    NSByte     *p1 = (p + h), *p2 = (p + z), *p3 = p, *p4 = p;
    NSUInteger s1  = z, s2 = t;

    /* @f:0 */ if(t < z) { p3 = p1; p4 = p2; p1 = p2 = p; s1 = s2; s2 = z; } /* @f:1 */

    NSByte *tbuff = PGMalloc(s1);
    memcpy(tbuff, p1, s1);
    memmove(p2, p3, s2);
    memcpy(p4, tbuff, s1);
    free(tbuff);
    return (z + t);
}

NS_INLINE NSUInteger __qunwrap4(NSByte *p, NSUInteger h, NSUInteger t, NSUInteger z) {
    return memlmove(p, (p + h), (t + z));
}

NS_INLINE NSUInteger __qnorm_wrapped(NSByte *p, NSUInteger h, NSUInteger t, NSUInteger s) {
    NSUInteger z = (s - h);
    return (t ? ((MIN(z, t) <= (h - t)) ? ((z <= t) ? __qunwrap1 : __qunwrap2) : __qunwrap3) : __qunwrap4)(p, h, t, z);
}

NS_INLINE NSUInteger __qnorm_unwrapped(NSByte *p, NSUInteger h, NSUInteger t, NSUInteger s) {
    return memlmove(p, (p + h), (t - h));
}

NS_INLINE NSUInteger __qnormalize(NSByte *p, NSUInteger h, NSUInteger t, NSUInteger s) {
    return (h ? (h == t) ? 0 : ((h < t) ? __qnorm_unwrapped : __qnorm_wrapped)(p, h, t, s) : t);
}

NS_INLINE NSUInteger __qinc_tail(PGByteQueuePtr q, NSUInteger delta) {
    NSUInteger t = __qtail(q);
    if(delta) __pg_ringinc(__qtail(q), delta, __qsize(q));
    return t;
}

NS_INLINE NSUInteger __qdec_tail(PGByteQueuePtr q, NSUInteger delta) {
    return __pg_ringdec(__qtail(q), delta, __qsize(q));
}

NS_INLINE NSUInteger __qinc_head(PGByteQueuePtr q, NSUInteger delta) {
    NSUInteger h = __qhead(q);
    if(delta) __pg_ringinc(__qhead(q), delta, __qsize(q));
    return h;
}

NS_INLINE NSUInteger __qdec_head(PGByteQueuePtr q, NSUInteger delta) {
    return __pg_ringdec(__qhead(q), delta, __qsize(q));
}

NS_INLINE NSUInteger __qxqueue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) {
    if(length) memcpy(__qbufoff(q, __qinc_tail(q, length)), buffer, length);
    return length;
}

NS_INLINE NSUInteger __qxdequeue(PGByteQueuePtr q, NSByte *buffer, NSUInteger length) {
    if(length) memcpy(buffer, __qbufoff(q, __qinc_head(q, length)), length);
    return length;
}

NS_INLINE void __qequeue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
    /* An empty queue is going to have room for at least one byte. */
    __qtail(q) = 1;
    __qbufcell(q, (__qhead(q) = 0)) = byte;
}

NS_INLINE void __qequeue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length)  PG_OVERLOADABLE {
    __qhead(q) = __qtail(q) = 0;
    __qxqueue(q, buffer, length);
}

NS_INLINE NSUInteger __qxrequeue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) {
    if(length) memcpy(__qbufoff(q, __qdec_head(q, length)), buffer, length);
    return length;
}

/****************************************************************************************************************
 * BYTE BUFFERS
 ***************************************************************************************************************/
#pragma mark BYTE BUFFERS

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
        PGFreeBuffer(bb->bytes, bb->size, secure);
        memset(bb, 0, sizeof(PGByteBuffer));
        free(bb);
    }
}

BOOL PGByteBufferCompare(PGByteBufferPtr b1, PGByteBufferPtr b2) {
    return ((b1 == b2) || (b1 && b2 && __pg_b_cmp(b1->bytes, b1->length, b2->bytes, b2->length)));
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

/****************************************************************************************************************
 * BYTE QUEUES
 ***************************************************************************************************************/
#pragma mark BYTE QUEUES

PGByteQueuePtr PGByteQueueCreate(NSUInteger initialSize) {
    if(initialSize == 0) PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
    PGByteQueuePtr q = PGCalloc(1, sizeof(PGByteQueue));
    __qbuf(q)        = malloc(__qsize(q) = q->qinit = MAX(initialSize, 2)); // Enough to hold at least one byte...
    if(__qbuf(q)) return q;
    free(q);
    PGThrowOutOfMemoryException;
}

PGByteQueuePtr PGByteQueueCopy(PGByteQueuePtr dest, PGByteQueuePtr src) {
    if(!src) PGThrowNullPointerException;

    if(dest) {
        __qhead(dest) = __qtail(dest) = 0;
        PGByteQueueEnsureRoom(dest, PGByteQueueCount(src));
    }
    else {
        dest = PGByteQueueCreate(__qsize(src));
        dest->qinit = src->qinit;
    }

    if(PGByteQueueCount(src)) {
        NSByte *srchead = __qbufhead(src);
        __qtail(dest) = PGByteQueueCount(src);

        if(__qnorm(src)) {
            memcpy(__qbuf(dest), srchead, __qnormsz(src));
        }
        else {
            NSUInteger cc = __qheadsz(src);
            memcpy(__qbuf(dest), srchead, cc);
            if(__qtail(src)) memcpy(__qbufoff(dest, cc), __qbuf(src), __qtail(src));
        }
    }

    return dest;
}

/******************************************************************************************//**
 * A normalized queue is NOT wrapped and has all of it's data starting at the beginning of
 * the queue buffer.
 *
 * @param q the queue to normalize.
 *//******************************************************************************************/
void PGByteQueueNormalize(PGByteQueuePtr q) {
    /* Sanity check */
    if(!q) PGThrowNullPointerException;
    __qtail(q) = __qnormalize(__qbuf(q), __qhead(q), __qtail(q), __qsize(q));
    __qhead(q) = 0;
}

PGByteQueuePtr PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta) {
    /* Sanity check */
    if(!q) PGThrowNullPointerException;

    /* Sanity check */
    if(delta) {
        /* Get the current queue buffer size.
         * This variable will also hold the new size. */
        NSUInteger ns     = __qsize(q);
        /* Get the size needed. (current_byte_count + delta) */
        NSUInteger needed = (PGByteQueueCount(q) + delta);

        /* Do we have enough room? */
        if(ns <= needed) {
            /* No? Double the size and check again. */
            do { ns *= 2; } while(ns <= needed);

            /* Reallocate the queue buffer to the newer size. */
            __qbuf(q) = PGRealloc(__qbuf(q), ns);

            /* Do we need to unwrap the data? */
            if(__qwrpd(q)) {
                if(__qtail(q)) memmove(__qbufsize(q), __qbuf(q), __qtail(q));
                __qtail(q) += __qsize(q);
            }

            /* Update the queue's size field. */
            __qsize(q) = ns;
        }
    }

    /* Return the queue size. */
    return q;
}

BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2) {
    return ((q1 == q2) ? YES : ((q1 && q2 && __qbuf(q1) && __qbuf(q2) && (PGByteQueueCount(q1) == PGByteQueueCount(q2))) ? __qcmp0(q1, q2) : NO));
}

void PGByteQueueDestroy(PGByteQueuePtr q, BOOL secure) {
    if(q) {
        PGFreeBuffer(__qbuf(q), __qsize(q), secure);
        memset(q, 0, sizeof(PGByteQueue));
        free(q);
    }
}

void PGByteQueueQueue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
    if(!q) PGThrowNullPointerException; else if(__qempty(q)) __qequeue(q, byte); else __qbufcell(q, __qinc_tail(PGByteQueueEnsureRoom(q, 1), 1)) = byte;
}

/********************************************************************************************************//**
 * Unless 'length' is zero, this method will throw a NULL pointer exception if either 'q' or 'buffer'
 * is NULL.
 *
 * @param q the queue to receive the bytes.
 * @param buffer the bytes to queue.
 * @param length the number of bytes to queue.
 *//********************************************************************************************************/
void PGByteQueueQueue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
    if(q && buffer && length) {
        PGByteQueueEnsureRoom(q, length);

        if(__qempty(q)) {
            __qequeue(q, buffer, length);
        }
        else if(__qwrpd(q)) {
            __qxqueue(q, buffer, length);
        }
        else {
            NSUInteger len = __qxqueue(q, buffer, MIN(length, __qtailsz(q)));
            __qxqueue(q, (buffer + len), (length - len));
        }
    }
    else if(length) PGThrowNullPointerException;
}

void PGByteQueueRequeue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
    if(!q) PGThrowNullPointerException; else if(__qempty(q)) __qequeue(q, byte); else __qbufcell(q, __qdec_head(PGByteQueueEnsureRoom(q, 1), 1)) = byte;
}

void PGByteQueueRequeue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
    if(q && buffer && length) {
        PGByteQueueEnsureRoom(q, length);

        if(__qempty(q)) {
            __qequeue(q, buffer, length);
        }
        else if(__qwrpd(q)) {
            __qxrequeue(q, buffer, length);
        }
        else {
            NSUInteger len = MIN(length, __qhead(q));
            NSUInteger rem = (length - len);
            __qxrequeue(q, (buffer + rem), len);
            __qxrequeue(q, buffer, rem);
        }
    }
    else if(length) PGThrowNullPointerException;
}

NSInteger PGByteQueueDequeue(PGByteQueuePtr q) PG_OVERLOADABLE {
    if(!q) PGThrowNullPointerException; else return (__qempty(q) ? EOF : __qbufcell(q, __qinc_head(q, 1)));
}

NSUInteger PGByteQueueDequeue(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    if(q && buffer && maxLength) {
        NSUInteger length = MIN(maxLength, PGByteQueueCount(q));

        if(length) {
            if(__qnorm(q)) {
                __qxdequeue(q, buffer, length);
            }
            else {
                NSUInteger len = __qxdequeue(q, buffer, MIN(length, __qheadsz(q)));
                __qxdequeue(q, (buffer + len), (length - len));
            }
        }

        return length;
    }
    else if(maxLength) PGThrowNullPointerException;
    return 0;
}

NSInteger PGByteQueuePop(PGByteQueuePtr q) PG_OVERLOADABLE {
    /* Sanity check */
    if(!q) PGThrowNullPointerException;
    return (__qempty(q) ? EOF : __qbufcell(q, __qdec_tail(q, 1)));
}

NSUInteger PGByteQueuePop(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    /* Sanity check */
    if(!q) PGThrowNullPointerException;
    if(__qempty(q)) return 0;
    return 0;
}

PGByteBufferPtr PGByteQueueGetBytes(PGByteQueuePtr q, NSUInteger length) PG_OVERLOADABLE {
    /* Sanity check */
    if(!q) PGThrowNullPointerException;
    NSUInteger cc = MIN(PGByteQueueCount(q), length);
    if(cc == 0) return NULL;
    PGByteBufferPtr b = PGByteBufferCreate(cc);
    b->length = PGByteQueueDequeue(q, b->bytes, b->size);
    return b;
}

PGByteBufferPtr PGByteQueueGetBytes(PGByteQueuePtr q) PG_OVERLOADABLE {
    return PGByteQueueGetBytes(q, NSUIntegerMax);
}

NSString *PGByteQueueGetNSString(PGByteQueuePtr q, NSStringEncoding encoding) PG_OVERLOADABLE {
    /* Sanity check */
    if(!q) PGThrowNullPointerException;

    NSUInteger cc = PGByteQueueCount(q);
    if(cc == 0) return @"";

    PGByteBufferPtr b  = PGByteQueueGetBytes(q, cc);
    NSString        *s = [[NSString alloc] initWithBytesNoCopy:b->bytes length:b->length encoding:encoding freeWhenDone:YES];

    free(b);
    return s;
}

NSString *PGByteQueueGetNSString(PGByteQueuePtr q, NSStringEncoding encoding, NSUInteger length) PG_OVERLOADABLE {
    if(length == 0) return @"";
    NSString *s = PGByteQueueGetNSString(q, encoding);
    return ((s.length <= length) ? s : [s substringToIndex:length]);
}

NSData *PGByteQueueGetNSData(PGByteQueuePtr q, NSUInteger length) PG_OVERLOADABLE {
    /* Sanity check */
    if(!q) PGThrowNullPointerException;
    NSUInteger cc = MIN(length, PGByteQueueCount(q));
    if(cc == 0) return [NSData new];
    PGByteBufferPtr b  = PGByteQueueGetBytes(q, cc);
    NSData          *d = [[NSData alloc] initWithBytesNoCopy:b->bytes length:b->length freeWhenDone:YES];
    free(b);
    return d;
}

NSData *PGByteQueueGetNSData(PGByteQueuePtr q) PG_OVERLOADABLE {
    return PGByteQueueGetNSData(q, NSUIntegerMax);
}
