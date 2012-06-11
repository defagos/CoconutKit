//
//  HLS3DTransform.m
//  CoconutKit
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLS3DTransform.h"

@implementation HLS3DTransform

+ (CATransform3D)transformFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    // Scaling matrix
    CATransform3D scaleTransform = CATransform3DMakeScale(toRect.size.width / fromRect.size.width, 
                                                          toRect.size.height / fromRect.size.height,
                                                          1.f);
    
    // Rect centers in the parent view coordinate system
    CGPoint beginCenterInCommonCoordinateSystem = CGPointMake(CGRectGetMidX(fromRect), CGRectGetMidY(fromRect));
    CGPoint endCenterInCommonCoordinateSystem = CGPointMake(CGRectGetMidX(toRect), CGRectGetMidY(toRect));
    
    // Translation matrix
    CATransform3D translationTransform = CATransform3DMakeTranslation(endCenterInCommonCoordinateSystem.x - beginCenterInCommonCoordinateSystem.x, 
                                                                      endCenterInCommonCoordinateSystem.y - beginCenterInCommonCoordinateSystem.y,
                                                                      0.f);
    
    return CATransform3DConcat(scaleTransform, translationTransform);
}

@end
