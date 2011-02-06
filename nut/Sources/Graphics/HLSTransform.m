//
//  HLSTransform.m
//  nut
//
//  Created by Samuel Défago on 2/6/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSTransform.h"

@implementation HLSTransform

+ (CGAffineTransform)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    // Scaling matrix
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(toRect.size.width / fromRect.size.width, 
                                                                  toRect.size.height / fromRect.size.height);
    
    // Rect centers in the parent view coordinate system
    CGPoint beginCenterInCommonCoordinateSystem = CGPointMake(CGRectGetMidX(fromRect), CGRectGetMidY(fromRect));
    CGPoint endCenterInCommonCoordinateSystem = CGPointMake(CGRectGetMidX(toRect), CGRectGetMidY(toRect));
    
    // Translation matrix
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(endCenterInCommonCoordinateSystem.x - beginCenterInCommonCoordinateSystem.x, 
                                                                              endCenterInCommonCoordinateSystem.y - beginCenterInCommonCoordinateSystem.y);
    
    return CGAffineTransformConcat(scaleTransform, translationTransform);
}

@end
