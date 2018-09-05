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

/****************************************************************************************************************
 * SUPPORT MACROS
 ***************************************************************************************************************/
#pragma mark SUPPORT MACROS

#define __pg_inc(i, j, k) (((i) + (j)) % (k))
#define __pg_dec(i, j, k) ((j) ? ((((j) <= (i)) ? (i) : ((i) + (k))) - (j)) : (i))

/****************************************************************************************************************
 * SUPPORT FUNCTION PROTOTYPES
 ***************************************************************************************************************/
#pragma mark SUPPORT FUNCTIONS PROTOTYPES

BOOL __pg_q_compare(const PGByteQueue *q1, const PGByteQueue *q2);

NSUInteger __pg_q_write(PGByteQueue *q, NSUInteger idx, const NSByte *buffer, NSUInteger length);

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q) PG_OVERLOADABLE;

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, BOOL reverse) PG_OVERLOADABLE;

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, NSUInteger idx) PG_OVERLOADABLE;

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, NSUInteger idx, BOOL reverse) PG_OVERLOADABLE;

BOOL __pg_q_normalize(PGByteQueuePtr q, BOOL force);

NSUInteger __pg_q_hardunwrap(PGByteQueuePtr q, NSUInteger newsize);

NS_INLINE NSUInteger __pg_q_resize(PGByteQueuePtr q, NSUInteger newSize) {
    q->qbuffer = PGRealloc(q->qbuffer, newSize);
    q->qsize   = newSize;
    return PGByteQueueCount(q);
}

NS_INLINE NSUInteger __pg_q_inctail(PGByteQueuePtr q, NSUInteger delta) {
    if(delta) {
        NSUInteger t = q->qtail;
        q->qtail = __pg_inc(t, delta, q->qsize);
        return t;
    }
    return q->qtail;
}

NS_INLINE NSUInteger __pg_q_dechead(PGByteQueuePtr q, NSUInteger delta) {
    return (q->qhead = __pg_dec(q->qhead, delta, q->qsize));
}

NS_INLINE NSUInteger __pg_q_inchead(PGByteQueuePtr q, NSUInteger delta) {
    if(delta) {
        NSUInteger h = q->qhead;
        q->qhead = __pg_inc(h, delta, q->qsize);
        return h;
    }
    return q->qhead;
}

NS_INLINE NSUInteger __pg_q_dectail(PGByteQueuePtr q, NSUInteger delta) {
    return (q->qtail = __pg_dec(q->qtail, delta, q->qsize));
}

/****************************************************************************************************************
 * BYTE BUFFERS
 ***************************************************************************************************************/
#pragma mark BYTE BUFFERS

PGByteBufferPtr PGByteBufferCreate(NSUInteger size) PG_OVERLOADABLE {
    if(size) {
        PGByteBufferPtr _b = PGCalloc(1, sizeof(PGByteBuffer));
        _b->bytes = PGMalloc(_b->size = size);
        if(_b->bytes) return _b;
        free(_b);
        PGThrowOutOfMemoryException;
    }
    PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
}

PGByteBufferPtr PGByteBufferCreate(NSByte *bytes, NSUInteger length) PG_OVERLOADABLE {
    if(bytes && length) {
        PGByteBufferPtr _b = PGByteBufferCreate(length);
        memmove(_b->bytes, bytes, (_b->length = length));
        return _b;
    }
    else if(length) PGThrowNullPointerException;
    PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
}

PGByteBufferPtr PGByteBufferCreate(NSData *data, NSUInteger length) PG_OVERLOADABLE {
    if(data && data.length && length) {
        PGByteBufferPtr _b = PGByteBufferCreate(MIN(data.length, length));
        [data getBytes:_b->bytes length:(_b->length = _b->size)];
        return _b;
    }
    else if(!data) PGThrowNullPointerException;
    PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
}

PGByteBufferPtr PGByteBufferCreate(NSData *data) PG_OVERLOADABLE {
    return PGByteBufferCreate(data, data.length);
}

PGByteBufferPtr PGByteBufferCopy(PGByteBufferPtr b) {
    if(b) {
        PGByteBufferPtr _b = PGByteBufferCreate(MAX(b->size, b->length));
        memmove(_b->bytes, b->bytes, (_b->length = MIN(b->size, b->length)));
        _b->aux1 = b->aux1;
        _b->aux2 = b->aux2;
        return _b;
    }
    PGThrowNullPointerException;
}

