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

@interface RubiconTests : XCTestCase

@end

@implementation RubiconTests

    -(void)setUp {
        [super setUp];
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    -(void)tearDown {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        [super tearDown];
    }

    -(void)te2stPGFormat {
        NSLog(@"New String = \"%@\"", PGFormat(@"Galen %@", @"Rhodes"));
    }

    -(void)te2stCompareWithClass:(id)obj {
        NSLog(@"Class %@ responds to \"compare:\": %@", NSStringFromClass([obj class]), @([obj respondsToSelector:@selector(compare:)]));
    }

    -(void)te2stMacros {
        PGMacros *macros = [PGMacros macrosWithHandler:^NSString *(NSString *label, NSString *whole, NSRange range) {
            NSLog(@"Found Macro: %@", label);
            return [NSString stringWithFormat:@"*** %@%@ ***", label, NSStringFromRange(range)];
        }];

        NSError  *error  = nil;
        NSString *result = [macros stringByProcessingMacrosIn:@"Now is the ${ time_space} for all good ${men } to come to the ${ aid } of their ${country}." error:&error];

        if(error) {
            XCTFail(@"Error: %@", [error description]);
        }
        else {
            NSLog(@"Results: \"%@\"", result);
        }
    }

    -(void)te2stCompare {
        [self te2stCompareWithClass:[[NSObject alloc] init]];
        [self te2stCompareWithClass:@(123)];
        [self te2stCompareWithClass:@"Galen"];
        [self te2stCompareWithClass:[NSString stringWithFormat:@"My name is %@!", @"Galen"]];
        [self te2stCompareWithClass:@[ @"a", @"b", @"c" ]];
    }

    -(void)te2stCommonBaseClass {
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

    -(NSInteger)performWithReturnInTry {
        NSInteger aNumber = 3;

        @try {
            return aNumber;
        }
        @finally {
            NSLog(@"Finally block has been executed.");
        }
    }

    -(void)te2stFinallyExecutedWithReturnFromTry {
        NSLog(@"Value returned: %@", @([self performWithReturnInTry]));
    }

    -(void)ifthentest:(BOOL)a b:(BOOL)b {
        if(a) if(b) NSLog(@"if(b)"); else NSLog(@"else b"); else NSLog(@"else a");
    }

    -(void)te2stIfThenElse {
        [self ifthentest:NO b:NO];
        [self ifthentest:NO b:YES];
        [self ifthentest:YES b:YES];
        [self ifthentest:YES b:NO];
    }

    -(void)testTrim {
        NSString *a1 = @"BOB";
        NSString *b1 = @" BOB \r\n";

        NSString *a2 = [a1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *b2 = [b1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSLog(@"a1 = %p", (__bridge void *)a1);
        NSLog(@"a2 = %p", (__bridge void *)a2);
        NSLog(@"b1 = %p", (__bridge void *)b1);
        NSLog(@"b2 = %p", (__bridge void *)b2);
    }

    //	-(void)testPerformanceExample {
    //		// This is an example of a performance test case.
    //		[self measureBlock:^{
    //			// Put the code you want to measure the time of here.
    //		}];
    //	}

@end
