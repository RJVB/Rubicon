/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMCharacterData.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/8/18
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

#import "PGDOMCharacterData.h"
#import "PGDOMPrivate.h"

@implementation PGDOMCharacterData {
    }

    @synthesize data = _data;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data {
        self = [super initWithNodeType:nodeType ownerDocument:ownerDocument];

        if(self) {
            _data = (data ?: @"").copy;
        }

        return self;
    }

    -(NSUInteger)length {
        PGDOMSyncData;
        return self.data.length;
    }

    -(void)appendData:(NSString *)data {
        PGDOMSyncData;
        [self insertData:data atOffset:self.data.length];
    }

    -(void)insertData:(NSString *)data atOffset:(NSUInteger)offset {
        PGDOMSyncData;
        NSString   *cdata = self.data;
        NSUInteger clen   = cdata.length;

        if(offset > clen) {
            @throw [self createIndexOutOfBoundsException];
        }
        if(data.length) {
            if(offset == clen) self.data = [cdata stringByAppendingString:data];
            else self.data = PGFormat(@"%@%@%@", [cdata substringToIndex:offset], data, [cdata substringFromIndex:offset]);
        }
    }

    -(void)deleteDataAtOffset:(NSUInteger)offset length:(NSUInteger)length {
        PGDOMSyncData;
        NSString   *cdata = self.data;
        NSUInteger clen   = cdata.length;
        NSUInteger eidx   = (offset + length);

        if((offset > clen) || (eidx > clen)) {
            @throw [self createIndexOutOfBoundsException];
        }
        else if((offset < clen) && (length > 0)) {
            NSString *pfx = [cdata substringToIndex:offset];
            self.data = ((eidx < length) ? PGFormat(@"%@%@", pfx, [cdata substringFromIndex:eidx]) : pfx);
        }
    }

    -(void)replaceDataAtOffset:(NSUInteger)offset length:(NSUInteger)length withData:(NSString *)newData {
        [self deleteDataAtOffset:offset length:length];
        [self insertData:newData atOffset:offset];
    }

    -(NSString *)substringDataAtOffset:(NSUInteger)offset length:(NSUInteger)length {
        return [self.data substringWithRange:NSMakeRange(offset, length)];
    }

    -(NSException *)createIndexOutOfBoundsException {
        return [NSException exceptionWithName:NSInvalidArgumentException reason:PGErrorMsgIndexOutOfBounds];
    }

@end
