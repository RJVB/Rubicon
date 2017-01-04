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
			NSLog(@"Insert Text: %@", aKey);
			PGBinaryTreeLeaf *node = self.view.rootNode;

			if(node) {
				self.view.rootNode = [node insertValue:aKey forKey:aKey withComparator:^NSComparisonResult(id obj1, id obj2) {
					return [(NSString *)obj1 compare:(NSString *)obj2];
				}].root;
			}
			else {
				self.view.rootNode = [[PGBinaryTreeKVNode alloc] initWithValue:aKey forKey:aKey];
			}

			self.textField.stringValue = @"";
		}
	}

	-(IBAction)removeText:(id)sender {
		NSString *key = self.textField.stringValue;

		if(key.trim.length) {
			NSLog(@"Remove Text: %@", key);

			PGBinaryTreeLeaf *node = [self.view.rootNode find:key withComparator:^NSComparisonResult(id obj1, id obj2) {
				return [(NSString *)obj1 compare:(NSString *)obj2];
			}];

			if(node && !node.isLeaf) {
				PGBinaryTreeLeaf *n = (node.parent ? node.parent : (node.left.isLeaf ? node.right : node.left));
				[node remove];
				n = n.root;
				self.view.rootNode = (n.isLeaf ? nil : n);
			}

			self.textField.stringValue = @"";
		}
	}

@end
