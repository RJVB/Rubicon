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
    NSBytePtr  qbuffer;
}                        PGByteQueue;
typedef PGByteQueue      *PGByteQueuePtr;

typedef struct {
    NSBytePtr  bytes;
    NSUInteger length;
    NSUInteger aux1;
    NSUInteger aux2;
}                        PGByteBuffer;
typedef PGByteBuffer     *PGByteBufferPtr;

typedef struct {
    PGByteBufferPtr *list;
    NSUInteger      length;
}                        PGByteBufferList;
typedef PGByteBufferList *PGByteBufferListPtr;

@interface PGDynamicByteQueue()

    -(instancetype)initWithByteQueue:(const PGByteQueuePtr)byteQueue NS_DESIGNATED_INITIALIZER;

    -(void)_createBuffer:(NSUInteger)initialSize;

    -(void)_ensureSize:(NSUInteger)length;

    -(NSInteger)_performOperation:(PGDynamicByteBufferOpBlock)opBlock byteQueue:(PGByteQueuePtr)queue error:(NSError **)error;

    -(NSInteger)_performOperation:(PGDynamicByteBufferOpBlock)opBlock error:(NSError **)error;

    -(void)_tryShrink;

    -(NSBytePtr)_getBytes:(NSUInteger)len;
@end

#define QCOUNT(q)     ((((q)->qhead)<=((q)->qtail))?(((q)->qtail)-((q)->qhead)):((((q)->qsize)-((q)->qhead))+((q)->qtail)))
#define QEMPTY(q)     (((q)->qhead)==((q)->qtail))
#define QNOTEMPTY(q)  (((q)->qhead)!=((q)->qtail))
#define QWRAPPED(q)   (((q)->qtail)<((q)->qhead))
#define QPTR(q, d)    (((q)->qbuffer)+(d))
#define QHEADP(q)     (((q)->qbuffer)+((q)->qhead))
#define QTAILP(q)     (((q)->qbuffer)+((q)->qtail))
#define QSZHD(q)      (((q)->qsize)-((q)->qhead))
#define QTLHD(q)      (((q)->qtail)-((q)->qhead))

// @f:0
NS_INLINE NSUInteger umin(NSUInteger i1, NSUInteger i2)                  { return ((i1 <= i2) ? i1 : i2);                         }
NS_INLINE NSUInteger umax(NSUInteger i1, NSUInteger i2)                  { return ((i1 <= i2) ? i2 : i1);                         }

NS_INLINE NSUInteger qPreAdd(NSUInteger *i, NSUInteger d, NSUInteger s)  { return (*i) = (((*i) + d) % s);                        }
NS_INLINE NSUInteger qPreSub(NSUInteger *i, NSUInteger d, NSUInteger s)  { return (*i) = (((d <= (*i)) ? (*i) : (s + (*i))) - d); }
NS_INLINE NSUInteger qPostAdd(NSUInteger *i, NSUInteger d, NSUInteger s) { NSUInteger j = (*i); qPreAdd(i, d, s); return j;       }
NS_INLINE NSUInteger qPostSub(NSUInteger *i, NSUInteger d, NSUInteger s) { NSUInteger j = (*i); qPreSub(i, d, s); return j;       }

NS_INLINE NSUInteger qHeadPostAdd(PGByteQueuePtr q, NSUInteger d)        { return qPostAdd(&q->qhead, d, q->qsize);               }
NS_INLINE NSUInteger qTailPostAdd(PGByteQueuePtr q, NSUInteger d)        { return qPostAdd(&q->qtail, d, q->qsize);               }
NS_INLINE NSUInteger qTailPreSub(PGByteQueuePtr q, NSUInteger d)         { return qPreSub(&q->qtail, d, q->qsize);                }
NS_INLINE NSUInteger qHeadPreSub(PGByteQueuePtr q, NSUInteger d)         { return qPreSub(&q->qhead, d, q->qsize);                }

NS_INLINE NSBytePtr qHeadPreSubP(PGByteQueuePtr q, NSUInteger d)         { return (q->qbuffer + qHeadPreSub(q, d));               }
NS_INLINE NSBytePtr qTailPreSubP(PGByteQueuePtr q, NSUInteger d)         { return (q->qbuffer + qTailPreSub(q, d));               }
NS_INLINE NSBytePtr qHeadPostAddP(PGByteQueuePtr q, NSUInteger d)        { return (q->qbuffer + qHeadPostAdd(q, d));              }
NS_INLINE NSBytePtr qTailPostAddP(PGByteQueuePtr q, NSUInteger d)        { return (q->qbuffer + qTailPostAdd(q, d));              }
// @f:1

PGByteQueuePtr qCreateNewBuffer(NSUInteger initialSize, NSUInteger currentSize);

PGByteQueuePtr qCreateExactCopy(const PGByteQueuePtr q);

PGByteQueuePtr qCreateNormalizedCopy(const PGByteQueuePtr q);

PGByteQueuePtr qCopyQueueData(PGByteQueuePtr dest, const PGByteQueuePtr src);

PGByteQueuePtr _Nullable qDestroyQueue(PGByteQueuePtr q);

NSUInteger qCalculateHash(const PGByteQueuePtr q);

BOOL qCompareQueues(const PGByteQueuePtr q1, const PGByteQueuePtr q2);

NSUInteger qNextSize(NSUInteger needed, NSUInteger newSize);

void qTryGrow(PGByteQueuePtr q, NSUInteger needed);

void qTryShrink(PGByteQueuePtr q);

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERTOOLS_H
