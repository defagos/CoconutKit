//
//  HLSTransform.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/6/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSTransform.h"

@implementation HLSTransform

+ (CGAffineTransform)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    // Scaling matrix
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(CGRectGetWidth(toRect) / CGRectGetWidth(fromRect), 
                                                                  CGRectGetHeight(toRect) / CGRectGetHeight(fromRect));
    
    // Rect centers in the parent view coordinate system
    CGPoint fromRectCenterInCommonCoordinateSystem = CGPointMake(CGRectGetMidX(fromRect), CGRectGetMidY(fromRect));
    CGPoint toRectCenterInCommonCoordinateSystem = CGPointMake(CGRectGetMidX(toRect), CGRectGetMidY(toRect));
    
    // Translation matrix
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(toRectCenterInCommonCoordinateSystem.x - fromRectCenterInCommonCoordinateSystem.x, 
                                                                              toRectCenterInCommonCoordinateSystem.y - fromRectCenterInCommonCoordinateSystem.y);
    
    return CGAffineTransformConcat(scaleTransform, translationTransform);
}

@end
