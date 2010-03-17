//
//  PSAlertViewViewController.m
//  PSAlertView
//
//  Created by Peter Steinberger on 17.03.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PSAlertViewViewController.h"
#import "PSAlertView.h"

@implementation PSAlertViewViewController

- (void)secondAlert:(NSString *)caller {
  NSString *msg = [NSString stringWithFormat:@"and i was called from %@", caller];
  PSAlertView *alert = [PSAlertView alertWithTitle:@"There's more!" message:msg];
  [alert setCancelButtonWithTitle:NSLocalizedString(@"Close", @"") block:^{}];
  [alert show];
}

- (IBAction)buttonPressed {
  NSString *outerStringVariable = @"buttonPressed function";
  
  PSAlertView *alert = [PSAlertView alertWithTitle:@"Alert Title" message:@"Hello from Blocks!"];
  [alert setCancelButtonWithTitle:NSLocalizedString(@"Ok", @"") block:^{}];
  [alert addButtonWithTitle:NSLocalizedString(@"More", @"") block: ^{
    [self secondAlert:outerStringVariable];
  }];
  [alert show];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
