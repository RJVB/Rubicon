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

	-(void)testCompareWithClass:(id)obj {
		NSLog(@"Class %@ responds to \"compare:\": %@", NSStringFromClass([obj class]), @([obj respondsToSelector:@selector(compare:)]));
	}

	-(void)testMacros {
		PGMacros *macros = [PGMacros macrosWithHandler:^NSString *(NSString *label, NSString *whole, NSRange range) {
			NSLog(@"Found Macro: %@", label);
			return [NSString stringWithFormat:@"*** %@%@ ***", label, NSStringFromRange(range)];
		}];

		NSError  *error  = nil;
		NSString *result = [macros stringByProcessingMacrosIn:@"Now is the ${ time_space} for all good ${men } to come to the ${ aid } of their ${country}."
														error:&error];

		if(error) {
			XCTFail(@"Error: %@", [error description]);
		}
		else {
			NSLog(@"Results: \"%@\"", result);
		}
	}

	-(void)testCompare {
		[self testCompareWithClass:[[NSObject alloc] init]];
		[self testCompareWithClass:@(123)];
		[self testCompareWithClass:@"Galen"];
		[self testCompareWithClass:[NSString stringWithFormat:@"My name is %@!", @"Galen"]];
		[self testCompareWithClass:@[ @"a", @"b", @"c" ]];
		[self testCompareWithClass:[[PGBinaryTreeLeaf alloc] initWithValue:@"Rhodes" forKey:@"Galen"]];
	}

	-(void)testCommonBaseClass {
		Subclass1D *c1 = [[Subclass1D alloc] init];
		Subclass2C *c2 = [[Subclass2C alloc] init];
		NSString   *s1 = @"String #1";
		NSString   *s2 = [NSString stringWithFormat:@"My name is %@!", @"Galen"];

		Class cClass1 = [c1 baseClassInCommonWith:c2];
		Class cClass2 = [s1 baseClassInCommonWith:s2];
		Class cClass3 = [s1 baseClassInCommonWith:c1];

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