void PGByteBufferDestroy(PGByteBufferPtr bb, BOOL secure) {
    if(bb) {
        if(bb->bytes) {
            if(secure) getrandom(bb->bytes, bb->size, 0);
            free(bb->bytes);
        }
        memset(bb, 0, sizeof(PGByteBuffer));
        free(bb);
    }
}

BOOL PGByteBufferCompare(PGByteBufferPtr b1, PGByteBufferPtr b2) {
    return ((b1 == b2) || (b1 && b2 && (b1->length == b2->length) && ((b1->bytes == b2->bytes) || (b1->bytes && b2->bytes && PGMemEqu(b1->bytes, b2->bytes, b1->length)))));
}

NSUInteger PGByteBufferHash(PGByteBufferPtr b) {
    return (b ? PGHash(b->bytes, b->length) : 0);
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b, NSUInteger maxLength) PG_OVERLOADABLE {
    if(b) {
        NSUInteger available = MIN(b->length, maxLength);
        return (available ? [[NSData alloc] initWithBytes:b->bytes length:available] : [NSData new]);
    }

    PGThrowNullPointerException;
}

NSData *PGByteBufferGetNSData(PGByteBufferPtr b) PG_OVERLOADABLE {
    return PGByteBufferGetNSData(b, NSUIntegerMax);
}

PGByteBufferPtr PGByteBufferResize(PGByteBufferPtr b, NSUInteger size) {
    if(!b) PGThrowNullPointerException;
    if(!size) PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);

    if(b->size != size) {
        b->bytes  = PGRealloc(b->bytes, size);
        b->length = MIN(b->length, (b->size = size));
    }

    return b;
}

/****************************************************************************************************************
 * BYTE QUEUES
 ***************************************************************************************************************/
#pragma mark BYTE QUEUES

const NSUInteger PGByteQueueMinSize            = 5;
const NSUInteger PGByteQueueDefaultInitialSize = (64 * 1024);

PGByteQueuePtr PGByteQueueCreate(NSUInteger initialSize) {
    if(initialSize) {
        PGByteQueuePtr q = PGCalloc(1, sizeof(PGByteQueue));
        q->qbuffer = malloc(q->qinit = q->qsize = MAX(PGByteQueueMinSize, initialSize));
        if(q->qbuffer) return q;
        free(q);
        PGThrowOutOfMemoryException;
    }
    PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
}

PGByteQueuePtr PGByteQueueCopy(PGByteQueuePtr dest, PGByteQueuePtr src) {
    if(src && src->qbuffer) {
        if(src->qsize) {
            NSUInteger srclen = PGByteQueueCount(src);

            if(dest) {
                dest->qhead = dest->qtail = 0;
                PGByteQueueEnsureRoom(dest, srclen);
            }
            else {
                dest = PGByteQueueCreate(src->qsize);
                dest->qinit = src->qinit;
            }

            dest->qtail = __pg_q_read(dest->qbuffer, srclen, src);
            return dest;
        }
        PGThrowInvArgException(PGErrorMsgZeroLengthBuffer);
    }
    PGThrowNullPointerException;
}

#define __pg_q_growthfactor ((double)(1.5))
#define __pg_q_nextsize(sz) ((NSUInteger)floor(((double)(sz)) * __pg_q_growthfactor))

void PGByteQueueShrink(PGByteQueuePtr q) {
    if(q) {
        NSUInteger cs = PGByteQueueCount(q);
        NSUInteger ns = q->qinit;

        while(ns <= cs) ns = __pg_q_nextsize(ns);
        if(ns < q->qsize) (__pg_q_normalize(q, NO) ? __pg_q_resize : __pg_q_hardunwrap)(q, ns);
    }

    PGThrowNullPointerException;
}

PGByteQueuePtr PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta) {
    if(q) {
        if(q->qhead && (q->qhead == q->qtail)) q->qhead = q->qtail = 0;

        if(delta) {
            NSUInteger dsize = (PGByteQueueCount(q) + delta);
            NSUInteger osize = q->qsize;
            NSUInteger nsize = osize;

            if(nsize <= dsize) {
                do { nsize = __pg_q_nextsize(nsize); } while(nsize <= dsize);
                __pg_q_resize(q, nsize);

                if(q->qtail < q->qhead) {
                    NSUInteger tsz   = (osize - q->qhead);
                    NSUInteger nhead = (nsize - tsz);
                    memmove((q->qbuffer + nhead), (q->qbuffer + q->qhead), tsz);
                    q->qhead = nhead;
                }
            }
        }

        return q;
    }

    PGThrowNullPointerException;
}

BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2) {
    return ((q1 == q2) || (q1 && q2 && (PGByteQueueCount(q1) == PGByteQueueCount(q2)) && ((q1->qhead == q1->qtail) || __pg_q_compare(q1, q2))));
}

void PGByteQueueDestroy(PGByteQueuePtr q, BOOL secure) {
    if(q) {
        if(q->qbuffer) {
            if(secure) getrandom(q->qbuffer, q->qsize, 0);
            free(q->qbuffer);
        }
        memset(q, 0, sizeof(PGByteQueue));
        free(q);
    }
}

void PGByteQueueQueue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
    PGByteQueueEnsureRoom(q, 1);
    q->qbuffer[__pg_q_inctail(q, 1)] = byte;
}

/********************************************************************************************************//**
 * This method will throw a NULL pointer exception if either 'q' or 'buffer' is NULL unless length is zero.
 *
 * @param q the queue to receive the bytes.
 * @param buffer the bytes to queue.
 * @param length the number of bytes to queue.
 *//********************************************************************************************************/
void PGByteQueueQueue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
    if(buffer && length) __pg_q_write(q, __pg_q_inctail(PGByteQueueEnsureRoom(q, length), length), buffer, length); else if(length) PGThrowNullPointerException;
}

void PGByteQueueRequeue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE {
    PGByteQueueEnsureRoom(q, 1);
    q->qbuffer[__pg_q_dechead(q, 1)] = byte;
}

void PGByteQueueRequeue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE {
    if(buffer && length) __pg_q_write(q, __pg_q_dechead(PGByteQueueEnsureRoom(q, length), length), buffer, length); else if(length) PGThrowNullPointerException;
}

NSInteger PGByteQueueDequeue(PGByteQueuePtr q) PG_OVERLOADABLE {
    if(q) return ((q->qhead == q->qtail) ? EOF : q->qbuffer[__pg_q_inchead(q, 1)]);
    PGThrowNullPointerException;
}

NSUInteger PGByteQueueDequeue(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    if(q && buffer) {
        NSUInteger length = MIN(maxLength, PGByteQueueCount(q));
        return __pg_q_read(buffer, length, q, __pg_q_inchead(q, length));
    }

    PGThrowNullPointerException;
}

NSInteger PGByteQueuePop(PGByteQueuePtr q) PG_OVERLOADABLE {
    if(q) return ((q->qhead == q->qtail) ? EOF : q->qbuffer[__pg_q_dectail(q, 1)]);
    PGThrowNullPointerException;
}

NSUInteger PGByteQueuePop(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength, BOOL reverse) PG_OVERLOADABLE {
    if(q && buffer) {
        NSUInteger length = MIN(maxLength, PGByteQueueCount(q));
        return __pg_q_read(buffer, length, q, __pg_q_dectail(q, length), reverse);
    }
    PGThrowNullPointerException;
}

