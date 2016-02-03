//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CustomTransitions.h"

@interface CustomTransition : NSObject

+ (NSArray *)rotateLayerAnimationStepsAroundVectorWithX:(CGFloat)x
                                                      y:(CGFloat)y
                                                      z:(CGFloat)z
                                       counterclockwise:(BOOL)counterclockwise
                                     cameraZTranslation:(CGFloat)cameraZTranslation
                                          appearingView:(UIView *)appearingView
                                       disappearingView:(UIView *)disappearingView
                                                 inView:(UIView *)view;

@end

@implementation CustomTransition

+ (NSArray *)rotateLayerAnimationStepsAroundVectorWithX:(CGFloat)x
                                                      y:(CGFloat)y
                                                      z:(CGFloat)z
                                       counterclockwise:(BOOL)counterclockwise
                                     cameraZTranslation:(CGFloat)cameraZTranslation
                                          appearingView:(UIView *)appearingView
                                       disappearingView:(UIView *)disappearingView
                                                 inView:(UIView *)view
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup animation step
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 rotateByAngle:(counterclockwise ? -M_PI_2 : M_PI_2) aboutVectorWithX:x y:y z:z];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    HLSLayerAnimation *layerAnimation12 = [HLSLayerAnimation animation];
    [layerAnimation12 translateSublayerCameraByVectorWithZ:cameraZTranslation];
    [animationStep1 addLayerAnimation:layerAnimation12 forView:view];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 rotateByAngle:(counterclockwise ? M_PI_4 : -M_PI_4) aboutVectorWithX:x y:y z:z];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 translateSublayersByVectorWithX:0.f y:0.f z:-cameraZTranslation / 5.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:view];
    animationStep2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationStep2.duration = 0.3;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 rotateByAngle:(counterclockwise ? M_PI_4 : -M_PI_4) aboutVectorWithX:x y:y z:z];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:appearingView];
    HLSLayerAnimation *layerAnimation32 = [HLSLayerAnimation animation];
    [layerAnimation32 translateSublayersByVectorWithX:0.f y:0.f z:cameraZTranslation / 5.f];
    [animationStep3 addLayerAnimation:layerAnimation32 forView:view];
    animationStep3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationStep3.duration = 0.3;
    [animationSteps addObject:animationStep3];
    
    // Hide the view which disappears to avoid being able to barely see when the device is rotated between
    // portrait and landscape modes
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation animation];
    [layerAnimation41 addToOpacity:-1.f];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:disappearingView];
    animationStep4.duration = 0.;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation CustomTransitionFallFromTop

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
                                       withBounds:(CGRect)bounds
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup step bringing the appearingView outside the frame
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 translateByVectorWithX:0.f y:-CGRectGetHeight(bounds)];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    // The animation
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    [layerAnimation21 translateByVectorWithX:0.f y:CGRectGetHeight(bounds)];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:appearingView];
    animationStep2.duration = 0.1;
    [animationSteps addObject:animationStep2];
    
    HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
    [layerAnimation31 translateByVectorWithX:0.f y:-CGRectGetHeight(bounds) / 3.f];
    [animationStep3 addLayerAnimation:layerAnimation31 forView:appearingView];
    animationStep3.duration = 0.15;
    [animationSteps addObject:animationStep3];
    
    HLSLayerAnimationStep *animationStep4 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation41 = [HLSLayerAnimation animation];
    [layerAnimation41 translateByVectorWithX:0.f y:CGRectGetHeight(bounds) / 3.f];
    [animationStep4 addLayerAnimation:layerAnimation41 forView:appearingView];
    animationStep4.duration = 0.15;
    [animationSteps addObject:animationStep4];
    
    return [NSArray arrayWithArray:animationSteps];
}

+ (NSArray *)reverseLayerAnimationStepsWithAppearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView
                                                  inView:(UIView *)view
                                              withBounds:(CGRect)bounds
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    // Setup step bringing the disappearingView outside the frame
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation51 = [HLSLayerAnimation animation];
    [layerAnimation51 translateByVectorWithX:0.f y:-CGRectGetHeight(bounds)];
    [animationStep1 addLayerAnimation:layerAnimation51 forView:disappearingView];
    animationStep1.duration = 0.4;
    [animationSteps addObject:animationStep1];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end

@implementation CustomTransitionRotateVerticallyCounterclockwise

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
                                       withBounds:(CGRect)bounds
{
    // See http://markpospesel.wordpress.com/tag/catransform3d/
    return [CustomTransition rotateLayerAnimationStepsAroundVectorWithX:0.f
                                                                      y:1.f
                                                                      z:0.f
                                                       counterclockwise:YES
                                                     cameraZTranslation:4.f * CGRectGetWidth([[UIScreen mainScreen] applicationFrame])
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView
                                                                 inView:view];
}

@end

@implementation CustomTransitionRotateVerticallyClockwise

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
                                       withBounds:(CGRect)bounds
{
    // See http://markpospesel.wordpress.com/tag/catransform3d/
    return [CustomTransition rotateLayerAnimationStepsAroundVectorWithX:0.f
                                                                      y:1.f
                                                                      z:0.f
                                                       counterclockwise:NO
                                                     cameraZTranslation:4.f * CGRectGetWidth([[UIScreen mainScreen] applicationFrame])
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView
                                                                 inView:view];
}

@end

@implementation CustomTransitionRotateHorizontallyCounterclockwise

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
                                       withBounds:(CGRect)bounds
{
    // See http://markpospesel.wordpress.com/tag/catransform3d/
    return [CustomTransition rotateLayerAnimationStepsAroundVectorWithX:1.f
                                                                      y:0.f
                                                                      z:0.f
                                                       counterclockwise:YES
                                                     cameraZTranslation:4.f * CGRectGetHeight([[UIScreen mainScreen] applicationFrame])
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView
                                                                 inView:view];
}

@end

@implementation CustomTransitionRotateHorizontallyClockwise

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
                                       withBounds:(CGRect)bounds
{
    // See http://markpospesel.wordpress.com/tag/catransform3d/
    return [CustomTransition rotateLayerAnimationStepsAroundVectorWithX:1.f
                                                                      y:0.f
                                                                      z:0.f
                                                       counterclockwise:NO
                                                     cameraZTranslation:4.f * CGRectGetHeight([[UIScreen mainScreen] applicationFrame])
                                                          appearingView:appearingView
                                                       disappearingView:disappearingView
                                                                 inView:view];
}

@end

@implementation CustomTransitionFadeInBlur

+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                           inView:(UIView *)view
                                       withBounds:(CGRect)bounds
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:-1.f];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    // Tweak the rasterization scale of the disappearing view to create a pseudo-blur effect
    HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
    HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
    layerAnimation21.togglingShouldRasterize = YES;
    [layerAnimation21 addToRasterizationScale:-0.5f];
    [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
    HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
    [layerAnimation22 addToOpacity:1.f];
    [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [NSArray arrayWithArray:animationSteps];
}

@end
