/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDynamicBufferTools.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/9/18
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

#ifndef RUBICON_PGDYNAMICBUFFERTOOLS_H
#define RUBICON_PGDYNAMICBUFFERTOOLS_H

#import <Rubicon/PGDynamicBuffers.h>
#import <Rubicon/NSException+PGException.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    NSUInteger qinit; // The initial size of the queue.
    NSUInteger qsize; // The current size of the queue.
    NSUInteger qhead;
    NSUInteger qtail;
    NSByte     *qbuffer;
}                        PGByteQueue;
typedef PGByteQueue      *PGByteQueuePtr;

typedef struct {
    NSByte     *bytes;
    NSUInteger length;
    NSUInteger aux1;
    NSUInteger aux2;
}                        PGByteBuffer;
typedef PGByteBuffer     *PGByteButterPtr;

typedef struct {
    PGByteBuffer **list;
    NSUInteger   length;
}                        PGByteBufferList;
typedef PGByteBufferList *PGByteBufferListPtr;

@interface PGDynamicByteQueue()

    @property(readonly) NSUInteger     roomRemaining;
    @property(nullable) PGByteQueuePtr q;

@end

FOUNDATION_EXPORT PGByteQueuePtr PGCreateByteQueue(NSUInteger initialSize);

FOUNDATION_EXPORT void PGNormalizeByteQueue(PGByteQueuePtr q);

FOUNDATION_EXPORT void PGDestroyByteQueue(PGByteQueuePtr q, BOOL secure);

FOUNDATION_EXPORT NSUInteger PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta);

FOUNDATION_EXPORT BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2);

NS_INLINE NSUInteger PGByteQueueCount(PGByteQueuePtr q) {
    return (((q->qtail < q->qhead) ? (q->qtail + q->qsize) : q->qtail) - q->qhead);
}

NS_INLINE NSUInteger PGByteQueueRoomRemaining(PGByteQueuePtr q) {
    return (((q->qtail < q->qhead) ? (q->qhead - q->qtail) : (q->qsize - q->qtail + q->qhead)) - 1);
}

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERTOOLS_H
