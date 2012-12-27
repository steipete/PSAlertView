//
//  PSPDFAlertView.m
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//
//

#import "PSPDFAlertView.h"
#import "UIColor+PSPDFKitAdditions.h"
#import <objc/runtime.h>

@interface PSPDFAlertView() <UIAlertViewDelegate> {
    id<UIAlertViewDelegate> _realDelegate;
    NSMutableArray *_blocks;
    BOOL _defaultStyleSet;
}

// Title and message label styles
@property (nonatomic, strong) UIColor *labelTextColor;
@property (nonatomic, strong) UIColor *labelShadowColor;
@property (nonatomic, assign) CGSize   labelShadowOffset;

// Button styles
@property (nonatomic, strong) UIColor *buttonTextColor;
@property (nonatomic, strong) UIFont  *buttonFont;
@property (nonatomic, strong) UIColor *buttonShadowColor;
@property (nonatomic, assign) CGSize   buttonShadowOffset;
@property (nonatomic, assign) CGFloat  buttonShadowBlur;

// Background gradient colors and locations
@property (nonatomic, strong) NSArray *gradientLocations;
@property (nonatomic, strong) NSArray *gradientColors;

@property (nonatomic, assign) CGFloat cornerRadius;

// Inner frame shadow (optional)
// Stroke path to cover up pixialation on corners from clipping!
@property (nonatomic, strong) UIColor *innerFrameShadowColor;
@property (nonatomic, strong) UIColor *innerFrameStrokeColor;

// Outer frame color
@property (nonatomic, strong) UIColor *outerFrameColor;
@property (nonatomic, assign) CGFloat  outerFrameLineWidth;
@property (nonatomic, strong) UIColor *outerFrameShadowColor;
@property (nonatomic, assign) CGSize   outerFrameShadowOffset;
@property (nonatomic, assign) CGFloat  outerFrameShadowBlur;

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
    if (delegate == nil) {
        [super setDelegate:nil];
        _realDelegate = nil;
    }else {
        [super setDelegate:self];
        if (delegate != self) {
            _realDelegate = delegate;
        }
    }
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block {
    block = [block copy];
    return [self setCancelButtonWithTitle:title extendedBlock:^(PSPDFAlertView *alert, NSInteger buttonIndex) {
        if (block) block();
    }];
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title extendedBlock:(void (^)(PSPDFAlertView *alert, NSInteger buttonIndex))block {
    assert([title length] > 0 && "cannot set empty button title");

    NSUInteger buttonIndex = [self addButtonWithTitle:title extendedBlock:block];
    self.cancelButtonIndex = buttonIndex;
    return buttonIndex;
}

- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    block = [block copy];
    return[self addButtonWithTitle:title extendedBlock:^(PSPDFAlertView *alert, NSInteger buttonIndex) {
        if (block) block();}
     ];
}

- (NSInteger)addButtonWithTitle:(NSString *)title extendedBlock:(void (^)(PSPDFAlertView *alert, NSInteger buttonIndex))block {
    assert([title length] > 0 && "cannot add button with empty title");
    [_blocks addObject:block ? [block copy] : [NSNull null]];
    return [self addButtonWithTitle:title];
}

- (NSInteger)addButtonWithTitle:(NSString *)title {
    NSInteger buttonIndex = [super addButtonWithTitle:title];

    // ensure blocks array is equal to number of buttons.
    while ([_blocks count] < self.numberOfButtons) {
        [_blocks addObject:[NSNull null]];
    }

    return buttonIndex;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    [self alertView:self clickedButtonAtIndex:buttonIndex];
}

