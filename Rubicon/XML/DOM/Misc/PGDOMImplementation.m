/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMImplementation.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/12/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 **********************************************************************************************************************************************************************************/

#import "PGDOMPrivate.h"

@implementation PGDOMImplementation {
    }

    -(instancetype)init {
        self = [super init];

        if(self) {
        }

        return self;
    }

    -(PGDOMDocument *)createDocumentWithType:(PGDOMDTD *)dtd qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        /*
         * TODO: Implement
         */
        return nil;
    }

    -(PGDOMDTD *)createDTDWithQualifiedName:(NSString *)qualifiedName publicID:(NSString *)publicID systemID:(NSString *)systemID {
        /*
         * TODO: Implement
         */
        return nil;
    }

@end
