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

#import "PGDynamicBufferTools.h"

#define NSUIntegerSize sizeof(NSUInteger)

typedef union {
    NSUInteger word;
    NSByte     bytes[NSUIntegerSize];
} NSHashHelper;

#define HP            (31u)
#define FOOHASH(h, v) ((h)=(((h)*(HP))+(v)))
#define FOOCAST(t, p) (*((t *)((voidp)(p))))

NS_INLINE NSUInteger qCalculateHash3(const NSByte *b, NSUInteger *h, NSUInteger s, NSUInteger c, NSUInteger hash) {
    if(c) {
        NSHashHelper   hh = { .word = 0 };
        for(NSUInteger i  = 0; i < c; i++) hh.bytes[i] = b[qPostAdd(h, 1, s)];
        FOOHASH(hash, hh.word);
    }

    return hash;
}

NS_INLINE NSUInteger qCalculateHash2(const NSByte *b, NSUInteger *h, NSUInteger s, NSUInteger c, NSUInteger hash) {
    for(NSUInteger i = 0; i < c; i++) FOOHASH(hash, FOOCAST(NSUInteger, b + qPostAdd(h, NSUIntegerSize, s)));
    return hash;
}

NS_INLINE NSUInteger qCalculateHash1(const NSByte *b, NSUInteger h, NSUInteger s, NSUInteger c) {
    return (c ? qCalculateHash3(b, &h, s, (c % NSUIntegerSize), qCalculateHash2(b, &h, s, (c / NSUIntegerSize), (HP + c))) : HP);
}

NSUInteger qCalculateHash(const PGByteQueue *q) {
    return qCalculateHash1(q->qbuffer, q->qhead, q->qsize, QCOUNT(q));
}

PGByteQueue *qCreateNewBuffer(NSUInteger initialSize, NSUInteger currentSize) {
    PGByteQueue *q = PGCalloc(1, sizeof(PGByteQueue));
    q->qsize   = umax(currentSize, initialSize);
    q->qinit   = initialSize;
    q->qbuffer = PGCalloc(1, q->qsize);
    return q;
}

PGByteQueue *qCopyQueueData(PGByteQueue *dest, const PGByteQueue *src) {
    if(src && dest) {
        BOOL w = QWRAPPED(src);

        dest->qhead = 0;
        dest->qtail = (w ? (QSZHD(src) + src->qtail) : QTLHD(src));

        if(dest->qtail) {
            NSUInteger t = (w ? QSZHD(src) : QTLHD(src));
            PGMemCopy(dest->qbuffer, QHEADP(src), t);
            if(w && src->qtail) PGMemCopy((dest->qbuffer + t), src->qbuffer, src->qtail);
        }

        return dest;
    }

    PGThrowNullPointerException;
}

PGByteQueue *qCreateExactCopy(const PGByteQueue *q) {
    if(q && q->qbuffer) {
        PGByteQueue *c = qCreateNewBuffer(q->qinit, q->qsize);
        c->qhead = q->qhead;
        c->qtail = q->qtail;

        if(QWRAPPED(q)) {
            PGMemCopy(QHEADP(c), QHEADP(q), QSZHD(q));
            PGMemCopy(c->qbuffer, q->qbuffer, q->qtail);
        }
        else {
            PGMemCopy(QHEADP(c), QHEADP(q), QTLHD(q));
        }

        return c;
    }

    PGThrowNullPointerException;
}

PGByteQueue *qCreateNormalizedCopy(const PGByteQueue *q) {
    if(q && q->qbuffer) return qCopyQueueData(qCreateNewBuffer(q->qinit, q->qsize), q); else PGThrowNullPointerException;
}

BOOL qCompareQueues(const PGByteQueue *q1, const PGByteQueue *q2) {
    if(q1 && q2) {
        NSUInteger   h1  = q1->qhead, t1 = q1->qtail, h2 = q2->qhead, s1 = q1->qsize, s2 = q2->qsize;
        const NSByte *b1 = q1->qbuffer;
        const NSByte *b2 = q2->qbuffer;

        while(h1 != t1) {
            if(b1[qPostAdd(&h1, 1, s1)] != b2[qPostAdd(&h2, 1, s2)]) return NO;
        }

        return YES;
    }

    return (q1 == q2);
}

PGByteQueue *qDestroyQueue(PGByteQueue *q) {
    if(q) {
        if(q->qbuffer) {
            memset(q->qbuffer, 0, q->qsize);
            free(q->qbuffer);
        }

        memset(q, 0, sizeof(PGByteQueue));
        free(q);
    }

    return NULL;
}

