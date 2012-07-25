//
//  HLSContainerAnimations.m
//  CoconutKit
//
//  Created by Samuel Défago on 13.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerAnimations.h"

#import "HLSAssert.h"
#import "HLSFloat.h"
#import "HLSLogger.h"

// Constants
static CGFloat kPushToTheBackScaleFactor = 0.95f;
static CGFloat kEmergeFromCenterScaleFactor = 0.01f;      // cannot use 0.f, otherwise infinite matrix elements

@interface HLSContainerAnimations ()

+ (CGRect)fixedFrameForView:(UIView *)view;

+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                         appearingContainerContent:(HLSContainerContent *)appearingContainerContent;

+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                          appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                      disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)fadeInAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                 disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)fadeInAnimation2WithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                  disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)crossDissolveAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                        disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                        appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                    disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)pushAndFadeAnimationWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                               appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                           disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)flowAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                        appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                    disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)emergeFromCenterAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent;

+ (HLSAnimation *)flipAnimationAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                       appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                   disappearingContainerContents:(NSArray *)disappearingContainerContents;

@end

@implementation HLSContainerAnimations

#pragma mark Class methods

/**
 * When a view controller is added as root view controller, there is a subtlety: When the device is rotated into landscape mode, the
 * root view is applied a rotation matrix transform. When a view controller container is set as root, there is an issue if the contentView
 * happens to be the root view: We cannot just use contentView.frame to calculate animations in landscape mode, otherwise animations
 * will be incorrect (they will correspond to the animations in portrait mode!). This method just fixes this issue, providing the
 * correct frame in all situations
 */
+ (CGRect)fixedFrameForView:(UIView *)view
{
    CGRect frame = CGRectZero;
    // Root view
    if ([view.superview isKindOfClass:[UIWindow class]]) {
        frame = CGRectApplyAffineTransform(view.frame, CGAffineTransformInvert(view.transform));
    }
    // All other cases
    else {
        frame = view.frame;
    }
    return frame;
}

// The new view covers the views below (which is not moved)
+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                         appearingContainerContent:(HLSContainerContent *)appearingContainerContent
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view covers the views below, which get slightly shrinked (Fliboard-style)
+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                          appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                      disappearingContainerContents:(NSArray *)disappearingContainerContents

