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

void PGNormalizeByteQueue(PGByteQueuePtr q) {
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

PGByteQueuePtr PGCreateByteQueue(NSUInteger initialSize) {
    if(initialSize == 0) PGThrow(NSInvalidArgumentException, @"Zero length buffer size.");
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

void PGDestroyByteQueue(PGByteQueuePtr q, BOOL secure) {
    if(q) {
        if(q->qbuffer) {
            if(secure) memset(q->qbuffer, 0, q->qsize);
            free(q->qbuffer);
        }

        if(secure) memset(q, 0, sizeof(PGByteQueue));
        free(q);
    }
}

NSUInteger PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta) {
    NSUInteger byteCount = PGQueueByteCount(q);
    NSUInteger needed    = (byteCount + delta);
    NSUInteger size      = q->qsize;

    if(size <= needed) {
        /* Take the current size and keep doubling it until we have enough room. */
        do { size *= 2; } while(size <= needed);

        q->qbuffer = PGRealloc(q->qbuffer, size);

        if(q->qtail && (q->qtail < q->qhead)) memmove((q->qbuffer + q->qsize), q->qbuffer, q->qtail);
        if(q->qhead) memmove(q->qbuffer, (q->qbuffer + q->qhead), byteCount);

        q->qhead = 0;
        q->qtail = byteCount;
        q->qsize = size;
    }

    return q->qsize;
}

NS_INLINE BOOL mcmp(const uint8_t *p1, const uint8_t *p2, size_t l) {
    return ((l == 0) || (memcmp(p1, p2, l) == 0));
}

BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2) {
    if(q1 == q2) return YES;
    if(q1 && q2) {
        NSUInteger bc1 = PGQueueByteCount(q1);
        NSUInteger bc2 = PGQueueByteCount(q2);

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
            NSByte     *pq1buff = q1->qbuffer;
            NSByte     *pq2buff = q2->qbuffer;
            NSByte     *pq1head = (pq1buff + q1head);
            NSByte     *pq2head = (pq2buff + q2head);
            NSByte     *p2      = (pq2head + q1top);
            NSByte     *p3      = (pq1buff + q2toprem);
            NSByte     *p4      = (pq1head + q2top);
            NSByte     *p5      = (pq2buff + q1toprem);

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
            /**/ if(case1) return mcmp(pq1head, pq2head, bc1);
            else if(case2) return (mcmp(pq1head, pq2head, q2top) && mcmp(p4, pq2buff, q2tail));
            else if(case3) return (mcmp(pq2head, pq1head, q1top) && mcmp(p2, pq1buff, q1tail));
            else if(case4) return (mcmp(pq1head, pq2head, q1top) && mcmp(pq1buff, pq2buff, q1tail));
            else if(case5) return (mcmp(pq1head, pq2head, q1top) && mcmp(pq1buff, p2, q2toprem) && mcmp(p3, pq2buff, q2tail));
            else /*     */ return (mcmp(pq2head, pq2head, q2top) && mcmp(pq2buff, p4, q1toprem) && mcmp(p5, pq1buff, q1tail));
        }
    }

    return NO;
}
