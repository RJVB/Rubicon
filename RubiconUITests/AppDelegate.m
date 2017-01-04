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
		self.view.rootNode = [[PGBinaryTreeKVNode alloc] initWithValue:@"A" forKey:@"A"];
	}

	-(void)applicationWillTerminate:(NSNotification *)aNotification {
	}

	-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
		return YES;
	}

	-(IBAction)insertText:(id)sender {
		NSString *aKey = self.textField.stringValue;

		if(aKey.trim.length) {
			PGBinaryTreeLeaf *node = self.view.rootNode;

			if(node) {
				self.view.rootNode = [node insertValue:aKey forKey:aKey withComparator:^NSComparisonResult(id obj1, id obj2) {
					return [(NSString *)obj1 compare:(NSString *)obj2];
				}].root;
			}
			else {
				self.view.rootNode = [[PGBinaryTreeKVNode alloc] initWithValue:aKey forKey:aKey];
			}

			NSLog(@"Insert Text: %@; count = %@", aKey, @(self.view.rootNode.root.count));
			self.textField.stringValue = @"";
		}
	}

	-(IBAction)removeText:(id)sender {
		NSString *key = self.textField.stringValue;

		if(key.trim.length) {

			PGBinaryTreeLeaf *node = [self.view.rootNode find:key withComparator:^NSComparisonResult(id obj1, id obj2) {
				return [(NSString *)obj1 compare:(NSString *)obj2];
			}];

			if(node && !node.isLeaf) {
				NSLog(@"Removing node %@", node);
				self.view.rootNode = [node remove];
			}

			NSLog(@"Remove Text: %@; count = %@", key, @(self.view.rootNode.root.count));
			self.textField.stringValue = @"";
		}
	}

@end
