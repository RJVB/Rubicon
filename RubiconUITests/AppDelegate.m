//
//  AppDelegate.m
//  RubiconUITests
//
//  Created by Galen Rhodes on 12/30/16.
//  Copyright © 2016 Project Galen. All rights reserved.
//

#import "AppDelegate.h"
#import "PGNodeView.h"

@interface AppDelegate()

	@property(weak) IBOutlet NSWindow   *window;
	@property(weak) IBOutlet PGNodeView *view;
	@property(weak) IBOutlet NSSlider   *slider;

@end

@implementation AppDelegate {
	}

	@synthesize window = _window;
	@synthesize view = _view;

	-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	}

	-(void)applicationWillTerminate:(NSNotification *)aNotification {
		// Insert code here to tear down your application
	}

	-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
		return YES;
	}

@end
