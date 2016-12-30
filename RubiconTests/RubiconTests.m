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

	-(void)testCommonBaseClass {
		Subclass1D *c1 = [[Subclass1D alloc] init];
		Subclass2C *c2 = [[Subclass2C alloc] init];
		NSString   *s1 = @"String #1";
		NSString   *s2 = [NSString stringWithFormat:@"My name is %@!", @"Galen"];

		Class cClass1 = [c1 baseClassInCommonWith:c2];
		Class cClass2 = [s1 baseClassInCommonWith:s2];
		Class cClass3 = [s1 baseClassInCommonWith:c1];

		if(cClass1) {
			NSLog(@"Class %@ and class %@ share a common base class: %@",
				  NSStringFromClass([c1 class]),
				  NSStringFromClass([c2 class]),
				  NSStringFromClass(cClass1));
			NSLog(@"Class %@ and class %@ share a common base class: %@",
				  NSStringFromClass([s1 class]),
				  NSStringFromClass([s2 class]),
				  NSStringFromClass(cClass2));
			NSLog(@"Class %@ and class %@ share a common base class: %@",
				  NSStringFromClass([s1 class]),
				  NSStringFromClass([c1 class]),
				  NSStringFromClass(cClass3));
		}
		else {
			XCTFail(@"Class %@ and class %@ do not have a common base class.", NSStringFromClass([c1 class]), NSStringFromClass([c2 class]));
			XCTFail(@"Class %@ and class %@ do not have a common base class.", NSStringFromClass([s1 class]), NSStringFromClass([s2 class]));
			XCTFail(@"Class %@ and class %@ do not have a common base class.", NSStringFromClass([s1 class]), NSStringFromClass([c1 class]));
		}
	}


	//	-(void)testPerformanceExample {
	//		// This is an example of a performance test case.
	//		[self measureBlock:^{
	//			// Put the code you want to measure the time of here.
	//		}];
	//	}

@end
