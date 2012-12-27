//
//  UIColor+PSPDFKitAdditions.h
//  PSPDFKit
//
//  Copyright (c) 2011-2012 Peter Steinberger. All rights reserved.
//

@interface UIColor (PSPDFKitAdditions)

/// Derived colors.
- (UIColor *)pspdf_lightenedColorWithDelta:(CGFloat)delta;
- (UIColor *)pspdf_darkenedColorWithDelta:(CGFloat)delta;

// Calculates the total brightness of the current color.
- (CGFloat)pspdf_brightness;

@end
