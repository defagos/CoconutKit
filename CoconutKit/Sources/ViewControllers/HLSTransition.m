//
//  HLSTransition.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/8/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSTransition.h"

#import "HLSAnimation.h"
#import "HLSAssert.h"
#import "HLSFloat.h"
#import "NSObject+HLSExtensions.h"
#import "NSSet+HLSExtensions.h"
#import <objc/runtime.h>

// Constants
const NSTimeInterval kAnimationTransitionDefaultDuration = -1.;

static CGFloat kPushToTheBackScaleFactor = 0.95f;
static CGFloat kEmergeFromCenterScaleFactor = 0.8f;

@interface HLSTransition ()

+ (NSArray *)coverAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                                     appearingView:(UIView *)appearingView;

+ (NSArray *)coverPushToBackAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                     yOffset:(CGFloat)yOffset
                                               appearingView:(UIView *)appearingView
                                            disappearingView:(UIView *)disappearingView;

+ (NSArray *)pushAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView;

+ (NSArray *)pushAndFadeAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                                           appearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView;

+ (NSArray *)pushAndToBackAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                   yOffset:(CGFloat)yOffset
                                             appearingView:(UIView *)appearingView
                                          disappearingView:(UIView *)disappearingView;

+ (NSArray *)flowAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView;

+ (NSArray *)flipAnimationStepsAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                                   appearingView:(UIView *)appearingView
                                disappearingView:(UIView *)disappearingView;

@end

@implementation HLSTransition

#pragma mark Getting transition animation information

+ (NSArray *)availableTransitionNames
{
    static NSArray *s_availableTransitionNames = nil;
    if (! s_availableTransitionNames) {
        NSMutableArray *availableTransitionNames = [NSMutableArray array];
        
        // Find all HLSTransition subclasses (except HLSTransition itself)
        unsigned int numberOfClasses = 0;
        Class *classes = objc_copyClassList(&numberOfClasses);
        for (int i = 0; i < numberOfClasses; ++i) {
            Class class = classes[i];
            
            // Discard HLSTransition
            if (class == [HLSTransition class]) {
                continue;
            }
            
            // Find whether HLSTransition is a superclass. We cannot use -isSubclassOfClass: since it is an NSObject
            // method and we might encounter other kinds of classes (e.g. proxies)
            // TODO: Factor out in HLSRuntime.h after merge with url-networking branch
            Class superclass = class;
            do {
                superclass = class_getSuperclass(superclass);
            } while (superclass && superclass != [HLSTransition class]);
            
            if (! superclass) {
                continue;
            }
            
            [availableTransitionNames addObject:NSStringFromClass(class)];
        }
        free(classes);
        
        s_availableTransitionNames = [[availableTransitionNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] retain];
    }
    return s_availableTransitionNames;
}

+ (NSTimeInterval)defaultDuration
{
    // Durations are constants for each transition animation class. Can cache them
    static NSMutableDictionary *s_animationClassNameToDurationMap = nil;
    if (! s_animationClassNameToDurationMap) {
        s_animationClassNameToDurationMap = [[NSMutableDictionary dictionary] retain];
    }
    
    NSNumber *duration = [s_animationClassNameToDurationMap objectForKey:[self className]];
    if (! duration) {
        // Calculate for a dummy animation
        HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[[self class] animationStepsWithAppearingView:nil disappearingView:nil inFrame:CGRectZero]];
        duration = [NSNumber numberWithDouble:[animation duration]];
        [s_animationClassNameToDurationMap setObject:duration forKey:[self className]];
    }
    
    return [duration doubleValue];
}

#pragma mark Built-in transition common code

