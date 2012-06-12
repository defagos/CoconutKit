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
    // Translation back to the origin
    CATransform3D originTranslationTransform = CATransform3DMakeTranslation(-CGRectGetMidX(fromRect), -CGRectGetMidY(fromRect), 0.f);
    
    // Scaling matrix
    CATransform3D scaleTransform = CATransform3DMakeScale(CGRectGetWidth(toRect) / CGRectGetWidth(fromRect), 
                                                          CGRectGetHeight(toRect) / CGRectGetHeight(fromRect),
                                                          1.f);
    
    // Translation to toRect center
    CATransform3D toRectCenterTranslationTransform = CATransform3DMakeTranslation(CGRectGetMidX(toRect), CGRectGetMidY(toRect), 0.f);
    
    // Compose the transform
    CATransform3D transform = originTranslationTransform;
    transform = CATransform3DConcat(transform, scaleTransform);
    transform = CATransform3DConcat(transform, toRectCenterTranslationTransform);
    return transform;
}

@end