NSUInteger PGByteQueuePop(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE {
    return PGByteQueuePop(q, buffer, maxLength, NO);
}

PGByteBufferPtr PGByteQueueGetByteBuffer(PGByteQueuePtr q, NSUInteger length) PG_OVERLOADABLE {
    if(q) {
        NSUInteger len = MIN(length, PGByteQueueCount(q));
        PGByteBufferPtr b = PGByteBufferCreate(MAX(1, len));
        b->length = __pg_q_read(b->bytes, len, q);
        return b;
    }
    PGThrowNullPointerException;
}

PGByteBufferPtr PGByteQueueGetByteBuffer(PGByteQueuePtr q) PG_OVERLOADABLE {
    return PGByteQueueGetByteBuffer(q, NSUIntegerMax);
}

NSString *PGByteQueueGetNSString(PGByteQueuePtr q, NSStringEncoding encoding) PG_OVERLOADABLE {
    if(q) {
        NSUInteger length = PGByteQueueCount(q);

        if(length) {
            NSByte *buffer = PGMalloc(length);
            __pg_q_read(buffer, length, q);
            return [[NSString alloc] initWithBytesNoCopy:buffer length:length encoding:encoding freeWhenDone:YES];
        }

        return @"";
    }

    PGThrowNullPointerException;
}

NSString *PGByteQueueGetNSString(PGByteQueuePtr q, NSStringEncoding encoding, NSUInteger length) PG_OVERLOADABLE {
    NSString *str = PGByteQueueGetNSString(q, encoding);
    return ((length < str.length) ? [str substringWithRange:NSMakeRange(0, length)] : str);
}

NSString *PGByteQueueGetNSString(PGByteQueuePtr q) PG_OVERLOADABLE {
    return PGByteQueueGetNSString(q, NSUTF8StringEncoding);
}

NSData *PGByteQueueGetNSData(PGByteQueuePtr q, NSUInteger length) PG_OVERLOADABLE {
    if(q) {
        NSUInteger len = MIN(length, PGByteQueueCount(q));

        if(len) {
            NSByte *buffer = PGMalloc(len);
            __pg_q_read(buffer, len, q);
            return [[NSData alloc] initWithBytesNoCopy:buffer length:len freeWhenDone:YES];
        }

        return PGGetEmptyNSDataSingleton();
    }

    PGThrowNullPointerException;
}

NSData *PGByteQueueGetNSData(PGByteQueuePtr q) PG_OVERLOADABLE {
    return PGByteQueueGetNSData(q, NSUIntegerMax);
}

/****************************************************************************************************************
 * SUPPORT FUNCTIONS
 ***************************************************************************************************************/
#pragma mark SUPPORT FUNCTIONS

NS_INLINE void __pg_q_reverse_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, NSUInteger idx) {
    while(length) {
        buffer[--length] = q->qbuffer[idx];
        idx = __pg_inc(idx, 1, q->qsize);
    }
}

NS_INLINE void __pg_q_forward_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, NSUInteger idx) {
    NSUInteger l1 = MIN(length, (q->qsize - idx));
    PGMemCopy(buffer, (q->qbuffer + idx), l1);
    PGMemCopy((buffer + l1), q->qbuffer, (length - l1));
}

NS_INLINE void __pg_q_normunwrap1(const PGByteQueue *q, NSUInteger begsize, NSUInteger endsize, NSUInteger bytecnt) {
    NSByte *bfree = (q->qbuffer + begsize);
    memmove(bfree, (q->qbuffer + q->qhead), endsize); // Move the free space to the end of the buffer.
    memmove((bfree + endsize), q->qbuffer, begsize);  // Move the beginning part to the free space.
    memmove(q->qbuffer, bfree, bytecnt);              // Move everything down to the beginning.
}

NS_INLINE void __pg_q_normunwrap2(const PGByteQueue *q, NSUInteger begsize, NSUInteger endsize) {
    memmove((q->qbuffer + endsize), q->qbuffer, begsize);  // Move enough of the free space to the beginning for the end part to fit.
    memmove(q->qbuffer, (q->qbuffer + q->qhead), endsize); // Move the end part to the beginning.
}

NS_INLINE NSUInteger __pg_q_normunwrap3(PGByteQueuePtr q, NSUInteger begsize, NSUInteger endsize, NSUInteger newsize) {
    NSByte *buffer = PGMalloc(newsize);
    memcpy(buffer, (q->qbuffer + q->qhead), endsize);
    memcpy((buffer + endsize), q->qbuffer, begsize);
    free(q->qbuffer);
    q->qbuffer = buffer;
    return (begsize + endsize);
}

NS_INLINE BOOL __pg_q_normunwrap(PGByteQueuePtr q, NSUInteger bytecnt, BOOL force) {
    NSUInteger freesize = (q->qhead - q->qtail);
    NSUInteger endsize  = (q->qsize - q->qhead);
    NSUInteger begsize  = (q->qtail);

    if(begsize <= freesize) __pg_q_normunwrap1(q, begsize, endsize, bytecnt);
    else if(endsize <= freesize) __pg_q_normunwrap2(q, begsize, endsize);
    else if(force) __pg_q_normunwrap3(q, begsize, endsize, q->qsize);
    else return NO;
    return YES;
}

