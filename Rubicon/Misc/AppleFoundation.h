/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMatchLinux.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 08/30/18 11:03 AM
 * DESCRIPTION:
 *
 * Copyright © 2018  Project Galen. All rights reserved.
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
 *//************************************************************************/

#ifndef __PGMATCHLINUX_H__
#define __PGMATCHLINUX_H__

#include <stdlib.h>
#include <unistd.h>
#include <sys/cdefs.h>
#include <sys/types.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <Rubicon/PGCStringCache.h>

__BEGIN_DECLS

int getrandom_dev(void *buffer, size_t length, char blocking);

int getentropy_pseudo(void *buffer, size_t size);

__END_DECLS

#import <Foundation/NSObjCRuntime.h>
#if !__has_feature(nullability)
#   define nullable                     /**/
#endif
#if !__has_feature(nullability) || !defined(NS_ASSUME_NONNULL_BEGIN)
#   define NS_ASSUME_NONNULL_BEGIN      /**/
#   define NS_ASSUME_NONNULL_END        /**/
#   define _Nullable                    /**/
#endif
#ifndef NS_DESIGNATED_INITIALIZER
#   if __has_attribute(objc_designated_initializer)
#       define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#   else
#       define NS_DESIGNATED_INITIALIZER
#   endif
#endif

/* @f:0 */
#if defined(__APPLE__)

    #include <Availability.h>

    #if defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_12)
        #define __PG_DEFINE_GETENTROPY__ 1
    #endif

    #define __PG_DEFINE_GETRANDOM__ 1

    #ifndef TEMP_FAILURE_RETRY
        #define TEMP_FAILURE_RETRY(expression) ({ long int __result; do { __result = (long int) (expression); } while ((__result == -1L) && (errno == EINTR)); __result; })
    #endif

    #ifndef __PG_DEFINE_CLOCK_NANOSLEEP__
        #define __PG_DEFINE_CLOCK_NANOSLEEP__ 1
    #endif

#endif /* defined(__APPLE__) */
/* @f:1 */

#if defined(__PG_DEFINE_GETENTROPY__) && (__PG_DEFINE_GETENTROPY__)

extern unsigned char pg_getentropy_pseudo;

__BEGIN_DECLS

int getentropy(void *buffer, size_t size);

__END_DECLS

#endif /* defined(__PG_DEFINE_GETENTROPY__) && (__PG_DEFINE_GETENTROPY__) */

#if defined(__PG_DEFINE_GETRANDOM__) && (__PG_DEFINE_GETRANDOM__)

extern unsigned char pg_getrandom_strict;

typedef enum __pg_getrandom_flags {
    GRND_RANDOM = 1, GRND_NONBLOCK = 2
}                    PG_GETRANDOM_FLAGS;

__BEGIN_DECLS

/**
 * Get random bytes.
 *
 * @param buffer the buffer to fill with random bytes.
 * @param length the length of the buffer.
 * @param flags combination of the values of the enum __pg_getrandom_flags.
 * @return zero if successful.
 */
ssize_t getrandom(void *buffer, size_t length, unsigned int flags);

__END_DECLS

#endif /* defined(__PG_DEFINE_GETRANDOM__) && (__PG_DEFINE_GETRANDOM__) */

#if defined(__PG_DEFINE_CLOCK_NANOSLEEP__) && (__PG_DEFINE_CLOCK_NANOSLEEP__)

__BEGIN_DECLS

#ifndef TIMER_ABSTIME
    #define TIMER_ABSTIME 1
#endif

int clock_nanosleep(enum clockid_t clk_id, int flags, struct timespec *rqtp, struct timespec *rmtp);

__END_DECLS

#endif /* defined(__PG_DEFINE_CLOCK_NANOSLEEP__) && (__PG_DEFINE_CLOCK_NANOSLEEP__) */

#endif /* __PGMATCHLINUX_H__ */
