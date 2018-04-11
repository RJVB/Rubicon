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
    NOutput(PGFormat(@"%@\r\n", string));
}

@implementation RubiconTests

    -(void)setUp {
        [super setUp];
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    -(void)tearDown {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        [super tearDown];
    }

    -(void)test92DynamicByteQueue {
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

    -(void)test93TemporaryDirectories {
        NSError *error = nil;
        NSLog(@"Temporary Directory: \"%@\"", PGTemporaryDirectory(&error).absoluteString);
        if(error) {
            XCTFail(@"Error: %@", error.description);
        }
    }

    -(void)test93TemporaryFiles {
        NSError *error = nil;
        NSLog(@"Temporary File: \"%@\"", PGTemporaryFile(@"Test.txt", &error).absoluteString);
        if(error) {
            XCTFail(@"Error: %@", error.description);
        }
    }

    -(void)test94StringByCenteringInPaddingOfLength {
        NSArray<NSString *> *strings = @[ @"Galen", @"Galen Rhodes", @"GalenGlenn", @"" ];
        NSArray<NSString *> *results = @[ @"=+Galen+=+", @"alen Rhode", @"GalenGlenn", @"=+-+=+-+=+" ];
        BOOL                overall  = YES;

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

    -(void)test94StringByFrontPaddingToLength {
        NSArray<NSString *> *strings = @[ @"Galen", @"Galen Rhodes", @"GalenGlenn", @"" ];
        NSArray<NSString *> *results = @[ @"=+-+=Galen", @"len Rhodes", @"GalenGlenn", @"=+-+=+-+=+" ];
        BOOL                overall  = YES;

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

    -(void)test95FilterOutputStream {
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

    -(void)test95Base64Function {
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

    -(void)test95Base64OutputStream {
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

    -(void)test98SplitByString {
        // Test String @"The-quick+brown-fox+jumps-over+the-lazy+dog."
        NSArray<NSString *> *patterns = @[ @"-", @"+", @".", @"|" ];
        NSArray<NSNumber *> *limits   = @[ @(0), @(4), @(1), @(99), @(9) ];
        NSArray<NSNumber *> *keeps    = @[ @(NO), @(YES) ];
        NSArray             *results  = @[
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
                    NSUInteger          limit  = limits[s++].unsignedLongValue;
                    NSArray<NSString *> *array = [TestString2 componentsSeparatedByString:pattern limit:limit keepSeparator:keep];

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

    -(void)test99SplitByPattern {
        // Test String @"The-quick+brown-fox+jumps-over+the-lazy+dog."
        NSError             *error    = nil;
        NSArray<NSString *> *patterns = @[ @"(?:\\-|\\+)", @"\\+", @"\\-", @"\\|", @"\\.", @"", @"\\R" ];
        NSArray<NSNumber *> *limits   = @[ @(0), @(4), @(1), @(99), @(9) ];
        NSArray<NSNumber *> *keeps    = @[ @(NO), @(YES) ];

        for(NSString *pattern in patterns) {
            for(NSNumber *v in keeps) {
                BOOL keep = v.boolValue;

                for(NSNumber *limit in limits) {
                    NSArray<NSString *> *array = [TestString2 componentsSeparatedByPattern:pattern limit:limit.unsignedLongValue options:0 keepSeparator:keep error:&error];
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

    -(void)test96PGFormat {
        NSLog(@"New String = \"%@\"", PGFormat(@"Galen %@", TestString));
    }

    -(void)testCompareWithClass:(id)obj {
        NSLog(@"Class %@ responds to \"compare:\": %@", NSStringFromClass([obj class]), [obj respondsToSelector:@selector(compare:)] ? @"YES" : @"NO");
    }

    -(void)test97Compare {
        CommonBaseClass *c1 = [Subclass1A new];
        CommonBaseClass *c2 = [Subclass1B new];
        CommonBaseClass *c3 = [Subclass1C new];
        CommonBaseClass *c4 = [Subclass1D new];

        [self testCompareWithClass:c1];
        [self testCompareWithClass:c2];
        [self testCompareWithClass:c3];
        [self testCompareWithClass:c4];
    }

    -(void)test97CommonBaseClass {
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
