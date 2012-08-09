//
//  CustomTransitions.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 8/9/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CustomTransitions.h"

@implementation CustomTransitionPushFromRight

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup step bringing the appearingView outside the frame
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:CGRectGetWidth(frame) y:0.f z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    // The push itself, moving the two views to the left
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-CGRectGetWidth(frame) y:0.f z:0.f];
    [viewAnimationStep21 scaleWithXFactor:0.5f yFactor:0.5f zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 translateByVectorWithX:-CGRectGetWidth(frame) y:0.f z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end
