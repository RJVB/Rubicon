/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMProcessingInstruction.m
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

@implementation PGDOMProcessingInstruction {
        NSString *_target;
        NSString *_data;
    }

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument target:(NSString *)target data:(NSString *)data {
        self = [super initWithNodeType:PGDOMNodeTypeProcessingInstruction ownerDocument:ownerDocument];

        if(self) {
            self.isReadOnly = NO;
            _target = (target ?: @"").copy;
            _data   = (data ?: @"").copy;
        }

        return self;
    }

    -(NSString *)target {
        PGDOMSyncData;
        return _target;
    }

    -(NSString *)data {
        PGDOMSyncData;
        return _data;
    }

    -(void)setData:(NSString *)data {
        PGDOMSyncData;
        PGDOMCheckRO;
        _data = (data ?: @"").copy;
        self.needsSyncData = YES;
    }

@end
