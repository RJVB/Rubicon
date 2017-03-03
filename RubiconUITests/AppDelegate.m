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

	@property(weak) IBOutlet NSWindow    *window;
	@property(weak) IBOutlet PGNodeView  *view;
	@property(weak) IBOutlet NSSlider    *slider;
	@property(weak) IBOutlet NSTextField *textField;

@end

@implementation AppDelegate {
	}

	@synthesize window = _window;
	@synthesize view = _view;
	@synthesize slider = _slider;
	@synthesize textField = _textField;

	-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
		self.view.rootNode = [[PGBinaryTreeNode alloc] initWithKey:@"A" value:@"A"];
	}

	-(void)applicationWillTerminate:(NSNotification *)aNotification {
	}

	-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
		return YES;
	}

	-(IBAction)insertText:(id)sender {
		NSString *aKey = self.textField.stringValue;

		if(aKey.trim.length) {
			PGBinaryTreeNode *node = self.view.rootNode;

			if(node) {
				self.view.rootNode = [node insertValue:aKey forKey:aKey comparator:^NSComparisonResult(id obj1, id obj2) {
					return [(NSString *)obj1 compare:(NSString *)obj2];
				}];
			}
			else {
				self.view.rootNode = [[PGBinaryTreeNode alloc] initWithKey:aKey value:aKey];
			}

			NSLog(@"Insert Text: %@; count = %@", aKey, @(self.view.rootNode.rootNode.count));
			self.textField.stringValue = @"";
		}
	}

	-(IBAction)removeText:(id)sender {
		NSString *key = self.textField.stringValue;

		if(key.trim.length) {
			PGBinaryTreeNode *node = [self.view.rootNode findNodeForKey:key comparator:^NSComparisonResult(id obj1, id obj2) {
				return [(NSString *)obj1 compare:(NSString *)obj2];
			}];

			if(node) {
				NSLog(@"Removing node %@", node);
				self.view.rootNode = [node remove];
			}

			NSLog(@"Remove Text: %@; count = %@", key, @(self.view.rootNode.rootNode.count));
			self.textField.stringValue = @"";
		}
	}

@end
