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

CGFloat HLSBorderWidthForBindingInformation(HLSViewBindingInformation *bindingInformation)
{
    return bindingInformation.updatedAutomatically ? 3.f : 1.f;
}

UIColor *HLSBorderColorForBindingInformation(HLSViewBindingInformation *bindingInformation)
{
    if (! bindingInformation.verified) {
        return [UIColor blueColor];
    }
    else {
        return bindingInformation.error ? [UIColor redColor] : [UIColor greenColor];
    }
}

UIColor *HLSBackgroundColorForBindingInformation(HLSViewBindingInformation *bindingInformation)
{
    UIColor *color = [HLSBorderColorForBindingInformation(bindingInformation) colorWithAlphaComponent:0.3f];
    
    if ([bindingInformation.view respondsToSelector:@selector(displayedValue)]) {
        return color;
    }
    else {
        UIImage *stripesImage = [UIImage coconutKitImageNamed:@"BackgroundStripes.png"];
        UIImage *coloredStripesImage = [[[UIImage imageWithColor:color] imageScaledToSize:stripesImage.size] imageMaskedWithImage:stripesImage];
        return [UIColor colorWithPatternImage:coloredStripesImage];
    }
}