void qBottomUpFirst(PGByteQueue *q, NSUInteger lim) {
    /*
     * We start by moving the bottom up to make
     * just enough room to move the top down. When
     * we're done the data will already be at the
     * beginning of the buffer.
     */
    PGMemMove((q->qbuffer + lim), q->qbuffer, q->qtail);
    PGMemMove(q->qbuffer, QHEADP(q), lim);
}

void qTopDownFirst(PGByteQueue *q, NSUInteger lim, NSUInteger qc) {
    /*
     * We start by moving the top down as far as we can
     * so that we can move the bottom up above it.
     */
    PGMemMove(QHEADP(q), QTAILP(q), lim);
    PGMemMove((q->qbuffer + qc), q->qbuffer, q->qtail);
    PGMemMove(q->qbuffer, QTAILP(q), qc);
}

void qUnwrapInPlaceAndShrink(PGByteQueue *q, NSUInteger lim, NSUInteger fsp, NSUInteger ns, NSUInteger qc) {
    /*
     * We have enough room to move the bottom up first
     * which is nice because this will take one fewer
     * move operation than if we had to move the top
     * down first.
     */
    if(lim <= fsp) qBottomUpFirst(q, lim); else qTopDownFirst(q, lim, qc);
    q->qhead   = 0;
    q->qtail   = qc;
    q->qbuffer = PGRealloc(q->qbuffer, (q->qsize = ns));
}

void qUnwrapWithTempAndShrink(PGByteQueue *q, NSUInteger lim, NSUInteger ns, NSUInteger qc) {
    /*
     * There's not enough room to efficiently unwrap the data
     * so let's just create a new buffer and copy the data.
     */
    NSByte *b = PGMalloc((q->qsize = ns));

    PGMemCopy(b, QHEADP(q), lim);
    PGMemCopy((b + lim), q->qbuffer, q->qtail);
    free(q->qbuffer); // Free the old buffer.

    q->qbuffer = b;
    q->qhead   = 0;
    q->qtail   = qc;
}

void qUnwrapAndShrink(PGByteQueue *q, NSUInteger ns, NSUInteger qc) {
    /*
     * We would like to simply unwrap the data in-place. If we can't
     * do that then we'll simply create a new buffer and copy the
     * data over.
     */
    NSUInteger lim = QSZHD(q);
    NSUInteger fsp = (q->qhead - q->qtail);

    if(fsp < umin(lim, q->qtail)) qUnwrapWithTempAndShrink(q, lim, ns, qc); else qUnwrapInPlaceAndShrink(q, lim, fsp, ns, qc);
}

void qShrinkQueue(PGByteQueue *q, NSUInteger ns, NSUInteger qc) {
    /*
     * If the data is unwrapped then it's pretty straight forward.
     */
    PGMemMove(q->qbuffer, QHEADP(q), qc);
    q->qhead   = 0;
    q->qtail   = qc;
    q->qbuffer = PGRealloc(q->qbuffer, (q->qsize = ns));
}

#define FOOMULT(v, f)             ((NSUInteger)(ceil(((double)(v))*((double)(f)))))
#define FOOSHRINKTEST(mn, ns, qc) (((ns)>(mn))&&((qc)<=(FOOMULT((ns),(0.25)))))

void _qTryShrink(PGByteQueue *q, NSUInteger qc, NSUInteger ns) {
    /*
     * As long as the data size is less than 1/4 the current buffer size
     * then cut the buffer size in half but never make it less than the
     * initial size.
     */
    if(FOOSHRINKTEST(q->qinit, ns, qc)) {
        do { ns = umax(q->qinit, FOOMULT(ns, 0.5)); } while(FOOSHRINKTEST(q->qinit, ns, qc));
        if(QWRAPPED(q)) qUnwrapAndShrink(q, ns, qc); else qShrinkQueue(q, ns, qc);
    }
}

void qTryShrink(PGByteQueue *q) {
    if(q) _qTryShrink(q, QCOUNT(q), q->qsize); else PGThrowNullPointerException;
}

NSUInteger qNextSize(NSUInteger needed, NSUInteger newSize) {
    while(newSize <= needed) newSize *= 2;
    return newSize;
}

void _qTryGrow(PGByteQueue *q, NSUInteger needed, NSUInteger newSize) {
    NSUInteger originalSize = q->qsize;

    if(newSize <= needed) {
        newSize = qNextSize(needed, newSize);
        q->qbuffer = PGRealloc(q->qbuffer, (q->qsize = newSize));
        if(QWRAPPED(q)) PGMemMove(QPTR(q, originalSize), q->qbuffer, qTailPostAdd(q, originalSize));
    }
}

void qTryGrow(PGByteQueue *q, NSUInteger needed) {
    if(q) _qTryGrow(q, needed, q->qsize); else PGThrowNullPointerException;
}
