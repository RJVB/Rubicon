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
 *//************************************************************************/

#import "PGInternal.h"

#if defined(__MACH_TIME_IMP__) && (__MACH_TIME_IMP__)

#import <mach/mach_time.h>
#import <sys/time.h>

static dispatch_once_t    machTimeFlag     = 0;
mach_timebase_info_data_t machTimebaseInfo = { 0, 0 };
NSFloat                   machTimeFactor   = 0;

NSLong PGSystemCPUTime(NSLong delta) {
    dispatch_once(&machTimeFlag, ^{
        mach_timebase_info(&machTimebaseInfo);
        machTimeFactor = (D64(machTimebaseInfo.numer) / D64(machTimebaseInfo.denom));
    });
    return (I64(D64(mach_absolute_time()) * machTimeFactor) + delta);
}

NSLong PGSystemRealTime(NSLong delta) {
    TimeVal tv;
    gettimeofday(&tv, NULL);
    return (PGTimeValToNanos(&tv) + delta);
}

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
int clock_gettime(clockid_t clk_id, PTimeSpec tp) {
    if(tp) {
        switch(clk_id) {
            case CLOCK_MONOTONIC:
            case CLOCK_MONOTONIC_RAW_APPROX:
            case CLOCK_MONOTONIC_RAW:
            case CLOCK_PROCESS_CPUTIME_ID:
            case CLOCK_THREAD_CPUTIME_ID:
                return clock_gettime_monotonic(tp);
            case CLOCK_REALTIME:
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

#else

NSLong PGSystemRealTime(NSLong delta) {
    TimeSpec tm = { 0, 0 };

    if(clock_gettime(CLOCK_REALTIME, &tm)) {
        @throw [NSException exceptionWithName:NSGenericException reason:PGStrError(errno) userInfo:nil];
    }

    return (PGTimeSpecToNanos(&tm) + delta);
}

NSLong PGSystemCPUTime(NSLong delta) {
    TimeSpec tm = { 0, 0 };

    if(clock_gettime(CLOCK_MONOTONIC_RAW, &tm)) {
        @throw [NSException exceptionWithName:NSGenericException reason:PGStrError(errno) userInfo:nil];
    }

    return (PGTimeSpecToNanos(&tm) + delta);
}

#endif /* defined(__MACH_TIME_IMP__) && (__MACH_TIME_IMP__) */

NS_INLINE void __pg_tsdiff(PTimeSpec ts1, PTimeSpec ts2, PTimeSpec r) {
    long ts1ns = ts1->tv_nsec;
    long ts2ns = ts2->tv_nsec;

    r->tv_sec = (ts2->tv_sec - ts1->tv_sec);
    if(ts2ns < ts1ns) {
        --r->tv_sec;
        ts2ns += PG_NANOS_PER_SECOND;
    }
    r->tv_nsec = (ts2ns - ts1ns);
}

NSInteger PGTimeSpecDiff(PTimeSpec older, PTimeSpec newer, PTimeSpec diff) {
    BOOL sames = (older->tv_sec == newer->tv_sec);

    if(sames && (older->tv_nsec == newer->tv_nsec)) {
        if(diff) memset(diff, 0, sizeof(TimeSpec));
        return 0;
    }
    else {
        BOOL      secsorder  = older->tv_sec < newer->tv_sec;
        BOOL      nsecsorder = older->tv_nsec < newer->tv_nsec;
        NSInteger sign       = (sames ? (nsecsorder ? 1 : -1) : (secsorder ? 1 : -1));
        // +-------+------------+-----------+-------+
        // | sames | nsecsorder | secsorder |  sign |
        // +-------+------------+-----------+-------+
        // |  YES  |    YES     |     x     |   1   |
        // |  YES  |    YES     |     x     |   1   |
        // |  YES  |     NO     |     x     |  -1   |
        // |  YES  |     NO     |     x     |  -1   |
        // |   NO  |     x      |    YES    |   1   |
        // |   NO  |     x      |    YES    |   1   |
        // |   NO  |     x      |     NO    |  -1   |
        // |   NO  |     x      |     NO    |  -1   |
        // +-------+------------+-----------+-------+
        if(diff) {
            memset(diff, 0, sizeof(TimeSpec));

            if(sign) {
                if(sames) diff->tv_nsec = (nsecsorder ? (newer->tv_nsec - older->tv_nsec) : (older->tv_nsec - newer->tv_nsec));
                else if(secsorder) __pg_tsdiff(older, newer, diff);
                else __pg_tsdiff(newer, older, diff);
            }
        }

        return sign;
    }
}

NSInteger PGTimeSpecAdd(PTimeSpec ts1, PTimeSpec ts2, PTimeSpec result) {
    if(ts1 && ts2 && result) {
        long nanos = (ts1->tv_nsec + ts2->tv_nsec);
        result->tv_sec  = (ts1->tv_sec + ts2->tv_sec + (nanos / PG_NANOS_PER_SECOND));
        result->tv_nsec = (nanos % PG_NANOS_PER_SECOND);
        return 0;
    }

    errno = EFAULT;
    return -1;
}

NSInteger PGRealTimePlusTimeSpec(PTimeSpec ts, PTimeSpec result) {
    if(result && ts) {
        TimeSpec tnow;
        clock_gettime(CLOCK_REALTIME, &tnow);
        return PGTimeSpecAdd(ts, &tnow, result);
    }

    errno = EFAULT;
    return -1;
}

NSInteger PGRemainingTimeFromAbsoluteTime(PTimeSpec abstime, PTimeSpec result) {
    if(abstime && result) {
        TimeSpec ts;
        if(clock_gettime(CLOCK_REALTIME, &ts)) return -1;
        if(PGTimeSpecDiff(&ts, abstime, result) < 0) memset(result, 0, sizeof(TimeSpec));
        return 0;
    }

    errno = EFAULT;
    return -1;
}

