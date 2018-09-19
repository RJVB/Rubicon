/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTime.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/2/17 7:28 AM
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
 *//************************************************************************/
#ifndef __Rubicon_PGTime_H_
#define __Rubicon_PGTime_H_

#import <Rubicon/PGDefines.h>

typedef struct timespec TimeSpec;
typedef TimeSpec        *PTimeSpec;
typedef struct timeval  TimeVal;
typedef TimeVal         *PTimeVal;

#define PG_NANOS_PER_SECOND   UINT32_C(1000000000)
#define PG_NANOS_PER_MILLI    UINT32_C(1000000)
#define PG_NANOS_PER_MICRO    UINT32_C(1000)
#define PG_MICROS_PER_SECOND  UINT32_C(1000000)
#define PG_MICROS_PER_MILLI   UINT32_C(1000)
#define PG_MILLIS_PER_SECOND  UINT32_C(1000)

#define PG_DAYS_PER_YEAR      UINT32_C(365)
#define PG_HOURS_PER_DAY      UINT32_C(24)
#define PG_MINUTES_PER_HOUR   UINT32_C(60)
#define PG_SECONDS_PER_MINUTE UINT32_C(60)

#define PG_HOURS_PER_YEAR     (PG_HOURS_PER_DAY * PG_DAYS_PER_YEAR)
#define PG_MINUTES_PER_DAY    (PG_MINUTES_PER_HOUR * PG_HOURS_PER_DAY)
#define PG_MINUTES_PER_YEAR   (PG_MINUTES_PER_HOUR * PG_HOURS_PER_YEAR)
#define PG_SECONDS_PER_HOUR   (PG_SECONDS_PER_MINUTE * PG_MINUTES_PER_HOUR)
#define PG_SECONDS_PER_DAY    (PG_SECONDS_PER_MINUTE * PG_MINUTES_PER_DAY)
#define PG_SECONDS_PER_YEAR   (PG_SECONDS_PER_MINUTE * PG_MINUTES_PER_YEAR)

#define PG_MILLIS_PER_MINUTE  (((NSLong)(PG_MILLIS_PER_SECOND)) * ((NSLong)PG_SECONDS_PER_MINUTE))
#define PG_MILLIS_PER_HOUR    (((NSLong)(PG_MILLIS_PER_SECOND)) * ((NSLong)PG_SECONDS_PER_HOUR))
#define PG_MILLIS_PER_DAY     (((NSLong)(PG_MILLIS_PER_SECOND)) * ((NSLong)PG_SECONDS_PER_DAY))
#define PG_MILLIS_PER_YEAR    (((NSLong)(PG_MILLIS_PER_SECOND)) * ((NSLong)PG_SECONDS_PER_YEAR))

#define PG_MICROS_PER_MINUTE  (((NSLong)(PG_MICROS_PER_MILLI)) * ((NSLong)(PG_MILLIS_PER_MINUTE)))
#define PG_MICROS_PER_HOUR    (((NSLong)(PG_MICROS_PER_MILLI)) * ((NSLong)(PG_MILLIS_PER_HOUR)))
#define PG_MICROS_PER_DAY     (((NSLong)(PG_MICROS_PER_MILLI)) * ((NSLong)(PG_MILLIS_PER_DAY)))
#define PG_MICROS_PER_YEAR    (((NSLong)(PG_MICROS_PER_MILLI)) * ((NSLong)(PG_MILLIS_PER_YEAR)))

#define PG_NANOS_PER_MINUTE   (((NSLong)(PG_NANOS_PER_MICRO)) * ((NSLong)(PG_MICROS_PER_MINUTE)))
#define PG_NANOS_PER_HOUR     (((NSLong)(PG_NANOS_PER_MICRO)) * ((NSLong)(PG_MICROS_PER_HOUR)))
#define PG_NANOS_PER_DAY      (((NSLong)(PG_NANOS_PER_MICRO)) * ((NSLong)(PG_MICROS_PER_DAY)))
#define PG_NANOS_PER_YEAR     (((NSLong)(PG_NANOS_PER_MICRO)) * ((NSLong)(PG_MICROS_PER_YEAR)))

