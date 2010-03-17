//
//  PSAlertViewAppDelegate.m
//  PSAlertView
//
//  Created by Peter Steinberger on 17.03.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PSAlertViewAppDelegate.h"
#import "PSAlertViewViewController.h"

@implementation PSAlertViewAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
