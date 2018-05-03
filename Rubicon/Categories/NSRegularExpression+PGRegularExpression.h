/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSRegularExpression(PGRegularExpression).h
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
 */

#ifndef __Rubicon_NSRegularExpression_PGRegularExpression__H_
#define __Rubicon_NSRegularExpression_PGRegularExpression__H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSRegularExpression(PGRegularExpression)

    -(BOOL)matches:(NSString *)string range:(NSRange)range;

    -(BOOL)matches:(NSString *)string;

    -(NSString *)stringByReplacingMatchesInString:(NSString *)str options:(NSMatchingOptions)options withTemplate:(NSString *)template;

    -(NSString *)stringByReplacingMatchesInString:(NSString *)str withTemplate:(NSString *)template;

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options prefix:(nullable NSString *)prefix error:(NSError **)error;

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error;

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern prefix:(nullable NSString *)prefix error:(NSError **)error;

    +(NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern error:(NSError **)error;

    +(NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern;

    +(NSRegularExpression *)cachedRegex:(NSString *)pattern error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif // __Rubicon_NSRegularExpression_PGRegularExpression__H_
