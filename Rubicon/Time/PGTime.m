/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTime.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/2/17 7:28 AM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
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
 */

#import "PGTime.h"

#if defined(__APPLE__)
mach_timebase_info_data_t machTimebaseInfo = { 0, 0 };
NSFloat                   machTimeFactor   = 0;

#if defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 101200)

/**
 * Get the current system clock monotonic time.
 *
 * @param tp The time specification record.
 */
NS_INLINE int clock_gettime_monotonic(PTimeSpec tp) {
    NSLong machNanos = PGSystemCPUTime(0);
    tp->tv_sec  = (__darwin_time_t)(machNanos / PG_NANOS_PER_SECOND);
    tp->tv_nsec = (long)(machNanos % PG_NANOS_PER_SECOND);
    return 0;
}

/**
 * Get the current system clock real time.
 *
 * @param tp The time specificatoin record.
 */
NS_INLINE int clock_gettime_realtime(PTimeSpec tp) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    tp->tv_sec  = tv.tv_sec;
    tp->tv_nsec = tv.tv_usec * 1000;
    return 0;
}

/**
 * Duplicates to some degree the same function as the Linux version.
 */
int clock_gettime(int clk_id, PTimeSpec tp) {
    if(tp) {
        switch(clk_id) {
            case CLOCK_MONOTONIC:
            case CLOCK_MONOTONIC_COARSE:
            case CLOCK_MONOTONIC_RAW:
                return clock_gettime_monotonic(tp);
            case CLOCK_REALTIME:
            case CLOCK_REALTIME_COARSE:
                return clock_gettime_realtime(tp);
            default:
                errno = EINVAL;
                break;
        }
    }
    else {
        errno = EFAULT;
    }

    return -1;
}

#endif
#endif
