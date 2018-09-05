/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDynamicBufferTools.h
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

#ifndef RUBICON_PGDYNAMICBUFFERTOOLS_H
#define RUBICON_PGDYNAMICBUFFERTOOLS_H

#import <Rubicon/PGDefines.h>

NS_ASSUME_NONNULL_BEGIN

/****************************************************************************************************************
 * BYTE BUFFERS
 ***************************************************************************************************************/
#pragma mark BYTE BUFFERS

typedef struct {
    NSByte     *bytes;
    NSUInteger length;
    NSUInteger size;
    NSUInteger aux1;
    NSUInteger aux2;
}                                  PGByteBuffer;
typedef PGByteBuffer               *PGByteBufferPtr;

typedef struct {
    PGByteBuffer **list;
    NSUInteger   length;
}                                  PGByteBufferList;
typedef PGByteBufferList           *PGByteBufferListPtr;

FOUNDATION_EXPORT PGByteBufferPtr PGByteBufferCreate(NSUInteger size) PG_OVERLOADABLE;

FOUNDATION_EXPORT PGByteBufferPtr PGByteBufferCreate(NSByte *bytes, NSUInteger length) PG_OVERLOADABLE;

FOUNDATION_EXPORT PGByteBufferPtr PGByteBufferCreate(NSData *data, NSUInteger length) PG_OVERLOADABLE;

FOUNDATION_EXPORT PGByteBufferPtr PGByteBufferCreate(NSData *data) PG_OVERLOADABLE;

FOUNDATION_EXPORT PGByteBufferPtr PGByteBufferResize(PGByteBufferPtr b, NSUInteger size);

FOUNDATION_EXPORT PGByteBufferPtr PGByteBufferCopy(PGByteBufferPtr b);

FOUNDATION_EXPORT void PGByteBufferDestroy(PGByteBufferPtr bb, BOOL secure);

FOUNDATION_EXPORT BOOL PGByteBufferCompare(PGByteBufferPtr b1, PGByteBufferPtr b2);

FOUNDATION_EXPORT NSUInteger PGByteBufferHash(PGByteBufferPtr b);

FOUNDATION_EXPORT NSData *PGByteBufferGetNSData(PGByteBufferPtr b, NSUInteger maxLength) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSData *PGByteBufferGetNSData(PGByteBufferPtr b) PG_OVERLOADABLE;

/****************************************************************************************************************
 * BYTE QUEUES
 ***************************************************************************************************************/
#pragma mark BYTE QUEUES

FOUNDATION_EXPORT const NSUInteger PGByteQueueDefaultInitialSize;
FOUNDATION_EXPORT const NSUInteger PGByteQueueMinSize;

typedef struct {
    NSUInteger qinit; // The initial size of the queue.
    NSUInteger qsize; // The current size of the queue.
    NSUInteger qhead;
    NSUInteger qtail;
    NSUInteger aux1;
    NSUInteger aux2;
    NSByte     *qbuffer;
}                                  PGByteQueue;
typedef PGByteQueue                *PGByteQueuePtr;

// @f:0
NS_INLINE NSUInteger PGByteQueueCount(const PGByteQueuePtr q)         { return (q ? (((q->qtail < q->qhead) ? (q->qtail + q->qsize) : q->qtail) - q->qhead) : 0); }
NS_INLINE NSUInteger PGByteQueueRoomRemaining(const PGByteQueuePtr q) { return (q ? (q->qsize - PGByteQueueCount(q) - 1) : 0); }
//@f:1

FOUNDATION_EXPORT PGByteQueuePtr PGByteQueueCreate(NSUInteger initialSize);

FOUNDATION_EXPORT PGByteQueuePtr PGByteQueueCopy(PGByteQueuePtr dest, PGByteQueuePtr src);

FOUNDATION_EXPORT void PGByteQueueShrink(PGByteQueuePtr q);

FOUNDATION_EXPORT PGByteQueuePtr PGByteQueueEnsureRoom(PGByteQueuePtr q, NSUInteger delta);

FOUNDATION_EXPORT BOOL PGByteQueueCompare(PGByteQueuePtr q1, PGByteQueuePtr q2);

FOUNDATION_EXPORT void PGByteQueueDestroy(PGByteQueuePtr q, BOOL secure);

FOUNDATION_EXPORT void PGByteQueueQueue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE;

/********************************************************************************************************//**
 * This method will throw a NULL pointer exception if either 'q' or 'buffer' is NULL unless length is zero.
 *
 * @param q the queue to receive the bytes.
 * @param buffer the bytes to queue.
 * @param length the number of bytes to queue.
 *//********************************************************************************************************/
FOUNDATION_EXPORT void PGByteQueueQueue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE;

FOUNDATION_EXPORT void PGByteQueueRequeue(PGByteQueuePtr q, NSByte byte) PG_OVERLOADABLE;

FOUNDATION_EXPORT void PGByteQueueRequeue(PGByteQueuePtr q, const NSByte *buffer, NSUInteger length) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSInteger PGByteQueueDequeue(PGByteQueuePtr q) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSUInteger PGByteQueueDequeue(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSInteger PGByteQueuePop(PGByteQueuePtr q) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSUInteger PGByteQueuePop(PGByteQueuePtr q, NSByte *buffer, NSUInteger maxLength) PG_OVERLOADABLE;

FOUNDATION_EXPORT PGByteBufferPtr PGByteQueueGetByteBuffer(PGByteQueuePtr q, NSUInteger length) PG_OVERLOADABLE;

FOUNDATION_EXPORT PGByteBufferPtr PGByteQueueGetByteBuffer(PGByteQueuePtr q) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSString *PGByteQueueGetNSString(PGByteQueuePtr q) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSString *PGByteQueueGetNSString(PGByteQueuePtr q, NSStringEncoding encoding) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSString *PGByteQueueGetNSString(PGByteQueuePtr q, NSStringEncoding encoding, NSUInteger length) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSData *PGByteQueueGetNSData(PGByteQueuePtr q, NSUInteger length) PG_OVERLOADABLE;

FOUNDATION_EXPORT NSData *PGByteQueueGetNSData(PGByteQueuePtr q) PG_OVERLOADABLE;

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDYNAMICBUFFERTOOLS_H
