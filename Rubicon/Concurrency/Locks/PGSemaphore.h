/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSemaphore.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/11/17 2:31 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017  Project Galen. All rights reserved.
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
 *******************************************************************************/

#ifndef __Rubicon_PGSemaphore_H_
#define __Rubicon_PGSemaphore_H_

#import "PGTools.h"

@class PGTimeSpec;

@interface PGSemaphore : NSObject

	@property(nonatomic, readonly) NSUInteger     value;
	@property(nonatomic, readonly, copy) NSString *name;

	-(instancetype)initWithSemaphoreName:(NSString *)name value:(NSUInteger)value;

	+(instancetype)semaphoreWithName:(NSString *)name value:(NSUInteger)value;

	-(BOOL)isOpen;

	-(void)close;

	-(void)post;

	-(void)wait;

	-(BOOL)tryWait;

	/**************************************************************************************************//**
	 * Mimics the POSIX sem_timedwait(2p) function.
	 *
	 * This method shall lock the semaphore referenced by this object as in the wait method. However, if
	 * the semaphore cannot be locked without waiting for another process or thread to unlock the semaphore
	 * by calling the post method, this wait shall be terminated when the specified timeout expires.
	 *
     * The timeout shall expire when the absolute time specified by abstime passes, as measured by the
     * clock on which timeouts are based (that is, when the value of that clock equals or exceeds abstime),
     * or if the absolute time specified by abstime has already been passed at the time of the call.
	 *
     * The timeout shall be based on the CLOCK_REALTIME clock.  The resolution of the timeout shall be the
     * resolution of the clock on which it is based. The timespec data type is defined as a structure in
     * the <time.h> header.
	 *
     * Under no circumstance shall the function fail with a timeout if the semaphore can be locked
     * immediately. The validity of the abstime need not be checked if the semaphore can be locked
     * immediately.
     *
     * For more details see: http://man7.org/linux/man-pages/man3/sem_timedwait.3p.html
	 *
	 * @param abstime The absolute time, based on the wall clock, that this method will timeout waiting.
	 * @return YES if it was able to successfully lock the semaphore before the timeout occurred.
	 * @see http://man7.org/linux/man-pages/man3/sem_timedwait.3p.html
	 ******************************************************************************************************/
	-(BOOL)timedWait:(PGTimeSpec *)abstime;

@end

#endif //__Rubicon_PGSemaphore_H_