+ (NSArray *)coverAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                                     appearingView:(UIView *)appearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)coverPushToBackAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                     yOffset:(CGFloat)yOffset
                                               appearingView:(UIView *)appearingView
                                            disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation layerAnimation];
    [layerAnimation22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)pushAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation layerAnimation];
    [layerAnimation22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation layerAnimation];
    layerAnimation31.opacityVariation = -1.f;
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)pushAndFadeAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                                           appearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    layerAnimation11.opacityVariation = -1.f;
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation layerAnimation];
    layerAnimation31.opacityVariation = -1.f;
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    HLSLayerAnimation *layerAnimation32 = [HLSLayerAnimation layerAnimation];
    layerAnimation32.opacityVariation = 1.f;
    [animationStep3 addLayerAnimation:layerAnimation32 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation layerAnimation];
    layerAnimation41.opacityVariation = -1.f;
    [animationStep4 addLayerAnimation:layerAnimation41 forView:disappearingView];
    animationStep4.duration = 0.;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)pushAndToBackAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                   yOffset:(CGFloat)yOffset
                                             appearingView:(UIView *)appearingView
                                          disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [layerAnimation21 scaleWithXFactor:0.5f yFactor:0.5f zFactor:1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation layerAnimation];
    [layerAnimation22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation layerAnimation];
    layerAnimation31.opacityVariation = -1.f;
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)flowAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation layerAnimation];
    [layerAnimation31 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation layerAnimation];
    [layerAnimation41 scaleWithXFactor:1.f / kPushToTheBackScaleFactor yFactor:1.f / kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:disappearingView];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:appearingView];
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep5 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation51 = [HLSLayerAnimation layerAnimation];
    layerAnimation51.opacityVariation = -1.f;
    [animationStep5 addLayerAnimation:layerAnimation51 forView:disappearingView];
    animationStep5.duration = 0.;
    [animationSteps addObject:animationStep5];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)flipAnimationStepsAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                                   appearingView:(UIView *)appearingView
                                disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *viewAnimationStep11 = [HLSLayerAnimation layerAnimation];
    [viewAnimationStep11 rotateByAngle:M_PI aboutVectorWithX:x y:y z:z];
    viewAnimationStep11.opacityVariation = -1.f;
    [animationStep1 addLayerAnimation:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *viewAnimationStep21 = [HLSLayerAnimation layerAnimation];
    [viewAnimationStep21 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    viewAnimationStep21.opacityVariation = -0.5f;
    [animationStep2 addLayerAnimation:viewAnimationStep21 forView:disappearingView];
    HLSLayerAnimation *viewAnimationStep22 = [HLSLayerAnimation layerAnimation];
    [viewAnimationStep22 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep2 addLayerAnimation:viewAnimationStep22 forView:appearingView];
    animationStep2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *viewAnimationStep31 = [HLSLayerAnimation layerAnimation];
    viewAnimationStep31.opacityVariation = 0.5f;
    [animationStep3 addLayerAnimation:viewAnimationStep31 forView:appearingView];
    HLSLayerAnimation *viewAnimationStep32 = [HLSLayerAnimation layerAnimation];
    viewAnimationStep32.opacityVariation = -0.5f;
    [animationStep3 addLayerAnimation:viewAnimationStep32 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *viewAnimationStep41 = [HLSLayerAnimation layerAnimation];
    [viewAnimationStep41 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep4 addLayerAnimation:viewAnimationStep41 forView:disappearingView];
    HLSLayerAnimation *viewAnimationStep42 = [HLSLayerAnimation layerAnimation];
    [viewAnimationStep42 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    viewAnimationStep42.opacityVariation = 0.5f;
    [animationStep4 addLayerAnimation:viewAnimationStep42 forView:appearingView];
    animationStep4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

#pragma mark Default transition implementation

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return nil;
}

+ (NSArray *)reverseAnimationStepsWithAppearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView
                                            inFrame:(CGRect)frame
{
    return nil;
}

@end

@implementation HLSTransitionNone

// Same as HLSTransition, i.e. empty animation

@end

@implementation HLSTransitionCoverFromBottom

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:0.f
                                                        yOffset:CGRectGetHeight(frame)
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTop

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:0.f
                                                        yOffset:-CGRectGetHeight(frame)
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromLeft

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:0.f
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromRight

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:0.f
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTopLeft

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTopRight

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomLeft

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomRight

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                                  appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:0.f
                                                                  yOffset:CGRectGetHeight(frame)
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:0.f
                                                                  yOffset:-CGRectGetHeight(frame)
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromLeftPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                                  yOffset:0.f
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromRightPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                                  yOffset:0.f
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopLeftPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                                  yOffset:-CGRectGetHeight(frame)
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopRightPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                                  yOffset:-CGRectGetHeight(frame)
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromBottomLeftPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                                  yOffset:CGRectGetHeight(frame)
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromBottomRightPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverPushToBackAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                                  yOffset:CGRectGetHeight(frame)
                                                            appearingView:appearingView
                                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFadeIn

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    layerAnimation11.opacityVariation = -1.f;
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    layerAnimation21.opacityVariation = 1.f;
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionFadeInPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    layerAnimation11.opacityVariation = -1.f;
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation layerAnimation];
    layerAnimation22.opacityVariation = 1.f;
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionCrossDissolve

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    layerAnimation11.opacityVariation = -1.f;
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    layerAnimation21.opacityVariation = -1.f;
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation layerAnimation];
    layerAnimation22.opacityVariation = 1.f;
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionPushFromBottom

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationStepsWithInitialXOffset:0.f
                                                       yOffset:CGRectGetHeight(frame)
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromTop

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationStepsWithInitialXOffset:0.f
                                                       yOffset:-CGRectGetHeight(frame)
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromLeft

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:0.f
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromRight

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:0.f
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromBottomFadeIn

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationStepsWithInitialXOffset:0.f
                                                              yOffset:CGRectGetHeight(frame)
                                                        appearingView:appearingView
                                                     disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromTopFadeIn

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationStepsWithInitialXOffset:0.f
                                                              yOffset:-CGRectGetHeight(frame)
                                                        appearingView:appearingView
                                                     disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromLeftFadeIn

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                              yOffset:0.f
                                                        appearingView:appearingView
                                                     disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromRightFadeIn

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                              yOffset:0.f
                                                        appearingView:appearingView
                                                     disappearingView:disappearingView];
}