NS_INLINE BOOL __pg_q_cmp1(const NSByte *q1data, const NSByte *q2data, const PGByteQueue *q2, NSUInteger q2tsz) {
    return (PGMemEqu(q1data, q2data, q2tsz) && PGMemEqu((q1data + q2tsz), q2->qbuffer, q2->qtail));
}

NS_INLINE BOOL __pg_q_cmp2(const PGByteQueue *q1, const PGByteQueue *q2, const NSByte *q1data, const NSByte *q2data, NSUInteger q1tsz, NSUInteger q2tsz) {
    NSUInteger tdiff = (q1tsz - q2tsz);
    return PGMemEqu(q1data, q2data, q2tsz) && PGMemEqu((q1data + q2tsz), q2->qbuffer, tdiff) && PGMemEqu(q1->qbuffer, (q2->qbuffer + tdiff), q1->qtail);
}

BOOL __pg_q_compare(const PGByteQueue *q1, const PGByteQueue *q2) {
    BOOL       q1norm  = (q1->qhead < q1->qtail);
    BOOL       q2norm  = (q2->qhead < q2->qtail);
    NSByte     *q1data = (q1->qbuffer + q1->qhead);
    NSByte     *q2data = (q2->qbuffer + q2->qhead);
    NSUInteger q1tsz   = (q1->qsize - q1->qhead);
    NSUInteger q2tsz   = (q2->qsize - q2->qhead);

    /*@f:0*/ if(q1norm && q2norm) return PGMemEqu(q1data, q2data, (q1->qtail - q1->qhead));
    else     if(q1norm)           return __pg_q_cmp1(q1data, q2data, q2, q2tsz);
    else     if(q2norm)           return __pg_q_cmp1(q2data, q1data, q1, q1tsz);
    else     if(q1tsz == q2tsz)   return (PGMemEqu(q1data, q2data, q1tsz) && PGMemEqu(q1->qbuffer, q2->qbuffer, q1->qtail));
    else     if(q1tsz > q2tsz)    return __pg_q_cmp2(q1, q2, q1data, q2data, q1tsz, q2tsz);
    else                          return __pg_q_cmp2(q2, q1, q2data, q1data, q2tsz, q1tsz); /*@f:1*/
}

NSUInteger __pg_q_write(PGByteQueue *q, NSUInteger idx, const NSByte *buffer, NSUInteger length) {
    NSUInteger l1 = MIN(length, (q->qsize - idx));
    /*
     * At this point we know for sure that we have enough room between
     * the head and the tail no matter how they're positioned and the
     * space we are going to write to will either be wrapped or not.
     *
     * 'l1' is going to be either equal to or less than 'length'. If 'l1'
     * is equal to 'length' then the space is not wrapped and the second
     * call to PGMemCopy(...) will do nothing.
     */
    PGMemCopy((q->qbuffer + idx), buffer, l1);
    PGMemCopy(q->qbuffer, (buffer + l1), (length - l1));
    return length;
}

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, NSUInteger idx, BOOL reverse) PG_OVERLOADABLE {
    if(length) (reverse ? __pg_q_reverse_read : __pg_q_forward_read)(buffer, length, q, idx);
    return length;
}

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, NSUInteger idx) PG_OVERLOADABLE {
    return __pg_q_read(buffer, length, q, idx, NO);
}

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q) PG_OVERLOADABLE {
    return __pg_q_read(buffer, length, q, q->qhead, NO);
}

NSUInteger __pg_q_read(NSByte *buffer, NSUInteger length, const PGByteQueue *q, BOOL reverse) PG_OVERLOADABLE {
    return __pg_q_read(buffer, length, q, q->qhead, reverse);
}

BOOL __pg_q_normalize(PGByteQueuePtr q, BOOL force) {
    BOOL       success = YES;
    NSUInteger bytecnt = PGByteQueueCount(q);

    if(bytecnt) {
        if(q->qhead < q->qtail) memmove(q->qbuffer, (q->qbuffer + q->qhead), bytecnt);
        else success = __pg_q_normunwrap(q, bytecnt, force);
    }

    if(success) {
        q->qhead = 0;
        q->qtail = bytecnt;
    }

    return success;
}

NSUInteger __pg_q_hardunwrap(PGByteQueuePtr q, NSUInteger newsize) {
    q->qtail = __pg_q_normunwrap3(q, q->qtail, (q->qsize - q->qhead), newsize);
    q->qhead = 0;
    return q->qtail;
}
