/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMatchLinux.c
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

#include "AppleFoundation.h"
#include <math.h>

int __ret_errno(int _errno, int _ret);

int __getrandom_dev(void *buffer, size_t length, const char *rndsrc, int openflags);

#if defined(__PG_DEFINE_GETENTROPY__) && (__PG_DEFINE_GETENTROPY__)
// #if defined(DEBUG) && (DEBUG)

unsigned char pg_getentropy_pseudo = 0;

int getentropy(void *buffer, size_t size) {
    if(pg_getentropy_pseudo) {
        return getentropy_pseudo(buffer, size);
    }
    else {
        return __getrandom_dev(buffer, size, "/dev/urandom", O_NONBLOCK);
    }
}

#else

    #include <sys/random.h>

#endif /* defined(__PG_DEFINE_GETENTROPY__) && (__PG_DEFINE_GETENTROPY__) */

#if defined(__PG_DEFINE_GETRANDOM__) && (__PG_DEFINE_GETRANDOM__)

#define PGGetEntropyPageSize   ((size_t)(256))
#define randsrc(b)             ((b) ? "/dev/random" : "/dev/urandom")
#define ERRRETVAL              (-1)

unsigned char pg_getrandom_strict = 0;

ssize_t __get_entropy(void *buffer, size_t offset, size_t length) {
    return (getentropy((buffer + offset), length) ? __ret_errno(((errno == ENOSYS || errno == EFAULT) ? errno : ENOSYS), ERRRETVAL) : 0);
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

ssize_t getrandom(void *buffer, size_t length, unsigned int flags) {
    if(buffer) {
        if(length) {
            char blkread = ((flags & GRND_NONBLOCK) == GRND_NONBLOCK);
            char blksrc  = ((flags & GRND_RANDOM) == GRND_RANDOM);
            if(blkread || pg_getrandom_strict) {
                char *src   = randsrc(blksrc);
                int  oflags = (blkread ? O_NONBLOCK : 0);
                return __getrandom_dev(buffer, length, src, oflags);
            }
            return __getrandom_getentropy(buffer, length);
        }
        return 0;
    }
    return __ret_errno(EFAULT, ERRRETVAL);
}

#endif /* defined(__PG_DEFINE_GETRANDOM__) && (__PG_DEFINE_GETRANDOM__) */

int __ret_errno(int _errno, int _ret) {
    errno = _errno;
    return _ret;
}

int __getrandom_dev(void *buffer, size_t length, const char *rndsrc, int openflags) {
    size_t tr = 0;
    int    fd = open(rndsrc, openflags, 0);

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

int getrandom_dev(void *buffer, size_t length, char blocking) {
    return __getrandom_dev(buffer, length, randsrc(blocking), 0);
}

int getentropy_pseudo(void *buffer, size_t size) {
    uint8_t        *bbuf = buffer;
    unsigned short rstate[3];
    long           t     = time(0);

#if defined(__SIZEOF_LONG__) && (__SIZEOF_LONG__ >= 6)
    rstate[0] = (unsigned short)((t & 0x0000ffff00000000) >> 32);
    rstate[1] = (unsigned short)((t & 0x00000000ffff0000) >> 16);
    rstate[2] = (unsigned short)((t & 0x000000000000ffff));
#else
    rstate[0] = (unsigned short)((t & 0xffff0000) >> 16);
    rstate[1] = (unsigned short)((t & 0x0000ffff));
    rstate[2] = (unsigned short)((time(0) & 0x0000ffff));
#endif

    for(size_t i = 0; i < size; ++i) *(bbuf++) = (uint8_t)(((unsigned long)(floor(erand48(rstate) * 256.0))) & 0x00ff);
    return 0;
}

#if defined(__PG_DEFINE_CLOCK_NANOSLEEP__) && (__PG_DEFINE_CLOCK_NANOSLEEP__)

int clock_nanosleep(clockid_t clk_id, int flags, struct timespec *rqtp, struct timespec *rmtp) {
    if((flags & TIMER_ABSTIME) == TIMER_ABSTIME) {
        struct timespec ts;

        /*
         * Make sure we got a value.
         */
        if(!rqtp) return __ret_errno(EFAULT, -1);

        /*
         * Make sure the nano seconds are in the proper range.
         */
        if(rqtp->tv_nsec < 0 || rqtp->tv_nsec > 999999999) return __ret_errno(EINVAL, -1);

        /*
         * Get the current real-time.
         */
        if(clock_gettime(CLOCK_REALTIME, &ts)) return -1;

        /*
         * See if we've already passed the wanted time.
         */
        if((ts.tv_sec > rqtp->tv_sec) || ((ts.tv_sec == rqtp->tv_sec) && (ts.tv_nsec >= rqtp->tv_nsec))) return 0;

        /*
         * Calculate the remaining time.
         */
        struct timespec t1 = { .tv_sec = (rqtp->tv_sec - ts.tv_sec), .tv_nsec = (rqtp->tv_nsec - ts.tv_nsec) };

        /*
         * Look for underflow.
         */
        if(t1.tv_nsec < 0) {
            t1.tv_sec--;
            t1.tv_nsec += 1000000000;
        }

        /*
         * Sleep...
         */
        return nanosleep(&t1, rmtp);
    }

    return nanosleep(rqtp, rmtp);
}

#endif // defined(__PG_DEFINE_CLOCK_NANOSLEEP__) && (__PG_DEFINE_CLOCK_NANOSLEEP__)