#define I64(i) ((NSLong)(i))
#define D64(d) ((NSFloat)(d))

#define PGTimeSpecZero(ts) (((ts).tv_sec == 0) && ((ts).tv_nsec == 0))

/**
 * Calculate the difference between two times. This function will populate the timespec structure passed in "diff" with the difference
 * in absolute values for seconds and nanoseconds. This function will also return a value to indicate if the two times are the same
 * (0), if "older" represents a time that occurred before "newer" (1), or if "older" represents a time that occurred after "newer"
 * (-1). In essence "older" is subtracted from "newer" then the sign is returned and the absolute values are put in "diff".
 *
 * @param older the first time presumed to be the older of the two (smaller values).
 * @param newer the second time presumed to be the newer of the two (larger values).
 * @param diff  the difference between the two in absolute values - seconds and nanoseconds. If this value is NULL then only the sign
 *              is returned.
 * @return 0    if the times are the same, 1 if "older" represents a time before "newer", -1 if "older" represents a time after
 *              "newer".
 */
FOUNDATION_EXPORT NSInteger PGTimeSpecDiff(PTimeSpec older, PTimeSpec newer, PTimeSpec diff);

FOUNDATION_EXPORT NSInteger PGTimeSpecAdd(PTimeSpec ts1, PTimeSpec ts2, PTimeSpec result);

FOUNDATION_EXPORT NSInteger PGRemainingTimeFromAbsoluteTime(PTimeSpec abstime, PTimeSpec result);

FOUNDATION_EXPORT NSInteger PGRealTimePlusTimeSpec(PTimeSpec ts, PTimeSpec result);

/**
 * Convert a time value to a long long int containing the number of nanoseconds.
 *
 * @param tv the time value.
 * @return the number of nanoseconds representing the time value as a long long int.
 */
NS_INLINE NSLong PGTimeValToNanos(PTimeVal tv) {
    return (tv ? ((I64(tv->tv_sec) * PG_NANOS_PER_SECOND) + (I64(tv->tv_usec) * PG_NANOS_PER_MICRO)) : 0);
}

/**
 * Convert the time given in nanoseconds to a time value (struct timeval).
 *
 * @param tv a pointer to a time value that will receive the converted time.
 * @param nanos a time in nanoseconds.
 * @return the pointer to the same time value structure.
 */
NS_INLINE PTimeVal PGNanosToTimeVal(PTimeVal tv, NSLong nanos) {
    if(!tv) {
        tv = (PTimeVal)malloc(sizeof(TimeVal));
    }

    if(tv) {
        tv->tv_sec  = (long)(nanos / PG_NANOS_PER_SECOND);
        tv->tv_usec = (int)((nanos % PG_NANOS_PER_SECOND) / PG_NANOS_PER_MICRO);
    }

    return tv;
}

/**
 * Convert a time specification to a long long int containing the number of nanoseconds.
 *
 * @param tp the time specification.
 * @return the number of nanoseconds representing the time specification as a long long int.
 */
NS_INLINE NSLong PGTimeSpecToNanos(const PTimeSpec tp) {
    return (NSLong)(tp ? ((I64(tp->tv_sec) * PG_NANOS_PER_SECOND) + I64(tp->tv_nsec)) : 0);
}

/**
 * Convert the time given in nanoseconds to a time specification (struct timespec).
 *
 * @param tp a pointer to a time specification that will receive the converted time.
 * @param nanos a time in nanoseconds.
 * @return the pointer to the same time specification structure.
 */
