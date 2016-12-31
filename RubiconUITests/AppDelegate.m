//
//  AppDelegate.m
//  RubiconUITests
//
//  Created by Galen Rhodes on 12/30/16.
//  Copyright © 2016 Project Galen. All rights reserved.
//

#import "AppDelegate.h"
#import "PGTestView.h"

@interface AppDelegate()

	@property(weak) IBOutlet NSWindow   *window;
	@property(weak) IBOutlet PGTestView *view;
	@property(weak) IBOutlet NSSlider   *slider;

	-(IBAction)sliderAction:(id)sender;

@end

@implementation AppDelegate {
	}

	@synthesize window = _window;
	@synthesize view = _view;
	@synthesize slider = _slider;

	-(IBAction)sliderAction:(id)sender {
		self.view.fontSize     = self.slider.doubleValue;
		self.view.needsDisplay = YES;
	}

	-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
		self.slider.integerValue = (NSInteger)self.view.fontSize;
	}

	-(void)applicationWillTerminate:(NSNotification *)aNotification {
		// Insert code here to tear down your application
	}

@end
