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

	-(void)testAlertWindow {
		NSApplication *app;  // Without these 2 lines, seg fault may occur
		app = [NSApplication sharedApplication];

		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Hello alert"];
		[alert addButtonWithTitle:@"All done"];
		NSModalResponse result = [alert runModal];
		if(result == NSAlertFirstButtonReturn) {
			NSLog(@"First button pressed");
		}
	}

	-(void)testSimpleWindow {
		NSApplication *app = [NSApplication sharedApplication];

		NSRect   frame   = NSMakeRect(0, 0, 200, 200);
		NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

		XCTAssertNotNil(window, @"Window not created.");

		[window setBackgroundColor:[NSColor blueColor]];
		[window makeKeyAndOrderFront:NSApp];

		struct timespec ts = { .tv_sec = 20, .tv_nsec = 0 };
		nanosleep(&ts, NULL);
	}

	-(void)testFontCreation {
		NSString *fontName = @".HelveticaNeueDeskInterface-MediumP4";
		NSFont   *aFont    = [NSFont fontWithName:fontName size:12];

		if(aFont) {
			NSLog(@"Font %@ created.", aFont.fontName);
		}
		else {
			XCTAssertNotNil(aFont, @"Font %@ not created.", fontName);
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
