/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSRegularExpression(PGRegularExpression).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/2/17 11:58 AM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * "It can hardly be a coincidence that no language on Earth has ever produced the expression 'As pretty as an airport.' Airports
 * are ugly. Some are very ugly. Some attain a degree of ugliness that can only be the result of special effort."
 * - Douglas Adams from "The Long Dark Tea-Time of the Soul"
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *//******************************************************************************************************************************/
#import "PGInternal.h"

@implementation NSRegularExpression(PGRegularExpression)

    -(BOOL)matches:(NSString *)string range:(NSRange)range {
        if(string.notEmpty && range.length) {
            NSArray<NSTextCheckingResult *> *matches = [self matchesInString:string options:0 range:range];

            if(matches.count == 1) {
                NSRange mrange = matches[0].range;
                return ((range.length == mrange.length) && (range.location == mrange.location));
            }
        }

        return NO;
    }

    -(BOOL)matches:(NSString *)string {
        return [self matches:string range:string.range];
    }

    -(NSString *)stringByReplacingMatchesInString:(NSString *)str options:(NSMatchingOptions)options withTemplate:(NSString *)template {
        return [self stringByReplacingMatchesInString:str options:options range:str.range withTemplate:template];
    }

    -(NSString *)stringByReplacingMatchesInString:(NSString *)str withTemplate:(NSString *)template {
        return [self stringByReplacingMatchesInString:str options:0 range:str.range withTemplate:template];
    }

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error {
        return [self cachedRegex:pattern options:options prefix:nil error:error];
    }

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options prefix:(NSString *)prefix error:(NSError **)error {
        static dispatch_once_t     predicate;
        static NSLock              *lock;
        static NSMutableDictionary *regexCache = nil;
        NSRegularExpression        *regex      = nil;

        if(pattern) {
            dispatch_once(&predicate, ^{
                regexCache = [NSMutableDictionary new];
                lock       = [NSLock new];
            });
            NSString *key = PGFormat(@"%@❖%@❖%@", (prefix.length ? prefix : @"☞"), @(options), pattern);
            [lock lock];
            regex = regexCache[key];
            if(regex == nil) {
                regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:error];
                if(regex) regexCache[key] = regex;
            }
            [lock unlock];
        }
        else if(error) {
            (*error) = [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeRegexPatternIsNULL userInfo:@{ NSLocalizedDescriptionKey: PGErrorMsgRegexPatternIsNULL }];
        }

        return regex;
    }

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern error:(NSError **)error {
        return [self cachedRegex:pattern options:0 prefix:nil error:error];
    }

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern prefix:(NSString *)prefix error:(NSError **)error {
        return [self cachedRegex:pattern options:0 prefix:prefix error:error];
    }

    +(NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern error:(NSError **)error {
        return [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:error];
    }

    +(NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern {
        return [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    }

@end
