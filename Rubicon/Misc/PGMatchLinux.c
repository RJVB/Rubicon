/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMatchLinux.c
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

#include "PGMatchLinux.h"
#include <errno.h>
#include <fcntl.h>

#if !defined(__PG_INCLUDE_ENTROPY__)
    #include <sys/random.h>
#endif /* !defined(__PG_INCLUDE_ENTROPY__) */

#define ERRRETVAL (-1)

int __ret_errno(int _errno, int _ret) {
    errno = _errno;
    return _ret;
}

ssize_t __get_entropy(void *buffer, size_t offset, size_t length) {
    return (getentropy((buffer + offset), length) ? __ret_errno(((errno == ENOSYS || errno == EFAULT) ? errno : ENOSYS), ERRRETVAL) : 0);
}

#define PGGetEntropyPageSize   ((size_t)(256))
#define randsrc(b)             ((b) ? "/dev/random" : "/dev/urandom")

unsigned char pg_getrandom_strict = 0;

int __getrandom_normal(void *buffer, size_t length, const char *randsrc, int openflags) {
    size_t tr = 0;
    int    fd = open(randsrc, openflags, 0);

    if(fd < 0) return __ret_errno(((errno == EINTR) ? EINTR : ENOSYS), ERRRETVAL);

    do {
        ssize_t br = read(fd, (buffer + tr), (length - tr));
        if(br < 0) return (((errno == EAGAIN) || (errno == EINTR)) ? ERRRETVAL : __ret_errno(ENOSYS, ERRRETVAL));
        if(br == 0) return __ret_errno(ENOSYS, ERRRETVAL);
        tr += br;
    }
    while(tr < length);

    return 0;
}

ssize_t __getrandom_getentropy(void *buffer, size_t length) {
    size_t numberOfFullPages        = (length / PGGetEntropyPageSize);
    size_t numberOfBytesInFullPages = (numberOfFullPages * PGGetEntropyPageSize);

    for(size_t i = 0; i < numberOfFullPages; ++i) {
        if(__get_entropy(buffer, (i * PGGetEntropyPageSize), PGGetEntropyPageSize)) return ERRRETVAL;
    }

    if(__get_entropy(buffer, numberOfBytesInFullPages, (length - numberOfBytesInFullPages))) return ERRRETVAL;
    return 0;
}

ssize_t __getrandom(void *buffer, size_t length, char blkread, char blksrc) {
    return ((blkread || pg_getrandom_strict) ? __getrandom_normal(buffer, length, randsrc(blksrc), (blkread ? O_NONBLOCK : 0)) : __getrandom_getentropy(buffer, length));
}

#if defined(__PG_INCLUDE_ENTROPY__) && (__PG_INCLUDE_ENTROPY__)

unsigned char pg_getentropy_pseudo = 0;

int getentropy(void *buffer, size_t size) {
    if(pg_getentropy_pseudo) {
        srandom((unsigned int)(time(0) & 0xffffffff));
        int8_t *bbuf = buffer;

        for(size_t i = 0; i < size; ++i) bbuf[i] = (uint8_t)(random() & 0xff);
        return 0;
    }
    else {
        return __getrandom_normal(buffer, size, "/dev/urandom", O_NONBLOCK);
    }
}

#endif /* defined(__PG_INCLUDE_ENTROPY__) */

#if defined(__PG_INCLUDE_RANDOM__) && (__PG_INCLUDE_RANDOM__)

ssize_t getrandom(void *buffer, size_t length, unsigned int flags) {
    return (buffer ? (length ? __getrandom(buffer, length, ((flags & GRND_NONBLOCK) != 0), ((flags & GRND_RANDOM) != 0)) : 0) : __ret_errno(EFAULT, ERRRETVAL));
}

#endif /* defined(__PG_INCLUDE_RANDOM__) */

