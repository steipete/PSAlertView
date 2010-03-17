//
//  PSAlertViewAppDelegate.h
//  PSAlertView
//
//  Created by Peter Steinberger on 17.03.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSAlertViewViewController;

@interface PSAlertViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PSAlertViewViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PSAlertViewViewController *viewController;

@end

