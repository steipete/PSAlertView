//
//  UIColor+PSPDFKitAdditions.m
//  PSPDFKit
//
//  Copyright (c) 2011-2012 Peter Steinberger. All rights reserved.
//

#import "UIColor+PSPDFKitAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIColor (PSPDFKitAdditions)

- (BOOL)pspdf_canProvideRGBComponents {
	switch (self.pspdf_colorSpaceModel) {
		case kCGColorSpaceModelRGB:
		case kCGColorSpaceModelMonochrome:
			return YES;
		default:
			return NO;
	}
}

- (CGColorSpaceModel)pspdf_colorSpaceModel {
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL)pspdf_canProvideRGBColor {
	return (([self pspdf_colorSpaceModel] == kCGColorSpaceModelRGB) || ([self pspdf_colorSpaceModel] == kCGColorSpaceModelMonochrome));
}

- (CGFloat)pspdf_redComponent {
	NSAssert ([self pspdf_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)pspdf_greenComponent {
	NSAssert ([self pspdf_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if ([self pspdf_colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
	return c[1];
}

- (CGFloat)pspdf_blueComponent {
	NSAssert ([self pspdf_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if ([self pspdf_colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
	return c[2];
}

- (CGFloat)pspdf_alphaComponent {
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}

- (CGFloat)pspdf_whiteComponent {
	NSAssert([self pspdf_colorSpaceModel] == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)pspdf_brightness {
    const CGFloat *components = CGColorGetComponents([self pspdf_colorInRGBColorSpace].CGColor);
    CGFloat brightness = 0;
    if (components) {
        brightness = (components[0] * 299 + components[1] * 587 + components[2] * 114)/1000.f;
    }
    return brightness;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Derived Colors

- (UIColor *)pspdf_lightenedColorWithDelta:(CGFloat)delta {
    if (![self pspdf_canProvideRGBColor]) return self;

    CGFloat redComponent = fminf([self pspdf_redComponent]+delta, 1);
    CGFloat greenComponent = fminf([self pspdf_greenComponent]+delta, 1);
    CGFloat blueComponent = fminf([self pspdf_blueComponent]+delta, 1);
    CGFloat alphaComponent = [self pspdf_alphaComponent];

    UIColor *lightenedColor = [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    return lightenedColor;
}

- (UIColor *)pspdf_darkenedColorWithDelta:(CGFloat)delta {
    if (![self pspdf_canProvideRGBColor]) return self;

    CGFloat redComponent = fmaxf([self pspdf_redComponent]-delta, 0);
    CGFloat greenComponent = fmaxf([self pspdf_greenComponent]-delta, 0);
    CGFloat blueComponent = fmaxf([self pspdf_blueComponent]-delta, 0);
    CGFloat alphaComponent = [self pspdf_alphaComponent];

    UIColor *darkenedColor = [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    return darkenedColor;
}

- (UIColor *)pspdf_colorInRGBColorSpace {
    UIColor *newColor = self;

    // convert UIDeviceWhiteColorSpace to UIDeviceRGBColorSpace.
    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        newColor = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    }

    return newColor;
}

@end
