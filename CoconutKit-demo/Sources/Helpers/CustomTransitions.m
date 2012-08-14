//
//  CustomTransitions.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 8/9/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CustomTransitions.h"

@implementation CustomTransitionFallFromTop

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{    
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup step bringing the appearingView outside the frame
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:0.f y:-CGRectGetHeight(frame) z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    // The animation
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:0.f y:CGRectGetHeight(frame) z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.1;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep31 translateByVectorWithX:0.f y:-CGRectGetHeight(frame) / 3.f z:0.f];
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:appearingView];
    animationStep3.duration = 0.15;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep41 translateByVectorWithX:0.f y:CGRectGetHeight(frame) / 3.f z:0.f];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:appearingView];
    animationStep4.duration = 0.15;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end
