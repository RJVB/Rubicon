/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMatchLinux.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/30/16 11:03 AM
 * DESCRIPTION:
 *
 * Copyright © 2016  Project Galen. All rights reserved.
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

#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

#if defined(__APPLE__)

#if defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_12)
    #define __PG_INCLUDE_ENTROPY__ 1
#endif /* defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_12) */

#if defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 102000)
    #define __PG_INCLUDE_RANDOM__ 1
#endif /* defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 102000) */

#if defined(__PG_INCLUDE_ENTROPY__)

extern unsigned char pg_getentropy_pseudo;

__BEGIN_DECLS

int getentropy(void *buffer, size_t size);

__END_DECLS

#endif /* defined(__PG_INCLUDE_ENTROPY__) */

#if defined(__PG_INCLUDE_RANDOM__)

extern unsigned char pg_getrandom_strict;

typedef enum __pg_getrandom_flags {
    /*
     * Use the /dev/random (blocking) source instead of the /dev/urandom (non-blocking)
     * source to obtain randomness. If this flag is specified, the call may block,
     * potentially for quite some time, even after the randomness source has been
     * initialized. If it is not specified, the call can only block when the system
     * has just booted and the randomness source has not yet been initialized.
     */
            GRND_RANDOM   = 1,  //
    /*
     * Instead of blocking, return to the caller immediately if no data is available. This value is ignored.
     */
            GRND_NONBLOCK = 2 //
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

#endif /* defined(__PG_INCLUDE_RANDOM__) */

#endif /* defined(__APPLE__) */

#endif /* __PGMATCHLINUX_H__ */
