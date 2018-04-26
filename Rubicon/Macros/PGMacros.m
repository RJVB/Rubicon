/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMacros.m
 *         IDE: AppCode
 *      AUTHOR: ${Galen} Rhodes
 *        DATE: 1/10/17 12:01 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
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
 */

#import "PGInternal.h"

@implementation PGMacros {
    }

    @synthesize macroHandler = _macroHandler;
    @synthesize macroRegex = _macroRegex;

    -(instancetype)initWithHandler:(PGMacroHandler)macroHandler {
        return (self = [self initWithRegex:PGDefaultMacroRegex andHandler:macroHandler]);
    }

    -(instancetype)initWithRegex:(NSString *)macroRegex andHandler:(PGMacroHandler)macroHandler {
        self = [super init];

        if(self) {
            self.macroHandler = macroHandler;
            self.macroRegex   = ((macroRegex.length == 0) ? PGDefaultMacroRegex : macroRegex);
        }

        return self;
    }

    +(instancetype)macrosWithRegex:(NSString *)macroRegex andHandler:(PGMacroHandler)macroHandler {
        return [[self alloc] initWithRegex:macroRegex andHandler:macroHandler];
    }

    +(instancetype)macrosWithHandler:(PGMacroHandler)macroHandler {
        return [[self alloc] initWithHandler:macroHandler];
    }

    -(NSString *)stringByProcessingMacrosIn:(NSString *)aString options:(NSRegularExpressionOptions)options error:(NSError **)error {
        NSError         *lerror  = nil;
        NSMutableString *rString = nil;

        if(aString) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.macroRegex options:options error:&lerror];

            if(lerror == nil) {
                NSUInteger lastLocation = 0;
                NSArray    *matches     = [regex matchesInString:aString options:0 range:aString.range];

                rString = [NSMutableString string];

                for(NSTextCheckingResult *result in matches) {
                    NSRange  mrange = (result.numberOfRanges == 1 ? [result range] : [result rangeAtIndex:1]);
                    NSString *subs  = [aString substringWithRange:mrange];
                    NSString *repl  = self.macroHandler(subs, aString, result.range);

                    if(lastLocation < result.range.location) {
                        NSRange  range = NSMakeRange(lastLocation, (result.range.location - lastLocation));
                        NSString *str  = [aString substringWithRange:range];
                        [rString appendString:str];
                    }

                    if(repl.length) [rString appendString:repl];
                    lastLocation = (result.range.location + result.range.length);
                }

                if(lastLocation < aString.length) {
                    NSString *str = [aString substringFromIndex:lastLocation];
                    [rString appendString:str];
                }
            }
        }
        else {
            NSString     *reason   = @"Given string is nil.";
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey       :reason,
                NSLocalizedFailureReasonErrorKey:reason
            };
            lerror = [NSError errorWithDomain:PGErrorDomain code:1 userInfo:userInfo];
        }

        if(error) *error = lerror;
        return rString;
    }

    -(NSString *)stringByProcessingMacrosIn:(NSString *)aString error:(NSError **)error {
        return [self stringByProcessingMacrosIn:aString options:0 error:error];
    }

    +(NSString *)stringByProcessingMacrosIn:(NSString *)aString
                                  withRegex:(NSString *)macroRegex
                                 andHandler:(PGMacroHandler)macroHandler
                                    options:(NSRegularExpressionOptions)options
                                      error:(NSError **)error {
        return [[[self alloc] initWithRegex:macroRegex andHandler:macroHandler] stringByProcessingMacrosIn:aString options:options error:error];
    }

    +(NSString *)stringByProcessingMacrosIn:(NSString *)aString withHandler:(PGMacroHandler)macroHandler options:(NSRegularExpressionOptions)options error:(NSError **)error {
        return [[[self alloc] initWithHandler:macroHandler] stringByProcessingMacrosIn:aString options:options error:error];
    }

    +(NSString *)stringByProcessingMacrosIn:(NSString *)aString withHandler:(PGMacroHandler)macroHandler error:(NSError **)error {
        return [[[self alloc] initWithHandler:macroHandler] stringByProcessingMacrosIn:aString error:error];
    }

@end
