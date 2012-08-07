//
//  HLSContainerAnimation.m
//  CoconutKit
//
//  Created by Samuel Défago on 13.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerAnimation.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

// Constants
static CGFloat kPushToTheBackScaleFactor = 0.95f;
static CGFloat kEmergeFromCenterScaleFactor = 0.01f;      // cannot use 0.f, otherwise infinite matrix elements

@interface HLSContainerAnimation ()

+ (CGRect)actualFrameForView:(UIView *)view;

+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                                     appearingView:(UIView *)appearingView;

+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                                      appearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)fadeInAnimationWithAppearingView:(UIView *)appearingView
                                  disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)fadeInAnimation2WithAppearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)crossDissolveAnimationWithAppearingView:(UIView *)appearingView
                                         disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)pushAndFadeAnimationWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                                           appearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)flowAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)emergeFromCenterAnimationWithAppearingView:(UIView *)appearingView;

+ (HLSAnimation *)flipAnimationAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                                   appearingView:(UIView *)appearingView
                                disappearingView:(UIView *)disappearingView;

@end

@implementation HLSContainerAnimation

#pragma mark Class methods

+ (CGRect)actualFrameForView:(UIView *)view
{
    return CGRectApplyAffineTransform(view.frame, CGAffineTransformInvert(view.transform));
}

// The new view covers the views below (which is not moved)
+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                                     appearingView:(UIView *)appearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view covers the views below, which get slightly shrinked (Fliboard-style)
+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                                      appearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in. The views below are left as is
+ (HLSAnimation *)fadeInAnimationWithAppearingView:(UIView *)appearingView
                                  disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in. The views below are pushed to the back
+ (HLSAnimation *)fadeInAnimation2WithAppearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in while the views below fade out
+ (HLSAnimation *)crossDissolveAnimationWithAppearingView:(UIView *)appearingView
                                         disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = -1.f;
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view pushes the other one
+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view pushes the other one, which fades in
+ (HLSAnimation *)pushAndFadeAnimationWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                                           appearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.alphaVariation = -1.f;
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep32.alphaVariation = 1.f;
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The old view is pushed to the back, then pushed by the new one (at the same scale), which is then pushed to the front
+ (HLSAnimation *)flowAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep31 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:disappearingView];
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep41 scaleWithXFactor:1.f / kPushToTheBackScaleFactor yFactor:1.f / kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:disappearingView];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:appearingView];
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    // Make the disappearing view disappear. Otherwise the view which disappeared might be visible if we apply the same
    // effect to push another view controller
    HLSAnimationStep *animationStep5 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep51 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep51.alphaVariation = -1.f;
    [animationStep5 addViewAnimationStep:viewAnimationStep51 forView:disappearingView];
    animationStep5.duration = 0.;
    [animationSteps addObject:animationStep5];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view emerges from the center of the screen
+ (HLSAnimation *)emergeFromCenterAnimationWithAppearingView:(UIView *)appearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 scaleWithXFactor:kEmergeFromCenterScaleFactor yFactor:kEmergeFromCenterScaleFactor zFactor:1.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:1.f / kEmergeFromCenterScaleFactor 
                                  yFactor:1.f / kEmergeFromCenterScaleFactor 
                                  zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The appearing and disappearing views are flipped around an axis
