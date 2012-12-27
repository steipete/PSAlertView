//
//  PSCViewController.m
//  PSAlertViewExample
//
//  Created by Peter Steinberger on 12/27/12.
//  Copyright (c) 2012 PSPDFKit. All rights reserved.
//

#import "PSCViewController.h"
#import "PSPDFAlertView.h"
#import <objc/runtime.h>

// NOP here.
#define PSPDFLocalize

// Key to register alertViews to enable the return key.
const char kPSPDFAlertViewKey;

@interface PSCViewController () <UITextFieldDelegate>
@end

@implementation PSCViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [testButton setTitle:@"Show Alert" forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(showAlertAction) forControlEvents:UIControlEventTouchUpInside];
    [testButton sizeToFit];
    testButton.center = self.view.center;
    [self.view addSubview:testButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showAlertAction];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)showAlertAction {
    PSPDFAlertView *titlePrompt = [[PSPDFAlertView alloc] initWithTitle:PSPDFLocalize(@"Title") message:@"This is a test alert."];
    titlePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;

    [titlePrompt textFieldAtIndex:0].text = @"Preset Text";
    [titlePrompt setCancelButtonWithTitle:PSPDFLocalize(@"Cancel") block:nil];
    [titlePrompt addButtonWithTitle:PSPDFLocalize(@"Save") extendedBlock:^(PSPDFAlertView *alert, NSInteger buttonIndex) {
        NSString *newSubject = [alert textFieldAtIndex:0].text ?: @"";
        NSLog(@"Entered text: %@", newSubject);
    }];

    // add support for the return key
    [[titlePrompt textFieldAtIndex:0] setDelegate:self];
    objc_setAssociatedObject([titlePrompt textFieldAtIndex:0], &kPSPDFAlertViewKey, titlePrompt, OBJC_ASSOCIATION_ASSIGN);

    [titlePrompt showWithTintColor:[UIColor colorWithRed:0.207 green:0.345 blue:0.101 alpha:1.000]];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate

// Enable the return key on the alert view.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIAlertView *alertView = objc_getAssociatedObject(textField, &kPSPDFAlertViewKey);
    if (alertView) { [alertView dismissWithClickedButtonIndex:1 animated:YES]; return YES; }
    else return NO;
}
@end