{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent viewIfLoaded]];
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in. The views below are left as is
+ (HLSAnimation *)fadeInAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                 disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = appearingContainerContent.originalViewAlpha;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in. The views below are pushed to the back
+ (HLSAnimation *)fadeInAnimation2WithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                  disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent viewIfLoaded]];
    }
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = appearingContainerContent.originalViewAlpha;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in while the views below fade out
+ (HLSAnimation *)crossDissolveAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                        disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep21.alphaVariation = -disappearingContainerContent.originalViewAlpha;
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent viewIfLoaded]];                 
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.alphaVariation = appearingContainerContent.originalViewAlpha;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view pushes the other one
+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                        appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                    disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view pushes the other one, which fades in
+ (HLSAnimation *)pushAndFadeAnimationWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                               appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                           disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep31.alphaVariation = -disappearingContainerContent.originalViewAlpha;
        [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep32.alphaVariation = appearingContainerContent.originalViewAlpha;
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:[appearingContainerContent viewIfLoaded]];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The old view is pushed to the back, then pushed by the new one (at the same scale), which is then pushed to the front
+ (HLSAnimation *)flowAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                        appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                    disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [viewAnimationStep11 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep31 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
        [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep32 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep41 scaleWithXFactor:1.f / kPushToTheBackScaleFactor yFactor:1.f / kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:[appearingContainerContent viewIfLoaded]];
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view emerges from the center of the screen
+ (HLSAnimation *)emergeFromCenterAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 scaleWithXFactor:kEmergeFromCenterScaleFactor yFactor:kEmergeFromCenterScaleFactor zFactor:1.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:1.f / kEmergeFromCenterScaleFactor 
                                  yFactor:1.f / kEmergeFromCenterScaleFactor 
                                  zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The appearing and disappearing views are flipped around an axis
+ (HLSAnimation *)flipAnimationAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                       appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                   disappearingContainerContents:(NSArray *)disappearingContainerContents

{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 rotateByAngle:M_PI aboutVectorWithX:x y:y z:z];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
        viewAnimationStep21.alphaVariation = -disappearingContainerContent.originalViewAlpha * 0.5f;
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep2.curve = UIViewAnimationCurveEaseOut;
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.alphaVariation = appearingContainerContent.originalViewAlpha * 0.5f;
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:[appearingContainerContent viewIfLoaded]]; 
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep32.alphaVariation = -disappearingContainerContent.originalViewAlpha * 0.5f;
        [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep41 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
        [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:[disappearingContainerContent viewIfLoaded]]; 
    }
    HLSViewAnimationStep *viewAnimationStep42 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep42 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    viewAnimationStep42.alphaVariation = appearingContainerContent.originalViewAlpha * 0.5f;
    [animationStep4 addViewAnimationStep:viewAnimationStep42 forView:[appearingContainerContent viewIfLoaded]]; 
    animationStep4.curve = UIViewAnimationCurveEaseIn;
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView
                                      duration:(NSTimeInterval)duration
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(disappearingContainerContents, HLSContainerContent);
    
    CGRect frame = [HLSContainerAnimations fixedFrameForView:containerView];
    
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
                                     appearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            animation = [self coverAnimationWithInitialXOffset:0.f
                                                       yOffset:-CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:0.f
                                     appearingContainerContent:appearingContainerContent];
            break;
        } 
            
        case HLSTransitionStyleCoverFromRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:0.f
                                     appearingContainerContent:appearingContainerContent];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:-CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:-CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }   
            
        case HLSTransitionStyleCoverFromBottomRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        } 
            
        case HLSTransitionStyleCoverFromBottom2: {
            animation = [self coverAnimation2WithInitialXOffset:0.f
                                                        yOffset:CGRectGetHeight(frame) 
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop2: {
            animation = [self coverAnimation2WithInitialXOffset:0.f
                                                        yOffset:-CGRectGetHeight(frame) 
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:0.f 
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:0.f
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromTopLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromTopRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleFadeIn: {
            animation = [self fadeInAnimationWithAppearingContainerContent:appearingContainerContent
                                             disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleFadeIn2: {
            animation = [self fadeInAnimation2WithAppearingContainerContent:appearingContainerContent
                                              disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            animation = [self crossDissolveAnimationWithAppearingContainerContent:appearingContainerContent 
                                                    disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            animation = [self pushAnimationWithInitialXOffset:0.f
                                                      yOffset:CGRectGetHeight(frame)
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStylePushFromTop: {
            animation = [self pushAnimationWithInitialXOffset:0.f
                                                      yOffset:-CGRectGetHeight(frame)
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        }    
            
        case HLSTransitionStylePushFromLeft: {
            animation = [self pushAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                      yOffset:0.f
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStylePushFromRight: {
            animation = [self pushAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                      yOffset:0.f
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStylePushFromBottomFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:0.f
                                                             yOffset:CGRectGetHeight(frame)
                                           appearingContainerContent:appearingContainerContent 
                                       disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStylePushFromTopFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:0.f
                                                             yOffset:-CGRectGetHeight(frame)
                                           appearingContainerContent:appearingContainerContent 
                                       disappearingContainerContents:disappearingContainerContents];
            break;
        }    
            
        case HLSTransitionStylePushFromLeftFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                             yOffset:0.f
                                           appearingContainerContent:appearingContainerContent 
                                       disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStylePushFromRightFadeIn: {
            animation = [self pushAndFadeAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                             yOffset:0.f
                                           appearingContainerContent:appearingContainerContent 
                                       disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStyleFlowFromBottom: {
            animation = [self flowAnimationWithInitialXOffset:0.f
                                                      yOffset:CGRectGetHeight(frame)
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStyleFlowFromTop: {
            animation = [self flowAnimationWithInitialXOffset:0.f
                                                      yOffset:-CGRectGetHeight(frame)
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        }    
            
        case HLSTransitionStyleFlowFromLeft: {
            animation = [self flowAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                      yOffset:0.f
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStyleFlowFromRight: {
            animation = [self flowAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                      yOffset:0.f
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStyleEmergeFromCenter: {
            animation = [self emergeFromCenterAnimationWithAppearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleFlipVertical: {
            animation = [self flipAnimationAroundVectorWithX:0.f 
                                                           y:1.f 
                                                           z:0.f 
                                   appearingContainerContent:appearingContainerContent 
                               disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleFlipHorizontal: {
            animation = [self flipAnimationAroundVectorWithX:1.f 
                                                           y:0.f 
                                                           z:0.f 
                                   appearingContainerContent:appearingContainerContent 
                               disappearingContainerContents:disappearingContainerContents];
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
    CGRect fixedFrame = [HLSContainerAnimations fixedFrameForView:containerView];
    
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
}

#pragma mark Object creation and destruction

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

@end
