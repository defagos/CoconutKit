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
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 translateByVectorWithX:0.f y:-CGRectGetHeight(frame) z:0.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    // The animation
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 translateByVectorWithX:0.f y:CGRectGetHeight(frame) z:0.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.1;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation layerAnimation];
    [layerAnimation31 translateByVectorWithX:0.f y:-CGRectGetHeight(frame) / 3.f z:0.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:appearingView];
    animationStep3.duration = 0.15;
    [animationSteps addObject:animationStep3];
    
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation layerAnimation];
    [layerAnimation41 translateByVectorWithX:0.f y:CGRectGetHeight(frame) / 3.f z:0.f];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:appearingView];
    animationStep4.duration = 0.15;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)reverseAnimationStepsWithAppearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView
                                            inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup step bringing the appearingView outside the frame
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation51 = [HLSLayerAnimation layerAnimation];
    [layerAnimation51 translateByVectorWithX:0.f y:-CGRectGetHeight(frame) z:0.f];
    [animationStep1 addLayerAnimation:layerAnimation51 forView:disappearingView];
    animationStep1.duration = 0.4;
    [animationSteps addObject:animationStep1];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end
