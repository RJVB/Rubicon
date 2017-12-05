//
//  TypeSizes.c
//  TypeSizes
//
//  Created by Galen Rhodes on 1/14/17.
//  Copyright © 2017 Project Galen. All rights reserved.
//

#include <stdio.h>

int main(int argc, const char *argv[]) {
    printf("\nSize of     char    : %lu", (unsigned long)sizeof(char));
    printf("\nSize of    short    : %lu", (unsigned long)sizeof(short));
    printf("\nSize of     int     : %lu", (unsigned long)sizeof(int));
    printf("\nSize of     long    : %lu", (unsigned long)sizeof(long));
    printf("\nSize of  long long  : %lu", (unsigned long)sizeof(long long));
    printf("\nSize of    float    : %lu", (unsigned long)sizeof(float));
    printf("\nSize of    double   : %lu", (unsigned long)sizeof(double));
    printf("\nSize of long double : %lu\n\n", (unsigned long)sizeof(long double));
	return 0;
}
