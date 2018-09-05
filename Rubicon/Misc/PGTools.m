/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/30/16 11:03 AM
 * DESCRIPTION:
 *
 * Copyright © 2016 Project Galen. All rights reserved.
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

const NSByte UTF8_2ByteMarker     = 0b11000000;
const NSByte UTF8_3ByteMarker     = 0b11100000;
const NSByte UTF8_4ByteMarker     = 0b11110000;
const NSByte UTF8_2ByteMarkerMask = 0b11100000;
const NSByte UTF8_3ByteMarkerMask = 0b11110000;
const NSByte UTF8_4ByteMarkerMask = 0b11111000;

typedef struct _st_buffer {
    char   *buffer;
    size_t size;
    size_t idx;
}            StrBuffer;

typedef NSString *(*strfmtf_t)(id, SEL, NSString *, va_list);

typedef NSString *(*strallocf_t)(id, SEL);

static const char *ASCII_REPL1[] = {
        "␀", "␁", "␂", "␃", "␄", "␅", "␆", "␇", "␈", "␉", "␊", "⍗", "␌", "␍", "␎", "␏", "␐", "␑", "␒", "␓", "␔", "␕", "␖", "␗", "␘", "␙", "␚", "␛", "␜", "␝", "␞", "␟", " ", "!",
        "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C",
        "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_", "`", "a", "b", "c", "d", "e",
        "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "␡"
};

static const char *ASCII_REPL2[] = {
        "␀", "␁", "␂", "␃", "␄", "␅", "␆", "␇", "␈", "␉", "␊", "⍗", "␌", "␍", "␎", "␏", "␐", "␑", "␒", "␓", "␔", "␕", "␖", "␗", "␘", "␙", "␚", "␛", "␜", "␝", "␞", "␟", "␠", "!",
        "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C",
        "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_", "`", "a", "b", "c", "d", "e",
        "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "␡"
};

NSBitmapImageRep *PGCreateARGBImage(NSFloat width, NSFloat height) {
    NSInteger iWidth  = (NSInteger)ceil(width);
    NSInteger iHeight = (NSInteger)ceil(height);

    return [[NSBitmapImageRep alloc]
                              initWithBitmapDataPlanes:NULL
                                            pixelsWide:iWidth
                                            pixelsHigh:iHeight
                                         bitsPerSample:PGBitsPerField
                                       samplesPerPixel:PGFieldsPerPixel
                                              hasAlpha:YES
                                              isPlanar:NO
                                        colorSpaceName:NSDeviceRGBColorSpace
                                          bitmapFormat:NSAlphaFirstBitmapFormat
                                           bytesPerRow:(iWidth * PGFieldsPerPixel)
                                          bitsPerPixel:(PGBitsPerField * PGFieldsPerPixel)];
}

BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError **error) {
    NSData *pngData = [image representationUsingType:NSPNGFileType properties:@{}];
    return [pngData writeToFile:filename options:0 error:error];
}

size_t PGCopyString(char **ptr, const char *str) {
    size_t len = 0;

    if(!ptr) PGThrowNullPointerException;
    else if(str) {
        len = strlen(str);
        *ptr = PGMalloc(len + 1);
        memcpy(*ptr, str, len + 1);
    }
    else *ptr = NULL;

    return len;
}

NSString *PGStrError(int osErrNo) {
    return [NSString stringWithUTF8String:strerror(osErrNo)];
}

NSString *PGFormatVA(NSString *fmt, va_list args) {
    static Class           stralloc;
    static SEL             strfmts;
    static SEL             strallocs;
    static strfmtf_t       strfmtf;
    static strallocf_t     strallocf;
    static dispatch_once_t strfmti = 0;

    dispatch_once(&strfmti, ^{
        stralloc  = NSString.class;
        strfmts   = @selector(initWithFormat:arguments:);
        strallocs = @selector(alloc);
        strallocf = (strallocf_t)[NSString methodForSelector:strallocs];
        strfmtf   = (strfmtf_t)[[NSString alloc] methodForSelector:strfmts];
    });

    return (*strfmtf)(((*strallocf)(stralloc, strallocs)), strfmts, fmt, args);
}

