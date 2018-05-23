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

typedef struct {
    NSByte     *bytes;
    NSUInteger length;
    NSUInteger aux1;
    NSUInteger aux2;
}                        PGByteBuffer;

typedef struct {
    PGByteBuffer **list;
    NSUInteger   length;
}                        PGByteBufferList;

@interface PGDynamicByteQueue()

    -(instancetype)initWithByteQueue:(const PGByteQueue *)byteQueue NS_DESIGNATED_INITIALIZER;

    -(void)_createBuffer:(NSUInteger)initialSize;

    -(void)_ensureSize:(NSUInteger)length;

    -(NSInteger)_performOperation:(PGDynamicByteBufferOpBlock)opBlock byteQueue:(PGByteQueue *)queue error:(NSError **)error;

    -(NSInteger)_performOperation:(PGDynamicByteBufferOpBlock)opBlock error:(NSError **)error;

    -(void)_tryShrink;

    -(NSByte *)_getBytes:(NSUInteger)len;
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

NS_INLINE NSUInteger qHeadPostAdd(PGByteQueue *q, NSUInteger d)        { return qPostAdd(&q->qhead, d, q->qsize);               }
NS_INLINE NSUInteger qTailPostAdd(PGByteQueue *q, NSUInteger d)        { return qPostAdd(&q->qtail, d, q->qsize);               }
NS_INLINE NSUInteger qTailPreSub(PGByteQueue *q, NSUInteger d)         { return qPreSub(&q->qtail, d, q->qsize);                }
NS_INLINE NSUInteger qHeadPreSub(PGByteQueue *q, NSUInteger d)         { return qPreSub(&q->qhead, d, q->qsize);                }

NS_INLINE NSByte *qHeadPreSubP(PGByteQueue *q, NSUInteger d)         { return (q->qbuffer + qHeadPreSub(q, d));               }
NS_INLINE NSByte *qTailPreSubP(PGByteQueue *q, NSUInteger d)         { return (q->qbuffer + qTailPreSub(q, d));               }
NS_INLINE NSByte *qHeadPostAddP(PGByteQueue *q, NSUInteger d)        { return (q->qbuffer + qHeadPostAdd(q, d));              }
NS_INLINE NSByte *qTailPostAddP(PGByteQueue *q, NSUInteger d)        { return (q->qbuffer + qTailPostAdd(q, d));              }
// @f:1

PGByteQueue *qCreateNewBuffer(NSUInteger initialSize, NSUInteger currentSize);

PGByteQueue *qCreateExactCopy(const PGByteQueue *q);

PGByteQueue *qCreateNormalizedCopy(const PGByteQueue *q);

PGByteQueue *qCopyQueueData(PGByteQueue *dest, const PGByteQueue *src);

PGByteQueue *_Nullable qDestroyQueue(PGByteQueue *q);

NSUInteger qCalculateHash(const PGByteQueue *q);

BOOL qCompareQueues(const PGByteQueue *q1, const PGByteQueue *q2);

NSUInteger qNextSize(NSUInteger needed, NSUInteger newSize);

void qTryGrow(PGByteQueue *q, NSUInteger needed);

void qTryShrink(PGByteQueue *q);

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERTOOLS_H