@end



@implementation HLSTransitionPushToBackFromBottom

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndToBackAnimationStepsWithInitialXOffset:0.f
                                                                yOffset:CGRectGetHeight(frame)
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushToBackFromTop

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndToBackAnimationStepsWithInitialXOffset:0.f
                                                                yOffset:-CGRectGetHeight(frame)
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushToBackFromLeft

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndToBackAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                                yOffset:0.f
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushToBackFromRight

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndToBackAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                                yOffset:0.f
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromBottom

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationStepsWithInitialXOffset:0.f
                                                       yOffset:CGRectGetHeight(frame)
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromTop

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationStepsWithInitialXOffset:0.f
                                                       yOffset:-CGRectGetHeight(frame)
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromLeft

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationStepsWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:0.f
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromRight

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationStepsWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:0.f
                                                 appearingView:appearingView
                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionEmergeFromCenter

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 scaleWithXFactor:kEmergeFromCenterScaleFactor yFactor:kEmergeFromCenterScaleFactor zFactor:1.f];
    layerAnimation11.opacityVariation = -1.f;
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 scaleWithXFactor:1.f / kEmergeFromCenterScaleFactor
                               yFactor:1.f / kEmergeFromCenterScaleFactor
                               zFactor:1.f];
    layerAnimation21.opacityVariation = 1.f;
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionEmergeFromCenterPushToBack

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation layerAnimation];
    [layerAnimation11 scaleWithXFactor:kEmergeFromCenterScaleFactor yFactor:kEmergeFromCenterScaleFactor zFactor:1.f];
    layerAnimation11.opacityVariation = -1.f;
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation layerAnimation];
    [layerAnimation21 scaleWithXFactor:1.f / kEmergeFromCenterScaleFactor
                               yFactor:1.f / kEmergeFromCenterScaleFactor
                               zFactor:1.f];
    layerAnimation21.opacityVariation = 1.f;
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation layerAnimation];
    [layerAnimation22 scaleWithXFactor:kPushToTheBackScaleFactor
                               yFactor:kPushToTheBackScaleFactor
                               zFactor:1.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:disappearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionFlipVertical

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flipAnimationStepsAroundVectorWithX:0.f
                                                            y:1.f
                                                            z:0.f
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlipHorizontal

+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flipAnimationStepsAroundVectorWithX:1.f
                                                            y:0.f
                                                            z:0.f
                                                appearingView:appearingView
                                             disappearingView:disappearingView];
}

@end