void PGLog(NSString *fmt, ...) {
    static PGLogger        *_log = nil;
    static dispatch_once_t _logo = 0;

    dispatch_once(&_logo, ^{ _log = [PGLogger sharedInstanceWithDomain:@"PGTools"]; });

    va_list args;
    va_start(args, fmt);
    [_log debug:@"%@", PGFormatVA(fmt, args)];
    va_end(args);
}

NSString *PGFormat(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    NSString *str = PGFormatVA(fmt, args);
    va_end(args);
    return str;
}

void PGFPrintfVA(NSString *filename, NSError **error, NSString *fmt, va_list args) {
    NSError *err = nil;
    [PGFormatVA(fmt, args) writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:&err];
    PGSetReference(error, err);
}

void PGFPrintf(NSString *filename, NSError **error, NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    PGFPrintfVA(filename, error, fmt, args);
    va_end(args);
}

void PGPrintf(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    PGFPrintfVA(@"/dev/stdout", nil, fmt, args);
    va_end(args);
}

void PGSPrintfVA(NSOutputStream *outs, NSString *fmt, va_list args) {
    NSString   *str    = PGFormatVA(fmt, args);
    const char *buffer = str.UTF8String;
    size_t     bufflen = strlen(buffer);
    size_t     buffsnt = 0;

    while(buffsnt < bufflen) {
        NSInteger r = [outs write:(NSByte *)(buffer + buffsnt) maxLength:(bufflen - buffsnt)];
        if(r <= 0) break;
        buffsnt += r;
    }
}

void PGSPrintf(NSOutputStream *outs, NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    PGSPrintfVA(outs, fmt, args);
    va_end(args);
}