+ (HLSAnimation *)flipAnimationAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                                   appearingView:(UIView *)appearingView
                                disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 rotateByAngle:M_PI aboutVectorWithX:x y:y z:z];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    viewAnimationStep21.alphaVariation = -0.5f;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.curve = UIViewAnimationCurveEaseOut;
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.alphaVariation = 0.5f;
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:appearingView];
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep32.alphaVariation = -0.5f;
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep41 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep42 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep42 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    viewAnimationStep42.alphaVariation = 0.5f;
    [animationStep4 addViewAnimationStep:viewAnimationStep42 forView:appearingView];
    animationStep4.curve = UIViewAnimationCurveEaseIn;
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                                        inView:(UIView *)view
                                      duration:(NSTimeInterval)duration
                                     belowOnly:(BOOL)belowOnly
{
    CGRect frame = [HLSContainerAnimation actualFrameForView:view];
    if ([view.subviews count] == 0) {
        HLSLoggerError(@"At least 1 view is required");
        return nil;
    }
    
    UIView *appearingView = nil;
    UIView *disappearingView = nil;
    if ([view.subviews count] == 1) {
        appearingView = [view.subviews objectAtIndex:0];
    }
    else if ([view.subviews count] == 2) {
        appearingView = [view.subviews objectAtIndex:1];
        disappearingView = [view.subviews objectAtIndex:0];
    }
    
    // TODO: Ugly: Fix when refactoring this class
    if (belowOnly) {
        appearingView = nil;
    }
    
    HLSAnimation *animation = nil;
    switch (transitionStyle) {
        case HLSTransitionStyleNone: {
            // Empty animation (not simply nil) so that the animation is played (and the associated
            // callback are called)
            animation = [HLSAnimation animationWithAnimationStep:nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            animation = [self coverAnimationWithInitialXOffset:0.f
                                                       yOffset:CGRectGetHeight(frame) 
                                                 appearingView:appearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            animation = [self coverAnimationWithInitialXOffset:0.f
                                                       yOffset:-CGRectGetHeight(frame) 
                                                 appearingView:appearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:0.f
                                                 appearingView:appearingView];
            break;
        } 
            
        case HLSTransitionStyleCoverFromRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:0.f
                                     appearingView:appearingView];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:-CGRectGetHeight(frame) 
                                                 appearingView:appearingView];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:-CGRectGetHeight(frame) 
                                                 appearingView:appearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:CGRectGetHeight(frame) 
                                                 appearingView:appearingView];
            break;
        }   
            
        case HLSTransitionStyleCoverFromBottomRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:CGRectGetHeight(frame) 
                                                 appearingView:appearingView];
            break;
        } 
            
        case HLSTransitionStyleCoverFromBottom2: {
            animation = [self coverAnimation2WithInitialXOffset:0.f
                                                        yOffset:CGRectGetHeight(frame) 
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop2: {
            animation = [self coverAnimation2WithInitialXOffset:0.f
                                                        yOffset:-CGRectGetHeight(frame) 
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:0.f 
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:0.f
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromTopLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromTopRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                                  appearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleFadeIn: {
            animation = [self fadeInAnimationWithAppearingView:appearingView
                                              disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleFadeIn2: {
            animation = [self fadeInAnimation2WithAppearingView:appearingView
                                               disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            animation = [self crossDissolveAnimationWithAppearingView:appearingView
                                                     disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            animation = [self pushAnimationWithInitialXOffset:0.f
                                                      yOffset:CGRectGetHeight(frame)
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStylePushFromTop: {
            animation = [self pushAnimationWithInitialXOffset:0.f
                                                      yOffset:-CGRectGetHeight(frame)
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        }    
            
        case HLSTransitionStylePushFromLeft: {
            animation = [self pushAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                      yOffset:0.f
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStylePushFromRight: {
            animation = [self pushAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                      yOffset:0.f
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStylePushFromBottomFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:0.f
                                                             yOffset:CGRectGetHeight(frame)
                                                       appearingView:appearingView
                                                    disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStylePushFromTopFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:0.f
                                                             yOffset:-CGRectGetHeight(frame)
                                                       appearingView:appearingView
                                                    disappearingView:disappearingView];
            break;
        }    
            
        case HLSTransitionStylePushFromLeftFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                             yOffset:0.f
                                                       appearingView:appearingView
                                                    disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStylePushFromRightFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                             yOffset:0.f
                                                       appearingView:appearingView
                                                    disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStyleFlowFromBottom: {
            animation = [self flowAnimationWithInitialXOffset:0.f
                                                      yOffset:CGRectGetHeight(frame)
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStyleFlowFromTop: {
            animation = [self flowAnimationWithInitialXOffset:0.f
                                                      yOffset:-CGRectGetHeight(frame)
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        }    
            
        case HLSTransitionStyleFlowFromLeft: {
            animation = [self flowAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                      yOffset:0.f
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStyleFlowFromRight: {
            animation = [self flowAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                      yOffset:0.f
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
            break;
        } 
            
        case HLSTransitionStyleEmergeFromCenter: {
            animation = [self emergeFromCenterAnimationWithAppearingView:appearingView];
            break;
        }
            
        case HLSTransitionStyleFlipVertical: {
            animation = [self flipAnimationAroundVectorWithX:0.f 
                                                           y:1.f 
                                                           z:0.f 
                                               appearingView:appearingView
                                            disappearingView:disappearingView];
            break;
        }
            
        case HLSTransitionStyleFlipHorizontal: {
            animation = [self flipAnimationAroundVectorWithX:1.f 
                                                           y:0.f 
                                                           z:0.f 
                                               appearingView:appearingView
                                            disappearingView:disappearingView];
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown transition style");
            return nil;
            break;
        }
    }
    
    if (doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        return animation;
    }
    else {
        return [animation animationWithDuration:duration];
    }
}

+ (HLSAnimation *)rotationAnimationWithContainerContents:(NSArray *)containerContents
                                           containerView:(UIView *)containerView
                                                duration:(NSTimeInterval)duration
{
#if 0
    CGRect fixedFrame = [HLSContainerAnimation actualFrameForView:containerView];
    
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    animationStep.duration = duration;
    
    // Apply a fix for each contained view controller (except the bottommost one which has no other view controller
    // below)
    for (NSUInteger index = 1; index < [containerContents count]; ++index) {
        HLSContainerContent *containerContent = [containerContents objectAtIndex:index];
        
        // Fix all view controller's views below
        NSArray *belowContainerContents = [containerContents subarrayWithRange:NSMakeRange(0, index)];
        for (HLSContainerContent *belowContainerContent in belowContainerContents) {
            UIView *belowView = [belowContainerContent viewIfLoaded];
            
            // This creates the animations needed to fix the view controller's view positions during rotation. To 
            // understand the applied animation transforms, use transparent view controllers loaded into the stack. Push 
            // one view controller into the stack using one of the transitions, then rotate the device, and pop it. For 
            // each transition style, do it once with push in portrait mode and pop in landscape mode, and once with push 
            // in landscape mode and pop in portrait mode. Try to remove the transforms to understand what happens if no 
            // correction is applied during rotation
            HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
            switch (containerContent.transitionStyle) {
                case HLSTransitionStyleCoverFromBottom2:
                case HLSTransitionStyleCoverFromTop2:
                case HLSTransitionStyleCoverFromLeft2:
                case HLSTransitionStyleCoverFromRight2:
                case HLSTransitionStyleCoverFromTopLeft2:
                case HLSTransitionStyleCoverFromTopRight2:
                case HLSTransitionStyleCoverFromBottomLeft2:
                case HLSTransitionStyleCoverFromBottomRight2:
                case HLSTransitionStyleFadeIn2: {
                    [viewAnimationStep scaleWithXFactor:kPushToTheBackScaleFactor * CGRectGetWidth(fixedFrame) / CGRectGetWidth(belowView.frame) 
                                                yFactor:kPushToTheBackScaleFactor * CGRectGetHeight(fixedFrame) / CGRectGetHeight(belowView.frame)
                                                zFactor:1.f];
                    break;
                }
                    
                default: {
                    // Nothing to do
                    break;
                }
            }
            [animationStep addViewAnimationStep:viewAnimationStep forView:[belowContainerContent viewIfLoaded]];
        }        
    }
    
    return [HLSAnimation animationWithAnimationStep:animationStep];
#endif
    return nil;
}

#pragma mark Object creation and destruction

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

@end