- (void)showWithTintColor:(UIColor *)tintColor {
    self.tintColor = tintColor;
    [self show];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Run the button's block
    if (buttonIndex >= 0 && buttonIndex < [_blocks count]) {
        id obj = _blocks[buttonIndex];
        if (![obj isEqual:[NSNull null]]) {
            ((void (^)())obj)(alertView, buttonIndex);
        }
    }

    if ([_realDelegate respondsToSelector:_cmd]) {
        [_realDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }

    // manually break potential retain cycles
    [_blocks removeAllObjects];
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

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Tint Color

- (void)setTintColor:(UIColor *)tintColor {
    if (tintColor != _tintColor) {
        _tintColor = tintColor;

        if (tintColor) {
            [self setDefaultStyle];
            if ([self.tintColor pspdf_brightness] > 0.4) {

                self.labelTextColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.9f];
                self.labelShadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
                self.outerFrameColor = [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f];

                self.buttonTextColor = self.labelTextColor;
                self.buttonShadowColor = [UIColor whiteColor];

                if ([self.tintColor isEqual:[UIColor whiteColor]]) {
                    self.labelTextColor = [UIColor colorWithRed:0.11f green:0.08f blue:0.39f alpha:1.00f];
                    self.buttonTextColor = self.labelTextColor;
                }
            }else {
                self.labelTextColor = [UIColor whiteColor];
                self.labelShadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
                self.outerFrameColor = [UIColor colorWithRed:250.0f/255.0f green:250.0f/255.0f blue:250.0f/255.0f alpha:1.0f];

                self.buttonTextColor = self.labelTextColor;
                self.buttonShadowColor = [UIColor blackColor];
            }

            UIColor *topGradient = [tintColor pspdf_lightenedColorWithDelta:0.10f];
            UIColor *middleGradient = tintColor;
            UIColor *bottomGradient = [tintColor pspdf_darkenedColorWithDelta:0.18f];
            self.gradientColors = @[topGradient, middleGradient, bottomGradient];
        }
    }
}

//  Created by Michał Zaborowski on 18/07/12.
//  Copyright (c) 2012 Michał Zaborowski. All rights reserved.
//  Modified by Peter Steinberger.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

- (void)setDefaultStyle {
    if (_defaultStyleSet) return;
    _defaultStyleSet = YES;

    self.buttonShadowBlur = 2.0f;
    self.buttonShadowOffset = CGSizeMake(0.5f, 0.5f);
    self.labelShadowOffset = CGSizeMake(0.0f, 1.0f);
    self.gradientLocations = @[ @0.0f, @0.57f, @1.0f];
    self.cornerRadius = 10.0f;
    self.labelTextColor = [UIColor whiteColor];
    self.outerFrameLineWidth = 2.0f;
    self.outerFrameShadowBlur = 6.0f;
    self.outerFrameShadowColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    self.outerFrameShadowOffset = CGSizeMake(0.0f, 1.0f);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.tintColor) {
        for (UIView *subview in self.subviews) {
            // Find and hide UIImageView containing blue background
            if ([subview isMemberOfClass:[UIImageView class]]) {
                subview.hidden = YES;
            }
            // Find and get styles of UILabels
            if ([subview isMemberOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)subview;
                label.textColor = self.labelTextColor;
                label.shadowColor = self.labelShadowColor;
                label.shadowOffset = self.labelShadowOffset;
            }
            // Hide button title labels
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                button.titleLabel.alpha = 0;
            }
        }
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    if (self.tintColor) {
        CGContextRef context = UIGraphicsGetCurrentContext();

        // Create base shape with rounded corners from bounds
        CGRect activeBounds = self.bounds;
        CGFloat cornerRadius = self.cornerRadius;
        CGFloat inset = 5.5f;
        CGFloat originX = activeBounds.origin.x + inset;
        CGFloat originY = activeBounds.origin.y + inset;
        CGFloat width = activeBounds.size.width - (inset*2.0f);
        CGFloat height = activeBounds.size.height - ((inset+2.0)*2.0f);

        CGRect bPathFrame = CGRectMake(originX, originY, width, height);
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:bPathFrame cornerRadius:cornerRadius].CGPath;

        // Create base shape with fill and shadow
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
        CGContextSetShadowWithColor(context, self.outerFrameShadowOffset, self.outerFrameShadowBlur, self.outerFrameShadowColor.CGColor);
        CGContextDrawPath(context, kCGPathFill);

        // Clip state
        CGContextSaveGState(context); //Save Context State Before Clipping To "path"
        CGContextAddPath(context, path);
        CGContextClip(context);

        // Draw grafient from gradientLocations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        size_t count = [self.gradientLocations count];

        CGFloat *locations = malloc(count * sizeof(CGFloat));
        [self.gradientLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            locations[idx] = [((NSNumber *)obj) floatValue];
        }];

        CGFloat *components = malloc([self.gradientColors count] * 4 * sizeof(CGFloat));

        [self.gradientColors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
            NSInteger startIndex = (idx * 4);
            [color getRed:&components[startIndex]
                    green:&components[startIndex+1]
                     blue:&components[startIndex+2]
                    alpha:&components[startIndex+3]];
        }];

        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);

        CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
        CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);

        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
        free(locations);
        free(components);

        // Stroke color for inner path
        if (self.innerFrameShadowColor || self.innerFrameStrokeColor) {
            CGContextAddPath(context, path);
            CGContextSetLineWidth(context, 3.0f);

            if (self.innerFrameStrokeColor) {
                CGContextSetStrokeColorWithColor(context, self.innerFrameStrokeColor.CGColor);
            }
            if (self.innerFrameShadowColor) {
                CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 6.0f, self.innerFrameShadowColor.CGColor);
            }
            CGContextDrawPath(context, kCGPathStroke);
        }

        // Stroke path to cover up pixialation on corners from clipping
        CGContextRestoreGState(context); // Restore First Context State Before Clipping "path"
        CGContextAddPath(context, path);
        CGContextSetLineWidth(context, self.outerFrameLineWidth);
        CGContextSetStrokeColorWithColor(context, self.outerFrameColor.CGColor);
        CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 0.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.1f].CGColor);
        CGContextDrawPath(context, kCGPathStroke);

        // Drawing button labels
        for (UIView *subview in self.subviews){
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;

                CGContextSetTextDrawingMode(context, kCGTextFill);
                CGContextSetFillColorWithColor(context, self.buttonTextColor.CGColor);
                CGContextSetShadowWithColor(context, self.buttonShadowOffset, self.buttonShadowBlur, self.buttonShadowColor.CGColor);

                UIFont *buttonFont = button.titleLabel.font;
                if (self.buttonFont)
                    buttonFont = self.buttonFont;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
                [button.titleLabel.text drawInRect:CGRectMake(button.frame.origin.x, button.frame.origin.y+10, button.frame.size.width, button.frame.size.height) withFont:buttonFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
#else
                [button.titleLabel.text drawInRect:CGRectMake(button.frame.origin.x, button.frame.origin.y+10, button.frame.size.width, button.frame.size.height) withFont:buttonFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
#endif
            }
        }
    }
}

@end