NSComparisonResult PGDateCompare(NSDate *d1, NSDate *d2) {
    return ((d1 == d2) ? NSOrderedSame : ((d1 && d2) ? [d1 compare:d2] : (d2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSComparisonResult PGNumCompare(NSNumber *n1, NSNumber *n2) {
    return ((n1 == n2) ? NSOrderedSame : ((n1 && n2) ? [n1 compare:n2] : (n2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSComparisonResult PGStrCompare(NSString *str1, NSString *str2) {
    return ((str1 == str2) ? NSOrderedSame : ((str1 && str2) ? [str1 compare:str2] : (str2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSComparisonResult _PGCompare(id obj1, id obj2) {
    if([[obj1 superclassInCommonWith:obj2] instancesRespondToSelector:@selector(compare:)]) return [obj1 compare:obj2];

    @throw PGCreateCompareException(obj1, obj2);
}

NSException *PGCreateCompareException(id obj1, id obj2) {
    return [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(PGErrorMsgCannotCompare, NSStringFromClass([obj1 class]), NSStringFromClass([obj2 class]))];
}

/**
 * This function attempts to generically compare two objects to determine their sort ordering. Two
 * objects are fully comparable if 1) they share a common superclass and 2) instances of that
 * superclass implement the "compare:" selector.
 *
 * NOTE: just because two objects have the same ordering weight (this function returns NSOrderedSame)
 * does not automatically mean they have equal values. Equality should still be determined by the
 * "isEqual:" method.
 *
 * @param obj1 the first object.
 * @param obj2 the second object.
 * @return NSOrderedSame if both objects have the same sorting weight, NSOrderedAscending if the first
 *          object's sorting weight is less than the second, and NSOrderedDescending if the first
 *          object's sorting weight is greater than the second.
 * @throws NSException named "NSInvalidArgumentException" if the two objects are not comparable.
 */
NSComparisonResult PGCompare(id obj1, id obj2) {
    return ((obj1 == obj2) ? NSOrderedSame : ((obj1 && obj2) ? _PGCompare(obj1, obj2) : (obj2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSURL *PGTemporaryDirectory(NSError **error) {
    return [[NSFileManager defaultManager]
                           URLForDirectory:NSItemReplacementDirectory
                                  inDomain:NSUserDomainMask
                         appropriateForURL:[NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES]
                                    create:YES
                                     error:error];
}

NSURL *PGTemporaryFile(NSString *filenamePostfix, NSError **error) {
    NSURL *tempDir = PGTemporaryDirectory(error);

    if(tempDir) {
        if(filenamePostfix.isEmpty) filenamePostfix = @"temp.tmp";
        return [tempDir URLByAppendingPathComponent:PGFormat(@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], filenamePostfix)];
    }

    return nil;
}

NSByte *PGMemReverse(NSByte *buffer, NSUInteger length) {
    NSUInteger len = (length / 2);

    if(buffer && len) {
        NSByte *a = buffer;
        NSByte *b = (buffer + length);

        for(int i = 0; i < len; ++i) {
            NSByte x = *(--b);
            *b     = *a;
            *(a++) = x;
        }
    }

    return buffer;
}

voidp PGMemDup(cvoidp src, size_t size) {
    voidp dest = PGMalloc(size);
    PGMemCopy(dest, src, size);
    return dest;
}

NSString *_validateDateOrTimeString(NSString *str, NSString *outputFormat, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle, NSStrArray testFormats) {
    if(str.notEmpty) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];

        fmt.dateStyle                  = dateStyle;
        fmt.timeStyle                  = timeStyle;
        fmt.doesRelativeDateFormatting = YES;
        fmt.lenient                    = YES;
        fmt.locale                     = NSLocale.currentLocale;
        fmt.timeZone                   = NSTimeZone.localTimeZone;

        for(NSString *dfmt in testFormats) {
            fmt.dateFormat = dfmt;
            NSDate *dt = [fmt dateFromString:str];

            if(dt) {
                fmt.dateFormat = outputFormat;
                return [fmt stringFromDate:dt];
            }
        }

        NSError              *error = nil;
        NSDataDetector       *de    = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
        NSTextCheckingResult *res   = [de firstMatchInString:str options:0 range:str.range];

        if(res.resultType == NSTextCheckingTypeDate) {
            NSDate *dt = res.date;

            if(dt) {
                fmt.dateFormat = outputFormat;
                return [fmt stringFromDate:dt];
            }
        }
    }

    return nil;
}

NSString *PGValidateDate(NSString *dateString) {
    return _validateDateOrTimeString(dateString, @"MM/dd/yyyy", NSDateFormatterLongStyle, NSDateFormatterNoStyle, @[ @"MM/dd/yyyy", @"yyyy-MM-dd", @"MM-dd-yyyy" ]);
}

NSString *PGValidateTime(NSString *timeString) {
    return _validateDateOrTimeString(timeString, @"HH:mm:ssZZZ", NSDateFormatterNoStyle, NSDateFormatterLongStyle, @[ @"hh:mm:ssZZZ a", @"HH:mm:ssZZZ", @"hh:mm a", @"HH:mm" ]);
}

/**
 * Given a string, this function will prefix all of the specified characters with the escapeChar.
 *
 * @param str the string.
 * @param escapeChar the character that will be prefixed to each of the following characters. If the string contains more than one character then only the first one is used.
 * @param ... a list of strings containing the characters to escape. If any of the strings contains more than one character (composed character, such as emojis,
 *            count as one character) then each character will be broken out separately.
 * @return a new string with the escaped sequences.
 */
NSString *PGEscapeString(NSString *str, NSString *escapeChar, ...) {
    va_list args;
    va_start(args, escapeChar);
    str = [str stringByEscapingChars:[NSString stringWithArguments:args] withEscape:escapeChar];
    va_end(args);
    return str;
}

NSError *PGCreateError(NSString *domain, NSInteger code, NSString *description) {
    return [NSError errorWithDomain:domain code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}

NSError *PGOpenInputStream(NSInputStream *input) {
    NSError *err = nil;

    switch(input.streamStatus) {
        case NSStreamStatusError:
            err = (input.streamError ?: PGCreateError(PGErrorDomain, PGErrorCodeUnknownInputStreamError, PGErrorMsgUnknownInputStreamError));
            break;
        case NSStreamStatusClosed:
            err = PGCreateError(PGErrorDomain, PGErrorCodeInputStreamClosed, PGErrorMsgInputStreamClosed);
            break;
        case NSStreamStatusAtEnd:
            err = PGCreateError(PGErrorDomain, PGErrorCodeUnexpectedEndOfInput, PGErrorMsgUnexpectedEndOfInput);
            break;
        case NSStreamStatusNotOpen:
            [input open];
        case NSStreamStatusOpening:
            while(input.streamStatus == NSStreamStatusOpening) /* EMPTY LOOP */;
            return PGOpenInputStream(input);
        default:
            break;
    }

    return err;
}

BOOL PGReadIntoBuffer(NSInputStream *input, void *buffer, NSUInteger maxLength, int *readStatus, NSError **error) {
    int rs = (int)[input read:buffer maxLength:maxLength];
    if((rs < 0) && (error)) *error = (input.streamError ?: PGCreateError(PGErrorDomain, PGErrorCodeUnknownInputStreamError, PGErrorMsgUnknownInputStreamError));
    return (((*readStatus) = rs) > 0);
}

void addChar(const char ch, StrBuffer *buffer) {
    buffer->buffer[buffer->idx++] = ch;

    if(buffer->idx == buffer->size) {
        buffer->size *= 2;
        buffer->buffer = realloc(buffer->buffer, buffer->size);
    }
}

NS_INLINE void addStr(const char *str, StrBuffer *buffer) {
    while(*str) addChar(*(str++), buffer);
}

#define UNICODEMASK(c) ((uint8_t)((c)&(0xc0)))

char *__pg_cleanstr(const char *str, size_t len, char includeSpaces) {
    if(str) {
        if(len) {
            size_t xlen   = (size_t)strlen(str);
            size_t strlen = MIN(xlen, len);

            StrBuffer  buffer = { .size = strlen, .idx = 0, .buffer = malloc(strlen) };
            uint8_t    ch     = 0;
            size_t     i      = 0;
            const char **repl = (includeSpaces ? ASCII_REPL2 : ASCII_REPL1);

            while(i < strlen) {
                ch = (uint8_t)str[i++];
                if((ch <= 0x20) || (ch == 0x1f)) addStr(repl[ch], &buffer); else addChar(ch, &buffer);
            }

            if((UNICODEMASK(ch) == 0xc0) || (UNICODEMASK(ch) == 0x80)) {
                /*
                 * The last character was part of a UTF-8 unicode multi-byte
                 * character so let's make sure we got the rest of the bytes.
                 */
                ch = (uint8_t)str[i++];

                while(UNICODEMASK(ch) == 0x80) { // Only worry about trailing unicode bytes, not the starter byte.
                    addChar(ch, &buffer);
                    ch = (uint8_t)str[i++];
                }
            }

            buffer.buffer[buffer.idx] = 0;

            char *nstr = PGStrdup(buffer.buffer);
            free(buffer.buffer);
            return nstr;
        }

        return PGStrdup("");
    }

    return NULL;
}

NSUInteger PGHashEnding(NSUInteger hash, const void *buffer, size_t length) {
    if(length) {
        NSUInteger r = 0;
        memcpy(&r, buffer, length);
        hash = ((hash * 31u) + r);
    }

    return hash;
}

NSUInteger PGHashMain(NSUInteger hash, const void *buffer, size_t length) {
    NSUInteger       m  = (length / sizeof(NSUInteger));
    NSUInteger       o  = (length % sizeof(NSUInteger));
    const NSUInteger *p = buffer;

    if(m) { while(m--) hash = ((hash * 31u) + (*(p++))); }
    return PGHashEnding(hash, p, o);
}

NSUInteger PGHash(const void *buffer, size_t length) {
    return (buffer ? (length ? PGHashMain((31u + length), buffer, MIN(length, 4096)) : 1) : 0);
}

char *PG_OVERLOADABLE PGCleanStr(const char *str, size_t len, char includeSpaces) {
    return __pg_cleanstr(str, len, includeSpaces);
}

NSUInteger PG_OVERLOADABLE PGCStringHash(const char *str, size_t len) {
    return PGHash((voidp const)str, len);
}

NSData *PGGetEmptyNSDataSingleton() {
    static dispatch_once_t __singletonCreated      = 0;
    static NSData          *__singletonEmptyNSData = nil;

    dispatch_once(&__singletonCreated, ^{ __singletonEmptyNSData = [NSData new]; });
    return __singletonEmptyNSData;
}
