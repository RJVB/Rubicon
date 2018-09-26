/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCStringCache.c
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/21/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
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

#include "PGCStringCache.h"
#include <string.h>
#include <math.h>
#include <errno.h>

void *xmalloc(size_t size) {
    void *mem = malloc(size);
    if(mem == NULL) errno = ENOMEM;
    return mem;
}

char *xstrdup(const char *str) {
    if(str) {
        char *nstr = strdup(str);
        if(nstr == NULL) errno = ENOMEM;
        return nstr;
    }
    return NULL;
}

int initializeCString(CString *cstrs, const char *s) {
    cstrs->cStringsSize = CSTRINGS_INIT_LENGTH;
    cstrs->cStrings     = xmalloc(cstrs->cStringsSize * sizeof(char *));

    if(cstrs->cStrings) {
        cstrs->cStringsStart = cstrs->cStringsEnd = (cstrs->cStringsSize / 2);
        char *str = xstrdup(s);

        if(str) {
            cstrs->cStrings[cstrs->cStringsEnd++] = str;
            return 0;
        }
    }

    return -1;
}

int binarySearchCStrings(const char *s, char **cStrings, size_t i1, size_t i2, size_t *idx) {
    if(i1 < i2) {
        size_t ic = (i1 + ((i2 - i1) / 2));
        int    cc = strcmp(s, cStrings[ic]);

        if(cc < 0) return binarySearchCStrings(s, cStrings, i1, ic, idx);
        else if(cc > 0) return binarySearchCStrings(s, cStrings, (ic + 1), i2, idx);
        else {
            if(idx) *idx = ic;
            return 0;
        }
    }

    if(idx) *idx = i1;
    return -1;
}

int findCString(CString *cstrs, const char *s, size_t *idx) {
    return binarySearchCStrings(s, cstrs->cStrings, cstrs->cStringsStart, cstrs->cStringsEnd, idx);
}

int storeCString(CString *cstrs, const char *str) {
    if(str) {
        if(cstrs->cStringsSize) {
            size_t idx = 0;

            if(findCString(cstrs, str, &idx)) {
                char *s = strdup(str);
                if(s == NULL) return -1;

                if((cstrs->cStringsStart == 0) && (cstrs->cStringsSize == cstrs->cStringsEnd)) {
                    // We're out of room. Make more.
                    size_t ns   = (size_t)ceil(cstrs->cStringsSize * 1.5);
                    char   **nb = xmalloc(ns * sizeof(char *));
                    if(nb == NULL) return -1;

                    cstrs->cStringsStart = ((ns - cstrs->cStringsSize) / 2);
                    memcpy(&nb[cstrs->cStringsStart], cstrs->cStrings, cstrs->cStringsSize);
                    free(cstrs->cStrings);
                    idx += cstrs->cStringsStart;

                    cstrs->cStrings     = nb;
                    cstrs->cStringsSize = ns;
                    cstrs->cStringsEnd += cstrs->cStringsStart;
                }

                size_t above   = (cstrs->cStringsEnd - idx);
                size_t below   = (idx - cstrs->cStringsStart);
                char   movdown = ((below < above) || (cstrs->cStringsSize == cstrs->cStringsEnd));

                if(movdown) {
                    size_t p = cstrs->cStringsStart--;
                    idx--;
                    memmove(&cstrs->cStrings[cstrs->cStringsStart], &cstrs->cStrings[p], below);
                }
                else {
                    cstrs->cStringsEnd++;
                    memmove(&cstrs->cStrings[idx], &cstrs->cStrings[idx + 1], above);
                }

                cstrs->cStrings[idx] = s;
            }
        }
        else {
            return initializeCString(cstrs, str);
        }
    }
    return 0;
}

void destroyCString(CString *cstrs) {
    if(cstrs && cstrs->cStringsSize && cstrs->cStrings) {
        for(size_t i = cstrs->cStringsStart; i < cstrs->cStringsEnd; i++) free(cstrs->cStrings[i]);
        free(cstrs->cStrings);
        memset(cstrs, 0, sizeof(CString));
    }
}

