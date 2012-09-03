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
#import "HLSLayerAnimationStep.h"
#import "NSObject+HLSExtensions.h"
#import "NSSet+HLSExtensions.h"
#import <objc/runtime.h>

// Constants
const NSTimeInterval kAnimationTransitionDefaultDuration = -1.;

static CGFloat kPushToTheBackScaleFactor = 0.95f;
static CGFloat kEmergeFromCenterScaleFactor = 0.8f;

@interface HLSTransition ()

+ (NSArray *)coverLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                yOffset:(CGFloat)yOffset
                                          appearingView:(UIView *)appearingView;

+ (NSArray *)coverPushToBackLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                          yOffset:(CGFloat)yOffset
                                                    appearingView:(UIView *)appearingView
                                                 disappearingView:(UIView *)disappearingView;

+ (NSArray *)pushLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                               yOffset:(CGFloat)yOffset
                                         appearingView:(UIView *)appearingView
                                      disappearingView:(UIView *)disappearingView;

+ (NSArray *)pushAndFadeLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                      yOffset:(CGFloat)yOffset
                                                appearingView:(UIView *)appearingView
                                             disappearingView:(UIView *)disappearingView;

+ (NSArray *)pushAndToBackLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                        yOffset:(CGFloat)yOffset
                                                  appearingView:(UIView *)appearingView
                                               disappearingView:(UIView *)disappearingView;

+ (NSArray *)flowLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                               yOffset:(CGFloat)yOffset
                                         appearingView:(UIView *)appearingView
                                      disappearingView:(UIView *)disappearingView;

+ (NSArray *)flipLayerAnimationStepsAroundVectorWithX:(CGFloat)x
                                                    y:(CGFloat)y
                                                    z:(CGFloat)z
                                        appearingView:(UIView *)appearingView
                                     disappearingView:(UIView *)disappearingView
                                               inView:(UIView *)view;

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

#pragma mark Generating the animation

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                      inView:(UIView *)view
                                    duration:(NSTimeInterval)duration
{
    NSAssert((! appearingView || appearingView.superview == view) && (! disappearingView || disappearingView.superview == view),
             @"Both the appearing and disappearing views must be children of the view in which the transition takes place");
    
    // Calculate the exact frame in which the animations will occur (taking into account the transform applied
    // to the parent view). Apply it temporarily to the view passed to the transition animation creation method
    // so that the receiver has the correct frame information
    CGRect originalFrame = view.frame;
    view.frame = CGRectApplyAffineTransform(view.frame, CGAffineTransformInvert(view.transform));
    
    // Build the animation with default parameters
    NSArray *animationSteps = [self layerAnimationStepsWithAppearingView:appearingView
                                                        disappearingView:disappearingView
                                                                  inView:view];
    view.frame = originalFrame;
    HLSAssertObjectsInEnumerationAreKindOfClass(animationSteps, [HLSLayerAnimationStep class]);
        
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:animationSteps];
    
    // Generate an animation with the proper duration
    if (doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        return animation;
    }
    else {
        return [animation animationWithDuration:duration];
    }
}

+ (HLSAnimation *)reverseAnimationWithAppearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView
                                             inView:(UIView *)view
                                           duration:(NSTimeInterval)duration
{
    NSAssert((! appearingView || appearingView.superview == view) && (! disappearingView || disappearingView.superview == view),
             @"Both the appearing and disappearing views must be children of the view in which the transition takes place");
    
    // Calculate the exact frame in which the animations will occur (taking into account the transform applied
    // to the parent view)
    CGRect originalFrame = view.frame;
    view.frame = CGRectApplyAffineTransform(view.frame, CGAffineTransformInvert(view.transform));
    
    // Build the animation with default parameters
    NSArray *animationSteps = [self reverseLayerAnimationStepsWithAppearingView:appearingView
                                                               disappearingView:disappearingView
                                                                         inView:view];
    view.frame = originalFrame;
    
    // If custom reverse animation implemented by the animation class, use it
    if (animationSteps) {
        HLSAssertObjectsInEnumerationAreKindOfClass(animationSteps, [HLSLayerAnimationStep class]);
                
        HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:animationSteps];
        
        // Generate an animation with the proper duration
        if (doubleeq(duration, kAnimationTransitionDefaultDuration)) {
            return animation;
        }
        else {
            return [animation animationWithDuration:duration];
        }
    }
    // If not implemented by the transition class, use the default reverse animation
    else {
        return [[self animationWithAppearingView:disappearingView
                                disappearingView:appearingView
                                          inView:view
                                        duration:duration] reverseAnimation];
    }
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
        HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[[self class] layerAnimationStepsWithAppearingView:nil
                                                                                                              disappearingView:nil
                                                                                                                        inView:nil]];
        duration = [NSNumber numberWithDouble:[animation duration]];
        [s_animationClassNameToDurationMap setObject:duration forKey:[self className]];
    }
    
    return [duration doubleValue];
}

#pragma mark Built-in transition common code

+ (NSArray *)coverLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                yOffset:(CGFloat)yOffset
                                          appearingView:(UIView *)appearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)coverPushToBackLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                          yOffset:(CGFloat)yOffset
                                                    appearingView:(UIView *)appearingView
                                                 disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)pushLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                               yOffset:(CGFloat)yOffset
                                         appearingView:(UIView *)appearingView
                                      disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 addToOpacity:-1.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)pushAndFadeLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                      yOffset:(CGFloat)yOffset
                                                appearingView:(UIView *)appearingView
                                             disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 addToOpacity:-1.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    HLSLayerAnimation *layerAnimation32 = [HLSLayerAnimation animation];
    [layerAnimation32 addToOpacity:1.f];
    [animationStep3 addLayerAnimation:layerAnimation32 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation animation];
    [layerAnimation41 addToOpacity:-1.f];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:disappearingView];
    animationStep4.duration = 0.;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)pushAndToBackLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                                        yOffset:(CGFloat)yOffset
                                                  appearingView:(UIView *)appearingView
                                               disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 translateByVectorWithX:-xOffset y:-yOffset];
    [layerAnimation21 scaleWithXFactor:0.5f yFactor:0.5f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 addToOpacity:-1.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)flowLayerAnimationStepsWithInitialXOffset:(CGFloat)xOffset
                                               yOffset:(CGFloat)yOffset
                                         appearingView:(UIView *)appearingView
                                      disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:xOffset y:yOffset];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 translateByVectorWithX:-xOffset y:-yOffset];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation animation];
    [layerAnimation41 scaleWithXFactor:1.f / kPushToTheBackScaleFactor yFactor:1.f / kPushToTheBackScaleFactor];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:disappearingView];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:appearingView];
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    // Make the disappearing view invisible
    HLSLayerAnimationStep *animationStep5 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation51 = [HLSLayerAnimation animation];
    [layerAnimation51 addToOpacity:-1.f];
    [animationStep5 addLayerAnimation:layerAnimation51 forView:disappearingView];
    animationStep5.duration = 0.;
    [animationSteps addObject:animationStep5];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)flipLayerAnimationStepsAroundVectorWithX:(CGFloat)x
                                                    y:(CGFloat)y
                                                    z:(CGFloat)z
                                        appearingView:(UIView *)appearingView
                                     disappearingView:(UIView *)disappearingView
                                               inView:(UIView *)view
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 rotateByAngle:M_PI aboutVectorWithX:x y:y z:z];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    HLSLayerAnimation *layerAnimation12 = [HLSLayerAnimation animation];
    [layerAnimation12 translateSublayerCameraByVectorWithZ:4 * CGRectGetWidth(view.frame)];
    [animationStep1 addLayerAnimation:layerAnimation12 forView:view];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [layerAnimation21 addToOpacity:-0.5f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.3;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 addToOpacity:0.5f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:appearingView];
    HLSLayerAnimation *layerAnimation32 = [HLSLayerAnimation animation];
    [layerAnimation32 addToOpacity:-0.5f];
    [animationStep3 addLayerAnimation:layerAnimation32 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation animation];
    [layerAnimation41 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:disappearingView];
    HLSLayerAnimation *layerAnimation42 = [HLSLayerAnimation animation];
    [layerAnimation42 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [layerAnimation42 addToOpacity:0.5f];
    [animationStep4 addLayerAnimation:layerAnimation42 forView:appearingView];
    animationStep4.duration = 0.3;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

#pragma mark Default transition implementation

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return nil;
}

+ (NSArray *)reverseLayerAnimationStepsWithAppearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView
                                                  inView:(UIView *)view
{
    return nil;
}

@end

@implementation HLSTransitionNone

// Same as HLSTransition, i.e. empty animation

@end

