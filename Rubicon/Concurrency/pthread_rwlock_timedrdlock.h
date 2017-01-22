/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: pthread_rwlock_timedrdlock.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/21/16 3:19 PM
 *  VISIBILITY: Public
 * DESCRIPTION:
 *
 * Copyright © 2016 Galen Rhodes All rights reserved.
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

#ifndef pthread_rwlock_timedrdlock_h
#define pthread_rwlock_timedrdlock_h
#ifdef __APPLE__

#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>

__BEGIN_DECLS

/**************************************************************************************************//**
 * Mac OS X implementation of the POSIX sem_timedwait() function that is not included in Apple's
 * implementation.
 *
 * sem_timedwait() is the same as sem_wait(), except that abs_timeout specifies a
 * limit on the amount of time that the call should block if the decrement cannot be immediately
 * performed. The abs_timeout argument points to a structure that specifies an absolute timeout in
 * seconds and nanoseconds since the Epoch, 1970-01-01 00:00:00 +0000 (UTC).
 *
 * If the timeout has already expired by the time of the call, and the semaphore could not be
 * locked immediately, then sem_timedwait() fails with a timeout error (errno set to ETIMEDOUT).
 *
 * If the operation can be performed immediately, then sem_timedwait() never fails with a timeout
 * error, regardless of the value of abs_timeout. Furthermore, the validity of abs_timeout is not
 * checked in this case.
 *
 * @param sem the pointer to the semaphore handle.
 * @param abstime points to a structure that specifies an absolute timeout in seconds and
 *                    nanoseconds since the Epoch, 1970-01-01 00:00:00 +0000 (UTC).
 * @return 0 on success; on timeout, the value of the semaphore is left unchanged, -1 is returned,
 *         and errno will have the value ETIMEDOUT; on error, the value of the semaphore is left
 *         unchanged, -1 is returned, and errno is set to indicate the error.
 ******************************************************************************************************/
int sem_timedwait(sem_t *sem, const struct timespec *abstime);

int pthread_rwlock_timedrdlock(pthread_rwlock_t *rwlock, const struct timespec *abstime);

int pthread_rwlock_timedwrlock(pthread_rwlock_t *rwlock, const struct timespec *abstime);

__END_DECLS

#endif /* __APPLE__ */
#endif /* pthread_rwlock_timedrdlock_h */
