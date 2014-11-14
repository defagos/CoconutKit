//
//  HLSViewBindingDebugOverlayApperance.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingDebugOverlayApperance.h"

#import "UIImage+HLSExtensions.h"
#import "UIView+HLSViewBindingImplementation.h"

CGFloat HLSViewBindingDebugOverlayBorderWidth(BOOL updatedAutomatically)
{
    return updatedAutomatically ? 3.f : 1.f;
}

UIColor *HLSViewBindingDebugOverlayBorderColor(BOOL isVerified, BOOL hasError)
{
    if (! isVerified) {
        return [UIColor blueColor];
    }
    else {
        return hasError ? [UIColor redColor] : [UIColor greenColor];
    }
}

UIColor *HLSViewBindingDebugOverlayBackgroundColor(BOOL isVerified, BOOL hasError, BOOL supportsInput)
{
    UIColor *color = [HLSViewBindingDebugOverlayBorderColor(isVerified, hasError) colorWithAlphaComponent:HLSViewBindingDebugOverlayAlpha()];
    
    if (supportsInput) {
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
    return 0.3f;
}