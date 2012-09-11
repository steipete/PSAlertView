//
//  PSPDFAlertView.m
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//
//

#import "PSPDFAlertView.h"
#import <objc/runtime.h>

@interface PSPDFAlertView() <UIAlertViewDelegate> {
    id<UIAlertViewDelegate> _realDelegate;
    NSMutableArray *_blocks;
}
@end

@implementation PSPDFAlertView

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithTitle:(NSString *)title {
    return self = [self initWithTitle:title message:nil];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    if ((self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil])) {
        _blocks = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)setDelegate:(id<UIAlertViewDelegate>)delegate {
    if(delegate == nil) {
        [super setDelegate:nil];
        _realDelegate = nil;
    }else {
        [super setDelegate:self];
        if (delegate != self) {
            _realDelegate = delegate;
        }
    }
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block {
    assert([title length] > 0 && "cannot set empty button title");

    [self addButtonWithTitle:title block:block];
    self.cancelButtonIndex = (self.numberOfButtons - 1);
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    assert([title length] > 0 && "cannot add button with empty title");
    [_blocks addObject:block ? [block copy] : [NSNull null]];
    [self addButtonWithTitle:title];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    [self alertView:self clickedButtonAtIndex:buttonIndex];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Run the button's block
    if (buttonIndex >= 0 && buttonIndex < [_blocks count]) {
        id obj = _blocks[buttonIndex];
        if (![obj isEqual:[NSNull null]]) {
            ((void (^)())obj)();
            // manually break potential retain cycle
            _blocks[buttonIndex] = [NSNull null];
        }
    }

    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate alertViewCancel:alertView];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate willPresentAlertView:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate didPresentAlertView:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if ([_realDelegate respondsToSelector:_cmd]) {
        return [_realDelegate alertViewShouldEnableFirstOtherButton:alertView];
    }else {
        return YES;
    }
}


@end
