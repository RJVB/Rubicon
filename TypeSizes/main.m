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
        const char *s1 = "a";
        const char *s2 = "b";
        int        c1  = strcmp(s1, s2);
        int        c2  = strcmp(s2, s1);

        printf("strcmp(\"%s\", \"%s\") = %d\n", s1, s2, c1);
        printf("strcmp(\"%s\", \"%s\") = %d\n", s2, s1, c2);
    }
    return 0;
}