NS_INLINE PTimeSpec PGNanosToTimeSpec(PTimeSpec tp, NSLong nanos) {
    if(tp) {
        tp->tv_sec  = (long)(nanos / PG_NANOS_PER_SECOND);
        tp->tv_nsec = (long)(nanos % PG_NANOS_PER_SECOND);
    }

    return tp;
}

/**
 * Add the specified number of nanoseconds to the given time specifier.
 *
 * @param tp the time specifier.
 * @param nanos the number of nanoseconds to add to the time specifier. May be negative.
 * @return the time specifier.
 */
NS_INLINE PTimeSpec PGAddNanosToTimeSpec(PTimeSpec tp, NSLong nanos) {
    return PGNanosToTimeSpec(tp, (PGTimeSpecToNanos(tp) + nanos));
}

/**
 * Compare two time specifiers for order.
 *
 * @param tp1 the first time specifier
 * @param tp2 the second time specifier
 * @return NSOrderedSame if tp1 and tp2 represent the same time. NSOrderedAscending if tp1 occurs before
 *      tp2. NSOrderedDescending if tp1 occurs after tp2.
 */
NS_INLINE NSComparisonResult PGCompareTimeSpecs(PTimeSpec tp1, PTimeSpec tp2) {
    NSLong n1 = PGTimeSpecToNanos(tp1), n2 = PGTimeSpecToNanos(tp2);
    return (n1 < n2 ? NSOrderedAscending : (n1 > n2 ? NSOrderedDescending : NSOrderedSame));
}

/**
 * Compare two time values for order.
 *
 * @param tv1 the first time specifier
 * @param tv2 the second time specifier
 * @return NSOrderedSame if tv1 and tv2 represent the same time. NSOrderedAscending if tv1 occurs before
 *      tv2. NSOrderedDescending if tv1 occurs after tv2.
 */
NS_INLINE NSComparisonResult PGCompareTimeVals(PTimeVal tv1, PTimeVal tv2) {
    NSLong n1 = PGTimeValToNanos(tv1), n2 = PGTimeValToNanos(tv2);
    return (n1 < n2 ? NSOrderedAscending : (n1 > n2 ? NSOrderedDescending : NSOrderedSame));
}

/**
 * Get the current system cpu time in nano seconds. Generally speaking this is the number of
 * nanoseconds that have elapsed since the system was powered on or rebooted.
 *
 * @param delta additional nanoseconds to add to the time read from the system clock.
 * @return The value of the system clock plus any additional time.
 */
NSLong PGSystemCPUTime(NSLong delta);

/**
 * Get the current time in nano seconds. This time represents the number of nanoseconds since the
 * epoch (Midnight, January 1, 1970, UTC).
 *
 * @param delta additional nanoseconds to add to the time read from the system clock.
 * @return The value of the system clock plus any additional time.
 */
NSLong PGSystemRealTime(NSLong delta);

#if defined(__APPLE__) && defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 101200)

#define __MACH_TIME_IMP__ 1

typedef enum {
    CLOCK_REALTIME             = 0,
    CLOCK_MONOTONIC            = 6,
    CLOCK_MONOTONIC_RAW        = 4,
    CLOCK_MONOTONIC_RAW_APPROX = 5,
    CLOCK_UPTIME_RAW           = 8,
    CLOCK_UPTIME_RAW_APPROX    = 9,
    CLOCK_PROCESS_CPUTIME_ID   = 12,
    CLOCK_THREAD_CPUTIME_ID    = 16
} clockid_t;

/**
 * And, of course, for some reason, Mac OS X didn't have this function or it's associated defines
 * until version 10.12.
 */
int clock_gettime(clockid_t clk_id, PTimeSpec tp);

#elif defined(__MACH_TIME_IMP__)

    #undef __MACH_TIME_IMP__

#endif /* defined(__APPLE__) && defined(MAC_OS_X_VERSION_MAX_ALLOWED) && (MAC_OS_X_VERSION_MAX_ALLOWED < 101200) */
#endif /* defined(__Rubicon_PGTime_H_) */
