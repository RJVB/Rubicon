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
        unsigned long len = 15;
        PGPrintf(@"+-%@-+----+\n", [@"" stringByPaddingToLength:len withString:@"-" startingAtIndex:0]);
        PGPrintf(@"| %@ |Size|\n", [@"Data Type" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0]);
        PGPrintf(@"+-%@-+----+\n", [@"" stringByPaddingToLength:len withString:@"-" startingAtIndex:0]);
        PGPrintf(@"| %@ | %2zu |\n", [@"char" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(char));
        PGPrintf(@"| %@ | %2zu |\n", [@"short" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(short));
        PGPrintf(@"| %@ | %2zu |\n", [@"int" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(int));
        PGPrintf(@"| %@ | %2zu |\n", [@"long" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(long));
        PGPrintf(@"| %@ | %2zu |\n", [@"long long" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(long long));
        PGPrintf(@"| %@ | %2zu |\n", [@"float" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(float));
        PGPrintf(@"| %@ | %2zu |\n", [@"double" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(double));
        PGPrintf(@"| %@ | %2zu |\n", [@"long double" stringByCenteringInPaddingOfLength:len withString:@" " startingAtIndex:0], sizeof(long double));
        PGPrintf(@"+-%@-+----+\n", [@"" stringByPaddingToLength:len withString:@"-" startingAtIndex:0]);
    }
    return 0;
}
