//
//  HLSViewBindingDebugOverlayApperance.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingDebugOverlayApperance.h"

#import "UIColor+HLSExtensions.h"
#import "UIImage+HLSExtensions.h"
#import "UIView+HLSViewBindingImplementation.h"

CGFloat HLSViewBindingDebugOverlayBorderWidth(BOOL isViewAutomaticallyUpdated)
{
    return isViewAutomaticallyUpdated ? 3.f : 1.f;
}

UIColor *HLSViewBindingDebugOverlayBorderColor(BOOL isVerified, BOOL hasError)
{
    if (! isVerified) {
        return [UIColor yellowColor];
    }
    else {
        return hasError ? [UIColor redColor] : [UIColor colorWithNonNormalizedRed:0 green:192 blue:0 alpha:1.f];
    }
}

UIColor *HLSViewBindingDebugOverlayBackgroundColor(BOOL isVerified, BOOL hasError, BOOL isModelAutomaticallyUpdated)
{
    UIColor *color = [HLSViewBindingDebugOverlayBorderColor(isVerified, hasError) colorWithAlphaComponent:HLSViewBindingDebugOverlayAlpha()];
    if (isModelAutomaticallyUpdated) {
        return color;
    }
    else {
        UIImage *stripesPatternImage = HLSViewBindingDebugOverlayStripesPatternImage();
        UIImage *coloredStripesPatternImage = [[[UIImage imageWithColor:color] imageScaledToSize:stripesPatternImage.size] imageMaskedWithImage:stripesPatternImage];
        return [UIColor colorWithPatternImage:coloredStripesPatternImage];
    }
}

UIImage *HLSViewBindingDebugOverlayStripesPatternImage(void)
{
    return [UIImage coconutKitImageNamed:@"BackgroundStripes.png"];
}

CGFloat HLSViewBindingDebugOverlayAlpha(void)
{
    return 0.4f;
}
