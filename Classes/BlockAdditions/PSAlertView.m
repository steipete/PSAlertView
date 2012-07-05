//
//  PSAlertView.m
//
//  Created by Peter Steinberger on 17.03.10.
//  Loosely based on Landon Fullers "Using Blocks", Plausible Labs Cooperative.
//  http://landonf.bikemonkey.org/code/iphone/Using_Blocks_1.20090704.html
//

#import "PSAlertView.h"

@implementation PSAlertView

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Static

+ (PSAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message {
  return [[[PSAlertView alloc] initWithTitle:title message:message] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
  if ((self = [super init]) == nil)
    return nil;
  
  /* Initialize the alert */
  _alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
  
  /* Initialize button -> block array */
  _blocks = [[NSMutableArray alloc] init];
  
  return self;
}

- (void)dealloc {
  _alert.delegate = nil;
  [_alert release];
  [_blocks release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)()) block {
  [self addButtonWithTitle:title block:block];
  _alert.cancelButtonIndex = _alert.numberOfButtons - 1;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)()) block {
  [_blocks addObject:[[block copy] autorelease]];
  [_alert addButtonWithTitle:title];
}

- (void)show {
  [_alert show];
  
  /* Ensure that the delegate (that's us) survives until the sheet is dismissed */
  [self retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  /* Run the button's block */
  if (buttonIndex >= 0 && buttonIndex < [_blocks count]) {
    void (^b)() = [_blocks objectAtIndex: buttonIndex];
    b();
  }
  
  /* AlertView to be dismissed, drop our self reference */
  [self release];
}

@end