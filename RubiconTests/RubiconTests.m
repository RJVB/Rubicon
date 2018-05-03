//
//  RubiconTests.m
//  RubiconTests
//
//  Created by Galen Rhodes on 12/21/16.
//  Copyright © 2016 Project Galen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Rubicon/Rubicon.h>
#import "CommonBaseClass.h"

#define INDICATOR(x) ((x) ? @"✅" : @"⛔️")

NSString *const GuideString = @"0---------1---------2---------3---------4---------5---------6---------7---------8";
NSString *const TestString  = @"Now is the time for all good men 🤯 to come to the aid of their country."; // 7
NSString *const TestString1 = @"The quick brown fox jumps over the lazy dog.";                             // 31
NSString *const TestString2 = @"The-quick+brown-fox+jumps-over+the-lazy+dog.";                             // 31

//NSString *const Base64Input  = @"Now is the time for all good programmers to come to the aid of their terminals.";    // 7
//NSString *const Base64Output = @"Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBwcm9ncmFtbWVycyB0byBjb21lIHRvIHRoZSBhaWQgb2YgdGhlaXIgdGVybWluYWxzLg==";

NSString *const Base64Input  = @"Now is the time for all good men 🤯 to come to the aid of their country.";    // 7
NSString *const Base64Output = @"Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBtZW4g8J+kryB0byBjb21lIHRvIHRoZSBhaWQgb2YgdGhlaXIgY291bnRyeS4=";

static NSString *const BAR = @"------------------------------------------------------------------------------------------------------------------------";

@interface RubiconTests : XCTestCase

@end

