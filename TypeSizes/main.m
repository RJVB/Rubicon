/************************************************************************//**
 *     PROJECT: Rubicon
 *      TARGET: TypeSizes
 *    FILENAME: main.m
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

#import <Rubicon/Rubicon.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        struct timespec ts1;
        struct timespec ts2;
        struct timespec tr;
        struct timespec sl = { .tv_sec = 4, .tv_nsec = 500000000 };

        clock_gettime(CLOCK_REALTIME, &ts1);
        // sleep(4);
        nanosleep(&sl, NULL);
        clock_gettime(CLOCK_REALTIME, &ts2);

        PGTimeSpecDiff(&ts1, &ts2, &tr);

        printf("2> Seconds %11li; Nanos %9li\n", ts2.tv_sec, ts2.tv_nsec);
        printf("1> Seconds %11li; Nanos %9li\n", ts1.tv_sec, ts1.tv_nsec);
        printf("===========================================================\n");
        printf("   Seconds %11li; Nanos %9li\n", tr.tv_sec, tr.tv_nsec);
    }
    return 0;
}