@implementation HLSTransitionCoverFromBottom

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:0.f
                                                             yOffset:CGRectGetHeight(view.frame)
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTop

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:0.f
                                                             yOffset:-CGRectGetHeight(view.frame)
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromLeft

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                             yOffset:0.f
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromRight

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                             yOffset:0.f
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTopLeft

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                             yOffset:-CGRectGetHeight(view.frame)
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTopRight

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                             yOffset:-CGRectGetHeight(view.frame)
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomLeft

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                             yOffset:CGRectGetHeight(view.frame)
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomRight

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                             yOffset:CGRectGetHeight(view.frame)
                                                       appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:0.f
                                                                       yOffset:CGRectGetHeight(view.frame)
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:0.f
                                                                       yOffset:-CGRectGetHeight(view.frame)
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromLeftPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                                       yOffset:0.f
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromRightPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                                       yOffset:0.f
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopLeftPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                                       yOffset:-CGRectGetHeight(view.frame)
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopRightPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                                       yOffset:-CGRectGetHeight(view.frame)
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromBottomLeftPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                                       yOffset:CGRectGetHeight(view.frame)
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromBottomRightPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition coverPushToBackLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                                       yOffset:CGRectGetHeight(view.frame)
                                                                 appearingView:appearingView
                                                              disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFadeIn

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 addToOpacity:1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionFadeInPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 addToOpacity:1.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionCrossDissolve

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 addToOpacity:-1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 addToOpacity:1.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionPushFromBottom

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushLayerAnimationStepsWithInitialXOffset:0.f
                                                            yOffset:CGRectGetHeight(view.frame)
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromTop

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushLayerAnimationStepsWithInitialXOffset:0.f
                                                            yOffset:-CGRectGetHeight(view.frame)
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromLeft

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                            yOffset:0.f
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromRight

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                            yOffset:0.f
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromBottomFadeIn

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndFadeLayerAnimationStepsWithInitialXOffset:0.f
                                                                   yOffset:CGRectGetHeight(view.frame)
                                                             appearingView:appearingView
                                                          disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromTopFadeIn

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndFadeLayerAnimationStepsWithInitialXOffset:0.f
                                                                   yOffset:-CGRectGetHeight(view.frame)
                                                             appearingView:appearingView
                                                          disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromLeftFadeIn

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndFadeLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                                   yOffset:0.f
                                                             appearingView:appearingView
                                                          disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromRightFadeIn

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndFadeLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                                   yOffset:0.f
                                                             appearingView:appearingView
                                                          disappearingView:disappearingView];
}

@end



@implementation HLSTransitionPushToBackFromBottom

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndToBackLayerAnimationStepsWithInitialXOffset:0.f
                                                                     yOffset:CGRectGetHeight(view.frame)
                                                               appearingView:appearingView
                                                            disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushToBackFromTop

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndToBackLayerAnimationStepsWithInitialXOffset:0.f
                                                                     yOffset:-CGRectGetHeight(view.frame)
                                                               appearingView:appearingView
                                                            disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushToBackFromLeft

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndToBackLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                                     yOffset:0.f
                                                               appearingView:appearingView
                                                            disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushToBackFromRight

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition pushAndToBackLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                                     yOffset:0.f
                                                               appearingView:appearingView
                                                            disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromBottom

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition flowLayerAnimationStepsWithInitialXOffset:0.f
                                                            yOffset:CGRectGetHeight(view.frame)
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromTop

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition flowLayerAnimationStepsWithInitialXOffset:0.f
                                                            yOffset:-CGRectGetHeight(view.frame)
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromLeft

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition flowLayerAnimationStepsWithInitialXOffset:-CGRectGetWidth(view.frame)
                                                            yOffset:0.f
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromRight

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition flowLayerAnimationStepsWithInitialXOffset:CGRectGetWidth(view.frame)
                                                            yOffset:0.f
                                                      appearingView:appearingView
                                                   disappearingView:disappearingView];
}

@end

@implementation HLSTransitionEmergeFromCenter

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 scaleWithXFactor:kEmergeFromCenterScaleFactor yFactor:kEmergeFromCenterScaleFactor];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 scaleWithXFactor:1.f / kEmergeFromCenterScaleFactor
                               yFactor:1.f / kEmergeFromCenterScaleFactor];
    [layerAnimation21 addToOpacity:1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionEmergeFromCenterPushToBack

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 scaleWithXFactor:kEmergeFromCenterScaleFactor yFactor:kEmergeFromCenterScaleFactor];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 scaleWithXFactor:1.f / kEmergeFromCenterScaleFactor
                               yFactor:1.f / kEmergeFromCenterScaleFactor];
    [layerAnimation21 addToOpacity:1.f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 scaleWithXFactor:kPushToTheBackScaleFactor
                               yFactor:kPushToTheBackScaleFactor];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:disappearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation HLSTransitionFlipVertical

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition flipLayerAnimationStepsAroundVectorWithX:0.f
                                                                 y:1.f
                                                                 z:0.f
                                                     appearingView:appearingView
                                                  disappearingView:disappearingView
                                                            inView:view];
}

@end

@implementation HLSTransitionFlipHorizontal

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
{
    return [HLSTransition flipLayerAnimationStepsAroundVectorWithX:1.f
                                                                 y:0.f
                                                                 z:0.f
                                                     appearingView:appearingView
                                                  disappearingView:disappearingView
                                                            inView:view];
}

@end