NS_INLINE void NOutput(NSString *string) {
    [string writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

NS_INLINE void Output(NSString *string) {
    NOutput(PGFormat(@"%@\n", string));
}

NS_INLINE NSString *quote(NSString *string) {
    return (string ? PGFormat(@"\"%@\"", string) : @"<NIL>");
}

NS_INLINE NSString *oquote(NSString *string) {
    return (string ? PGFormat(@"@\"%@\"", string) : @"<NIL>");
}

NS_INLINE NSString *compareDescription(NSComparisonResult cr) {
    switch(cr) {
        case NSOrderedAscending: return @"NSOrderedAscending";
        case NSOrderedDescending: return @"NSOrderedDescending";
        default: return @"NSOrderedSame";
    }
}

void FOutput(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

@implementation RubiconTests

    -(void)setUp {
        [super setUp];
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    -(void)tearDown {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        [super tearDown];
    }

    -(void)test84Regex {
        NSString *str = @"Now \"is\" the time for some\\all good men to come to the end of their country.";
        NSLog(@"Before: \"%@\"", str);
        // NSLog(@" After: \"%@\"", PGEscapeString(str, @"\\", @"\"\\", @".", nil));
        NSLog(@" After: \"%@\"", [str stringByEscapingChars:@"\\\"." withEscape:@"\\"]);
    }

    -(void)t_est85CommandLine {
        const char *cmdline[]    = {
                "programName", "-R$1,234.4", "--nop=7.65E-3", "-foo", "--foo", "--bar=56789", "-bar", "012345", "--jail", "\\--jail", "\\\\--jail", "--", "galen", "rhodes",
                "is\\was", "\"here\""
        };
        NSUInteger cmdLineLength = (NSUInteger)(sizeof(cmdline) / sizeof(char *));

        const PGCmdLineOptionStruct opts[] = { // @f:0
            { .shortName = "f",  .longName = "foo", .isRequired = 1, .argumentState = PGCmdLineArgNone,     .argumentType = PGCmdLineArgTypeNone    }, // 1
            { .shortName = "o",  .longName = NULL,  .isRequired = 1, .argumentState = PGCmdLineArgRequired, .argumentType = PGCmdLineArgTypeString  }, // 2
            { .shortName = "r",  .longName = "bar", .isRequired = 0, .argumentState = PGCmdLineArgRequired, .argumentType = PGCmdLineArgTypeInteger }, // 3
            { .shortName = "b",  .longName = NULL,  .isRequired = 0, .argumentState = PGCmdLineArgNone,     .argumentType = PGCmdLineArgTypeNone    }, // 4
            { .shortName = "a",  .longName = NULL,  .isRequired = 0, .argumentState = PGCmdLineArgNone,     .argumentType = PGCmdLineArgTypeNone    }, // 5
            { .shortName = NULL, .longName = "nop", .isRequired = 0, .argumentState = PGCmdLineArgRequired, .argumentType = PGCmdLineArgTypeFloat   }, // 6
            { .shortName = "D",  .longName = NULL,  .isRequired = 0, .argumentState = PGCmdLineArgRequired, .argumentType = PGCmdLineArgTypeDate    }, // 7
            { .shortName = "T",  .longName = NULL,  .isRequired = 0, .argumentState = PGCmdLineArgRequired, .argumentType = PGCmdLineArgTypeTime    }, // 8
            { .shortName = "R",  .longName = NULL,  .isRequired = 0, .argumentState = PGCmdLineArgRequired, .argumentType = PGCmdLineArgTypeRegex, .regexPattern = "\\$-?[0-9]{1,3}(?:,[0-9]{3})*(?:\\.[0-9]{2})?" }, // 9
            { .shortName = NULL, .longName = NULL } // *END* @f:1
        };
        NSError                     *error = nil;

        PGCmdLine *commandLine = [PGCmdLine cmdLineWithArguments:cmdline length:cmdLineLength encoding:NSUTF8StringEncoding parseOptions:0 optionList:opts error:&error];
        NSLog(@"ERROR: %@", error);
        NSLog(@"%@", commandLine.description);
        NSLog(@"%@", @"Done");
    }

    -(void)t_est86CommandLine {
        const char *cmdline[]    = {
                "programName", "-foo", "--foo", "--bar=galen", "-bar", "rhodes", "--jail", "--", "galen", "rhodes", "is\\was", "\"here\""
        };
        NSUInteger cmdLineLength = (NSUInteger)(sizeof(cmdline) / sizeof(char *));

        NSError   *error       = nil;
        NSArray   *opts        = @[
                PGMakeCmdLineOpt(@"f", @"foo", YES, PGCmdLineArgNone, PGCmdLineArgTypeNone, nil),      // 1
                PGMakeCmdLineOpt(@"o", nil, YES, PGCmdLineArgRequired, PGCmdLineArgTypeString, nil),   // 2
                PGMakeCmdLineOpt(@"r", @"bar", NO, PGCmdLineArgRequired, PGCmdLineArgTypeString, nil), // 3
                PGMakeCmdLineOpt(@"b", nil, NO, PGCmdLineArgNone, PGCmdLineArgTypeNone, nil),          // 4
                PGMakeCmdLineOpt(@"a", nil, NO, PGCmdLineArgNone, PGCmdLineArgTypeNone, nil)           // 5
        ];
        PGCmdLine *commandLine = [[PGCmdLine alloc] initWithArguments:cmdline length:cmdLineLength encoding:NSUTF8StringEncoding parseOptions:0 options:opts error:&error];

        NSLog(@"ERROR: %@", error);
        NSLog(@"%@", commandLine.description);

        const char *cmdline2[] = {
                "programName", "--bar=galen", "-bar", "rhodes", "--", "galen", "rhodes", "was", "here"
        };

        NSUInteger cmdLine2Length = (NSUInteger)(sizeof(cmdline2) / sizeof(char *));

        commandLine = [[PGCmdLine alloc] initWithArguments:cmdline2 length:cmdLine2Length encoding:NSUTF8StringEncoding parseOptions:0 options:opts error:&error];
        NSLog(@"ERROR: %@", error);
        NSLog(@"%@", commandLine.description);

        NSLog(@"%@", @"Done");
    }

    -(void)t_est87TimeFormatter {
        NSDateFormatter *fmt  = [[NSDateFormatter alloc] init];
        NSStrArray      dates = @[ @"11:31:14", @"11:31:14 PM", @"14:55", @"3:22" ];
        NSStrArray      fmts  = @[ @"hh:mm:ssZZZ a", @"HH:mm:ssZZZ", @"hh:mm a", @"HH:mm" ];

        fmt.locale                     = [NSLocale currentLocale];
        fmt.dateStyle                  = NSDateFormatterNoStyle;
        fmt.timeStyle                  = NSDateFormatterLongStyle;
        fmt.doesRelativeDateFormatting = YES;
        fmt.lenient                    = YES;
        fmt.timeZone                   = [NSTimeZone localTimeZone];

        for(NSString *dstr in dates) {
            NSDate *dt = nil;

            for(NSString *dfmt in fmts) {
                fmt.dateFormat = dfmt;
                dt = [fmt dateFromString:dstr];
                if(dt) break;
            }

            if(dt == nil) {
                NSError              *error = nil;
                NSDataDetector       *de    = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
                NSTextCheckingResult *res   = [de firstMatchInString:dstr options:0 range:NSMakeRange(0, dstr.length)];
                if(res.resultType == NSTextCheckingTypeDate) {
                    dt = res.date;
                }
            }

            fmt.dateFormat = @"HH:mm:ss.SSSZZZ (zzzz)";
            NSLog(@"Time: \"%@\" = %@", dstr, dt ? quote([fmt stringFromDate:dt]) : @"<NULL>");
        }

        NSDate *dt = [NSDate date];
        fmt.dateFormat = @"HH:mm:ss.SSSZZZ (zzzz)";
        NSLog(@"Time: %@ = %@", dt, [fmt stringFromDate:dt]);
    }

    -(void)t_est87DateFormatter {
        NSDateFormatter *fmt  = [[NSDateFormatter alloc] init];
        NSStrArray      dates = @[ @"04/21/2018", @"21/04/2018", @"1967-12-25", @"Tomorrow", @"October 25, 1970", @"7 days from now" ];
        NSStrArray      fmts  = @[ @"MM/dd/yyyy", @"yyyy-MM-dd", @"MM-dd-yyyy" ];

        fmt.locale                     = [NSLocale currentLocale];
        fmt.dateStyle                  = NSDateFormatterLongStyle;
        fmt.timeStyle                  = NSDateFormatterNoStyle;
        fmt.doesRelativeDateFormatting = YES;
        fmt.lenient                    = YES;
        fmt.timeZone                   = [NSTimeZone localTimeZone];

        for(NSString *dstr in dates) {
            NSDate *dt = nil;

            for(NSString *dfmt in fmts) {
                fmt.dateFormat = dfmt;
                dt = [fmt dateFromString:dstr];
                if(dt) break;
            }

            if(dt == nil) {
                NSError              *error = nil;
                NSDataDetector       *de    = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
                NSTextCheckingResult *res   = [de firstMatchInString:dstr options:0 range:NSMakeRange(0, dstr.length)];
                if(res.resultType == NSTextCheckingTypeDate) {
                    dt = res.date;
                }
            }

            NSLog(@"Date: \"%@\" = %@", dstr, quote(dt.description));
        }

        NSDate *dt = [NSDate date];
        NSLog(@"Date: %@ = %@", dt, [fmt stringFromDate:dt]);
    }

    -(void)t_est87ArrayBlock {
        NSStrArray array = @[ @"Galen", @"Sherard", @"Rhodes" ];
        NSUInteger idx   = [array indexOfObjectPassingTest:^BOOL(NSString *obj, NSUInteger i, BOOL *stop) {
            NSLog(@"Object(%lu): %@", i, oquote(obj));
            return [obj isEqualToString:@"is"];
        }];

        NSLog(@"Results: %lu", idx);
    }

    -(void)t_est87Cleans {
        NSRegularExpression *rx1 = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(-{1,2})\\s*" options:0 error:nil];
        NSRegularExpression *rx2 = [NSRegularExpression regularExpressionWithPattern:@"^(\\s*)\\\\(-|\\\\)" options:0 error:nil];

        NSLog(@"Result: %@", quote([rx2 stringByReplacingMatchesInString:@"     \\-Galen" options:0 withTemplate:@"$1$2"]));
        NSLog(@"Result: %@", quote([rx2 stringByReplacingMatchesInString:@"\\-Galen" options:0 withTemplate:@"$1$2"]));
        NSLog(@"Result: %@", quote([rx2 stringByReplacingMatchesInString:@"     \\\\Galen" options:0 withTemplate:@"$1$2"]));
        NSLog(@"Result: %@", quote([rx2 stringByReplacingMatchesInString:@"\\\\Galen" options:0 withTemplate:@"$1$2"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"-foo" options:0 withTemplate:@"$1"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"-  foo" options:0 withTemplate:@"$1"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"   -foo" options:0 withTemplate:@"$1"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"   -  foo" options:0 withTemplate:@"$1"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"--foo" options:0 withTemplate:@"$1"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"--  foo" options:0 withTemplate:@"$1"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"   --foo" options:0 withTemplate:@"$1"]));
        NSLog(@"Result: %@", quote([rx1 stringByReplacingMatchesInString:@"   --  foo" options:0 withTemplate:@"$1"]));
    }

    -(void)t_est87Set {
        NSArray<PGCmdLineOption *> *array = @[
                PGMakeCmdLineOpt(@"o", @"october", NO, PGCmdLineArgNone, PGCmdLineArgTypeString, nil), //1
                PGMakeCmdLineOpt(@"a", nil, NO, PGCmdLineArgNone, PGCmdLineArgTypeString, nil),        //2
                PGMakeCmdLineOpt(nil, @"pear", NO, PGCmdLineArgNone, PGCmdLineArgTypeString, nil),     //3
                PGMakeCmdLineOpt(@"o", @"pumpkin", NO, PGCmdLineArgNone, PGCmdLineArgTypeString, nil), //4
                PGMakeCmdLineOpt(@"p", @"october", NO, PGCmdLineArgNone, PGCmdLineArgTypeString, nil), //5
        ];
        NSSet<PGCmdLineOption *>   *set   = [NSSet setWithArray:array];

        NSUInteger          i = 0;
        for(PGCmdLineOption *opt in set) {
            NSLog(@"Option %lu> %@", ++i, opt.description);
        }

        NSLog(@"%@", BAR);

        NSUInteger j = 0;

        for(PGCmdLineOption *opt1 in array) {
            NSUInteger k = 0;
            j++;

            for(PGCmdLineOption *opt2 in array) {
                BOOL eq = [opt1 isEqual:opt2];
                k++;

                if(opt1 != opt2 && eq) {
                    NSLog(@"%lu == %lu; %@ == %@", j, k, opt1, opt2);
                }
            }
        }
    }

    -(void)t_est88Compare {
        NSString *s1 = @"Galen";
        NSString *s2 = @"Rhodes";
        NSString *s3 = nil;

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
        NSLog(@"[%@ compare:%@] == %@", oquote(s1), oquote(s2), compareDescription([s1 compare:s2]));
        NSLog(@"[%@ compare:%@] == %@", oquote(s2), oquote(s1), compareDescription([s2 compare:s1]));
        NSLog(@"[%@ compare:%@] == %@", oquote(s3), oquote(s1), compareDescription([s3 compare:s1]));
        NSLog(@"[%@ compare:%@] == %@", oquote(s1), oquote(s3), compareDescription([s1 compare:s3]));

        NSLog(@"%@", BAR);

        NSLog(@"PGStrCompare(%@, %@) == %@", oquote(s1), oquote(s2), compareDescription(PGStrCompare(s1, s2)));
        NSLog(@"PGStrCompare(%@, %@) == %@", oquote(s2), oquote(s1), compareDescription(PGStrCompare(s2, s1)));
        NSLog(@"PGStrCompare(%@, %@) == %@", oquote(s3), oquote(s1), compareDescription(PGStrCompare(s3, s1)));
        NSLog(@"PGStrCompare(%@, %@) == %@", oquote(s1), oquote(s3), compareDescription(PGStrCompare(s1, s3)));
#pragma clang diagnostic pop
    }

    -(void)t_est89CommandLineRegexPatterns {
        NSError                               *error   = nil;
        NSStrArray                            patterns = @[
                @"(?is-mw:^\\s*(-)\\s*([\\d\\p{L}]+)(.*)$)",   // 1
                @"(?is-mw:^\\s*(-)\\s*([fo]*[q]|[fo]+)(.*)$)", // 2
                @"(?is-mw:^\\s*(--)\\s*$)",                    // 3
                @"(?is-mw:^\\s*(--)\\s*([\\d\\p{L}]+)(?:\\s*=(.*))?$)",    // 4
        ];
        NSStrArray                            samples  = @[
                @"-f", @"-foo", @"-fooq123", @"--foo", @"--foo=bar", @"-", @"--", @"galenrhodes",
        ];
        NSMutableArray<NSRegularExpression *> *regex   = [NSMutableArray arrayWithCapacity:patterns.count];

        BOOL         hadOutput = NO;
        for(NSString *pattern in patterns) {
            error = nil;
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];

            if(r) [regex addObject:r];
            else {
                hadOutput = YES;
                NSLog(@"%@", BAR);
                NSLog(@"Error in regex pattern: %@", pattern);
                NSLog(@"      --------------->: %@", (error ? error.description : @"<Unknown>"));
            }
        }
        if(hadOutput) {
            hadOutput = NO;
            NSLog(@"%@", BAR);
        }

        NSUInteger si = 0;

        for(NSString *str in samples) {
            NSLog(@"%@", BAR);
            NSLog(@"Sample %2lu: \"%@\"", ++si, str);

            for(NSUInteger i = 0, j = regex.count; i < j; i++) {
                NSRegularExpression             *r       = regex[i];
                NSRange                         srng     = NSMakeRange(0, str.length);
                NSArray<NSTextCheckingResult *> *matches = [r matchesInString:str options:0 range:srng];
                NSUInteger                      mc       = matches.count;

                NSString *f1 = @"    Regex %2lu: \"%@\"";
                NSString *f2 = @"      Result: %@";
                NSString *f3 = @"        %@ %2lu: Location = %2lu; Length = %2lu; \"%@\"";
                NSString *f4 = @"        %@ %2lu: Location = --; Length = --;";

                NSLog(f1, (i + 1), r.pattern);

                if(mc == 1) {
                    NSTextCheckingResult *tcr = matches[0];
                    NSUInteger           gc   = tcr.numberOfRanges;

                    NSLog(f2, PGFormat(@"OPTION - Capture Groups = %lu", gc));

                    for(NSUInteger k = 0, l = gc; k < l; k++) {
                        NSRange group = [tcr rangeAtIndex:k];

                        if(group.location == NSNotFound) NSLog(f4, @"Group", k);
                        else NSLog(f3, @"Group", k, group.location, group.length, [str substringWithRange:group]);
                    }
                }
                else {
                    NSLog(f2, PGFormat(@"Not An Option - matches = %lu", mc));

                    for(NSUInteger k = 0; k < mc; k++) {
                        NSRange match = matches[k].range;

                        if(match.location == NSNotFound) NSLog(f4, @"Range", k);
                        else NSLog(f3, @"Range", k, match.location, match.length, [str substringWithRange:match]);
                    }
                }

                NSLog(@"%@", @"   ");
            }
        }

        NSLog(@"%@", BAR);
    }

    -(void)t_est90OptionCleanup {
        NSError    *err     = nil;
        NSString   *pattern = @"^(?:\\s*(\\-\\-)\\s*(?:([^\\s]+)\\s*(\\=)?)?|\\s*(\\-)\\s*)";
        NSUInteger maxWidth = 0;

        NSStrArray samples = @[ /* @f:0 */
                @"--foo",
                @"-foo",
                @"  --foo",
                @"  -foo",
                @"-- foo",
                @"-  foo",
                @"   --   foo",
                @"     -   foo",
                @"--",
                @"  --",
                @"--foo   ",
                @"-foo   ",
                @"  --foo   ",
                @"  -foo   ",
                @"-- foo   ",
                @"-  foo   ",
                @"   --   foo   ",
                @"     -   foo   ",
                @"--   ",
                @"  --   ",
                @"-",
                @"     -",
                @"-        ",
                @"       -           ",
                @"foo",
                @"             foo",
                @"foo           ",
                @"             foo                 ",
                @"  --  foo = now is the time.  "
                /* @f:1 */
        ];

        PGRegexFilterBlock blk = ^NSString *(NSString *str, NSString *sub, NSUInteger num, NSTextCheckingResult *res, NSString *last, BOOL *stop) {
//            FOutput(@"str: \"%@\"", str);
//            FOutput(@"sub: \"%@\"", sub);
//            FOutput(@"ranges: %lu", res.numberOfRanges);
//            for(NSUInteger i = 0, j = res.numberOfRanges; i < j; i++) {
//                FOutput(@"------> %@", NSStringFromRange([res rangeAtIndex:i]));
//            }
            NSMutableString *mstr = [NSMutableString new];
            for(NSUInteger  i     = 1, j = res.numberOfRanges; i < j; i++) {
                NSRange r = [res rangeAtIndex:i];
                if(r.location != NSNotFound) [mstr appendString:[str substringWithRange:r]];
            }
            return mstr;
        };

        for(NSString *str in samples) maxWidth = MAX(maxWidth, str.length + 2);

        NSLog(@"%@", BAR);
        NSLog(@"%@", @"");

        for(NSString *str in samples) {
            NSString *fstr = [str stringByFilteringWithRegexPattern:pattern regexOptions:0 matchOptions:0 replacementBlock:blk error:&err];

            if(fstr) NSLog(@"Input: %@; Output:%@", [quote(str) stringByFrontPaddingToLength:maxWidth withString:@" " startingAtIndex:0], quote(fstr));
            else if(err) NSLog(@"Error: %@", err);
            else NSLog(@"%@", @"Unknown Error.");
        }

        NSLog(@"%@", @"");
        NSLog(@"%@", @"");
        NSLog(@"%@", BAR);
    }

    -(void)t_est90StringByFilteringWithRegexPattern {
        NSLog(@"%@", @"Beginning: test90StringByFilteringWithRegexPattern");

        PGRegexFilterBlock blk = ^NSString *(NSString *str, NSString *sub, NSUInteger num, NSTextCheckingResult *res, NSString *last, BOOL *stop) {
            return ([sub isEqualToString:@"men"] ? @"programmers" : @"users");
        };

        NSString *str = nil;

        NSError *err = nil;
        str = [TestString stringByFilteringWithRegexPattern:@"men|country" regexOptions:0 matchOptions:0 replacementBlock:blk error:&err];

        FOutput(@"Unfiltered String: %@", TestString);
        FOutput(@"  Filtered String: %@", str);

        NSLog(@"%@", @"Finished: test90StringByFilteringWithRegexPattern");
    }

    -(void)t_est91EnumerateOverCharactersWithBlock {
        NSString           *test   = [TestString copy];
        NSRange            nsRange = NSMakeRange(30, 10);
        __block NSUInteger cnt     = 0;

        FOutput(@"Test String: %@", quote([test substringWithRange:nsRange]));

        [test enumerateOverCharactersWithBlock:^BOOL(unichar c, unichar *dc, NSRange range, BOOL composed, NSString *before, NSString *after) {
            FOutput(@"%2lu [%2lu,%2lu]: '%@'; before: %@; after: %@", cnt++, range.location, range.length, [test substringWithRange:range], quote(before), quote(after));
            return NO;
        }                                range:nsRange];
    }

    -(void)t_est92DynamicByteQueue {
        PGDynamicByteQueue *queue = [PGDynamicByteQueue queueWithInitialSize:5];
        NSString           *test  = @"ABCD";
        [queue queueString:test];
        [queue queueString:@"EFGH"];
        [queue requeueString:@"0123456789"];
        PGPrintf(@"\n\nQUEUE: \"%@\"\n", queue.string);
        NSInteger a = queue.pop;
        NSInteger b = queue.pop;
        NSInteger c = queue.dequeue;
        NSInteger d = queue.dequeue;
        PGPrintf(@"VALUES: a = %li ('%c'); b = %li ('%c'); c = %li ('%c'); d = %li ('%c');\n",
                 a,
                 (char)(a & 0x00ff),
                 b,
                 (char)(b & 0x00ff),
                 c,
                 (char)(c & 0x00ff),
                 d,
                 (char)(d & 0x00ff));

        PGPrintf(@"QUEUE: \"%@\"\n\n\n", queue.string);
    }

    -(void)t_est93TemporaryDirectories {
        NSError *error = nil;
        NSLog(@"Temporary Directory: \"%@\"", PGTemporaryDirectory(&error).absoluteString);
        if(error) {
            XCTFail(@"Error: %@", error.description);
        }
    }

    -(void)t_est93TemporaryFiles {
        NSError *error = nil;
        NSLog(@"Temporary File: \"%@\"", PGTemporaryFile(@"Test.txt", &error).absoluteString);
        if(error) {
            XCTFail(@"Error: %@", error.description);
        }
    }

    -(void)t_est94StringByCenteringInPaddingOfLength {
        NSStrArray strings = @[ @"Galen", @"Galen Rhodes", @"GalenGlenn", @"" ];
        NSStrArray results = @[ @"=+Galen+=+", @"alen Rhode", @"GalenGlenn", @"=+-+=+-+=+" ];
        BOOL       overall = YES;

        NSLog(@"%@", BAR);
        for(int i = 0; i < strings.count;) {
            NSString   *s   = strings[(NSUInteger)i];
            NSString   *t   = [PGFormat(@"\"%@\"", s) stringByFrontPaddingToLength:15 withString:@"                                 " startingAtIndex:0];
            NSString   *u   = [s stringByCenteringInPaddingOfLength:10 withString:@"+-+=+-+=+-+=+-+=+-+=+-+=" startingAtIndex:3];
            NSUInteger slen = s.length;
            BOOL       x    = ([u isEqualToString:results[(NSUInteger)i++]]);

            overall = (overall && x);
            NSLog(@"%2d %@> (%2lu) %@ <=> \"%@\"", i, INDICATOR(x), slen, t, u);
        }
        NSLog(@"%@", BAR);
        XCTAssertTrue(overall, @"%@: Overall - %@", @"One or more of the test cases failed", INDICATOR(overall));
    }

    -(void)t_est94StringByFrontPaddingToLength {
        NSStrArray strings = @[ @"Galen", @"Galen Rhodes", @"GalenGlenn", @"" ];
        NSStrArray results = @[ @"=+-+=Galen", @"len Rhodes", @"GalenGlenn", @"=+-+=+-+=+" ];
        BOOL       overall = YES;

        NSLog(@"%@", BAR);
        for(int i = 0; i < strings.count;) {
            NSString   *s   = strings[(NSUInteger)i];
            NSString   *t   = [PGFormat(@"\"%@\"", s) stringByFrontPaddingToLength:15 withString:@"                                 " startingAtIndex:0];
            NSString   *u   = [s stringByFrontPaddingToLength:10 withString:@"+-+=+-+=+-+=+-+=+-+=+-+=" startingAtIndex:3];
            NSUInteger slen = s.length;
            BOOL       x    = ([u isEqualToString:results[(NSUInteger)i++]]);

            overall = (overall && x);
            NSLog(@"%2d %@> (%2lu) %@ <=> \"%@\"", i, INDICATOR(x), slen, t, u);
        }
        NSLog(@"%@", BAR);
        XCTAssertTrue(overall, @"%@: Overall - %@", @"One or more of the test cases failed", INDICATOR(overall));
    }

    -(void)t_est95FilterOutputStream {
        const char     *cInput   = Base64Input.UTF8String;
        size_t         cInputLen = strlen(cInput);
        NSOutputStream *output   = [PGFilterOutputStream streamWithOutputStream:[NSOutputStream outputStreamToFileAtPath:@"/dev/stdout" append:YES] chunk:10];

        [output open];
        NSInteger written = [output write:(const uint8_t *)cInput maxLength:cInputLen];
        [output close];

        NSLog(@"%@", BAR);
        NSLog(@"        Bytes Provided: %zu", cInputLen);
        NSLog(@"         Bytes Written: %@:%@", @(written), INDICATOR(cInputLen == written));
        NSLog(@"%@", BAR);
        XCTAssertTrue((cInputLen == written), @"%@: cInputLen = %zu; written = %li", @"Test cases failed", cInputLen, written);
    }

    -(void)t_est95Base64Function {
        size_t     outlen        = 0;
        const char *base64Input  = Base64Input.UTF8String;
        NSUInteger zz            = [Base64Input lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        size_t     inputLen      = strlen(base64Input);
        char       *output       = PGEncodeBase64((const uint8_t *)base64Input, inputLen, &outlen);
        NSString   *base64Output = [NSString stringWithUTF8String:output];
        BOOL       x             = [Base64Output isEqualToString:base64Output];

        Output(BAR);
        Output(Base64Input);
        Output(BAR);

        NSLog(BAR);
        NSLog(@"   String Input: %@ (%zu, %lu)", Base64Input, inputLen, zz);
        NSLog(@"  Base64 Output: %@ (%zu)", base64Output, strlen(output));
        NSLog(@"Expected Output: %@", Base64Output);
        NSLog(@"        Correct: %@", INDICATOR(x));
        NSLog(BAR);
        free(output);
        XCTAssertTrue(x, @"Test Case Failed!");
    }

    -(void)t_est95Base64OutputStream {
        const char           *base64Input = Base64Input.UTF8String;
        size_t               capacity     = 1024;
        uint8_t              *bytes       = (uint8_t *)calloc(1, 1024);
        PGBase64OutputStream *b64         = [[PGBase64OutputStream alloc] initWithOutputStream:[NSOutputStream outputStreamToBuffer:bytes capacity:capacity] chunk:10];
        NSInteger            written      = 0;
        NSInteger            fwritten     = 0;

        [b64 open];
        written  = [b64 write:(const uint8_t *)base64Input maxLength:strlen(base64Input)];
        fwritten = [b64 flush];

        BOOL x = [[NSString stringWithUTF8String:(const char *)bytes] isEqualToString:Base64Output];

        NSLog(@"%@", BAR);
        NSLog(@"         Bytes Written: %@", @(written));
        NSLog(@"Bytes Written by Flush: %@", @(fwritten));
        NSLog(@"         Output Length: %zu", strlen((const char *)bytes));
        NSLog(@"                Output: \"%s\"", (const char *)bytes);
        NSLog(@"       Expected Output: \"%@\"", Base64Output);
        NSLog(@"        Correct: %@", INDICATOR(x));
        NSLog(@"%@", BAR);

        [b64 close];
        b64 = nil;
        free(bytes);
        XCTAssertTrue(x, @"Test Case Failed!");
    }

    -(void)t_est98SplitByString {
        // Test String @"The-quick+brown-fox+jumps-over+the-lazy+dog."
        NSStrArray          patterns = @[ @"-", @"+", @".", @"|" ];
        NSArray<NSNumber *> *limits  = @[ @(0), @(4), @(1), @(99), @(9) ];
        NSArray<NSNumber *> *keeps   = @[ @(NO), @(YES) ];
        NSArray             *results = @[
                @[
                        @[
                                @[ @"The", @"quick+brown", @"fox+jumps", @"over+the", @"lazy+dog." ], // Limit 0
                                @[ @"The", @"quick+brown", @"fox+jumps", @"over+the-lazy+dog." ], //     Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], //                 Limit 1
                                @[ @"The", @"quick+brown", @"fox+jumps", @"over+the", @"lazy+dog." ], // Limit 99
                                @[ @"The", @"quick+brown", @"fox+jumps", @"over+the", @"lazy+dog." ] //  Limit 9
                        ], // No Keep
                        @[
                                @[ @"The-", @"quick+brown-", @"fox+jumps-", @"over+the-", @"lazy+dog." ], // Limit 0
                                @[ @"The-", @"quick+brown-", @"fox+jumps-", @"over+the-lazy+dog." ], //      Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], //                     Limit 1
                                @[ @"The-", @"quick+brown-", @"fox+jumps-", @"over+the-", @"lazy+dog." ], // Limit 99
                                @[ @"The-", @"quick+brown-", @"fox+jumps-", @"over+the-", @"lazy+dog." ] //  Limit 9
                        ] //  Keep
                ], // @"-"
                @[
                        @[
                                @[ @"The-quick", @"brown-fox", @"jumps-over", @"the-lazy", @"dog." ], // Limit 0
                                @[ @"The-quick", @"brown-fox", @"jumps-over", @"the-lazy+dog." ], //     Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], //                 Limit 1
                                @[ @"The-quick", @"brown-fox", @"jumps-over", @"the-lazy", @"dog." ], // Limit 99
                                @[ @"The-quick", @"brown-fox", @"jumps-over", @"the-lazy", @"dog." ] //  Limit 9
                        ], // No Keep
                        @[
                                @[ @"The-quick+", @"brown-fox+", @"jumps-over+", @"the-lazy+", @"dog." ], // Limit 0
                                @[ @"The-quick+", @"brown-fox+", @"jumps-over+", @"the-lazy+dog." ], //      Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], //                     Limit 1
                                @[ @"The-quick+", @"brown-fox+", @"jumps-over+", @"the-lazy+", @"dog." ], // Limit 99
                                @[ @"The-quick+", @"brown-fox+", @"jumps-over+", @"the-lazy+", @"dog." ] //  Limit 9
                        ] //  Keep
                ], // @"+"
                @[
                        @[
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog", @"" ], // Limit 0
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog", @"" ], // Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], //     Limit 1
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog", @"" ], // Limit 99
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog", @"" ] //  Limit 9
                        ], // No Keep
                        @[
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog.", @"" ], // Limit 0
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog.", @"" ], // Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], //      Limit 1
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog.", @"" ], // Limit 99
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog.", @"" ] //  Limit 9
                        ] //  Keep
                ], // @"."
                @[
                        @[
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 0
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 1
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 99
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ] //  Limit 9
                        ], // No Keep
                        @[
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 0
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 4
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 1
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ], // Limit 99
                                @[ @"The-quick+brown-fox+jumps-over+the-lazy+dog." ] //  Limit 9
                        ] //  Keep
                ] //  @"|"
        ];

        BOOL           x = YES;
        for(NSUInteger q = 0, ql = patterns.count; q < ql;) {
            NSString *pattern = patterns[q++];

            for(NSUInteger r = 0, rl = keeps.count; r < rl;) {
                BOOL keep = keeps[r++].boolValue;

                for(NSUInteger s = 0, sl = limits.count; s < sl;) {
                    NSUInteger limit = limits[s++].unsignedLongValue;
                    NSStrArray array = [TestString2 componentsSeparatedByString:pattern limit:limit keepSeparator:keep];

                    for(NSUInteger i = 0, j = array.count; i < j;) {
                        NSString *str = array[i++];
                        NSString *res = results[q - 1][r - 1][s - 1][i - 1];
                        BOOL     y    = [str isEqualToString:res];

                        x = (x && y);
                        if(!y) NSLog(@"\"%@\" == \"%@\" %@", str, res, INDICATOR(y));
                    }
                }
            }
        }

        XCTAssertTrue(x, @"Test case failed.");
    }

    -(void)t_est99SplitByPattern {
        // Test String @"The-quick+brown-fox+jumps-over+the-lazy+dog."
        NSError             *error   = nil;
        NSStrArray          patterns = @[ @"(?:\\-|\\+)", @"\\+", @"\\-", @"\\|", @"\\.", @"", @"\\R" ];
        NSArray<NSNumber *> *limits  = @[ @(0), @(4), @(1), @(99), @(9) ];
        NSArray<NSNumber *> *keeps   = @[ @(NO), @(YES) ];

        for(NSString *pattern in patterns) {
            for(NSNumber *v in keeps) {
                BOOL keep = v.boolValue;

                for(NSNumber *limit in limits) {
                    NSStrArray array = [TestString2 componentsSeparatedByPattern:pattern limit:limit.unsignedLongValue options:0 keepSeparator:keep error:&error];
                    XCTAssertNil(error, @"REGEX ERROR: %@", error.description);

                    NSLog(@"%@", BAR);
                    NSLog(@"         Splitting: \"%@\"", TestString2);
                    NSLog(@"      With Pattern: \"%@\"", pattern);
                    NSLog(@"             Limit: %@", limit);
                    NSLog(@"Keeping Separators: %@", (keep ? @"YES" : @"NO"));
                    NSLog(@"%@", BAR);

                    for(NSUInteger i = 0, j = array.count; i < j;) {
                        NSString *str = array[i];
                        NSLog(@"%3lu> \"%@\"", ++i, str);
                    }
                }
            }
        }
    }

    -(void)t_est96PGFormat {
        NSLog(@"New String = \"%@\"", PGFormat(@"Galen %@", TestString));
    }

    -(void)_testCompareWithClass:(id)obj {
        NSLog(@"Class %@ responds to \"compare:\": %@", NSStringFromClass([obj class]), [obj respondsToSelector:@selector(compare:)] ? @"YES" : @"NO");
    }

    -(void)t_est97Compare {
        CommonBaseClass *c1 = [Subclass1A new];
        CommonBaseClass *c2 = [Subclass1B new];
        CommonBaseClass *c3 = [Subclass1C new];
        CommonBaseClass *c4 = [Subclass1D new];

        [self _testCompareWithClass:c1];
        [self _testCompareWithClass:c2];
        [self _testCompareWithClass:c3];
        [self _testCompareWithClass:c4];
    }

    -(void)t_est97CommonBaseClass {
        Subclass1D *c1 = [[Subclass1D alloc] init];
        Subclass2C *c2 = [[Subclass2C alloc] init];
        NSString   *s1 = @"String #1";
        NSString   *s2 = [NSString stringWithFormat:@"My name is %@!", @"Galen"];

        Class cClass1 = [c1 superclassInCommonWith:c2];
        Class cClass2 = [s1 superclassInCommonWith:s2];
        Class cClass3 = [s1 superclassInCommonWith:c1];

        NSString *c1Name = NSStringFromClass([c1 class]);
        NSString *c2Name = NSStringFromClass([c2 class]);
        NSString *s1Name = NSStringFromClass([s1 class]);
        NSString *s2Name = NSStringFromClass([s2 class]);

        if(cClass1) {
            NSString *fmt = @"Class %@ and class %@ share a common base class: %@";
            NSLog(fmt, c1Name, c2Name, NSStringFromClass(cClass1));
            NSLog(fmt, s1Name, s2Name, NSStringFromClass(cClass2));
            NSLog(fmt, s1Name, c1Name, NSStringFromClass(cClass3));
        }
        else {
            XCTFail(@"Class %@ and class %@ do not have a common base class.", c1Name, c2Name);
            XCTFail(@"Class %@ and class %@ do not have a common base class.", s1Name, s2Name);
            XCTFail(@"Class %@ and class %@ do not have a common base class.", s1Name, c1Name);
        }
    }

    //	-(void)testPerformanceExample {
    //		// This is an example of a performance test case.
    //		[self measureBlock:^{
    //			// Put the code you want to measure the time of here.
    //		}];
    //	}

@end

void FOutput(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    Output([[NSString alloc] initWithFormat:format arguments:args]);
    va_end(args);
}

