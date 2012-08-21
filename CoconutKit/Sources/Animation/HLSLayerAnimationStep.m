//
//  HLSLayerAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLayerAnimationStep.h"

#import "HLSAnimationStep+Protected.h"
#import "HLSFloat.h"
#import "HLSLogger.h"

// Remark: CoreAnimation default settings are duration = 0.25 and linear timing function, but
//         to be consistent with UIView block-based animations we do not override the default
//         duration received from HLSAnimationStep (0.2) and set an ease-in ease-out function

@implementation HLSLayerAnimationStep

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }
    return self;
}

#pragma mark Accessors and mutators

- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forLayer:(CALayer *)layer
{
    [self addObjectAnimation:layerAnimation forObject:layer];
}

- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forView:(UIView *)view
{
    [self addLayerAnimation:layerAnimation forLayer:view.layer];
}

@synthesize timingFunction = m_timingFunction;

#pragma mark Managing the animation

- (void)playAnimated:(BOOL)animated
{
    // Animate all views involved in the animation step
    for (CALayer *layer in [self objects]) {        
        HLSLayerAnimation *layerAnimation = (HLSLayerAnimation *)[self objectAnimationForObject:layer];
        NSAssert(layerAnimation != nil, @"Missing layer animation; data consistency failure");
        
        // Remark: For each property we animate, we still must set the final value manually (CoreAnimations
        //         animate properties but do not set them)
        NSMutableArray *animations = [NSMutableArray array];
        
        // Opacity animation (opacity must always lie between 0.f and 1.f)
        CGFloat opacity = layer.opacity + layerAnimation.opacityVariation;
        if (floatlt(opacity, -1.f)) {
            HLSLoggerWarn(@"Layer animations adding to an opacity value larger than -1 for view %@. Fixed to -1, but your animation is incorrect", layer);
            opacity = -1.f;
        }
        else if (floatgt(opacity, 1.f)) {
            HLSLoggerWarn(@"Layer animations adding to an opacity value larger than 1 for view %@. Fixed to 1, but your animation is incorrect", layer);
            opacity = 1.f;
        }
        
        if (animated) {
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [opacityAnimation setFromValue:[NSNumber numberWithFloat:layer.opacity]];
            [opacityAnimation setToValue:[NSNumber numberWithFloat:opacity]];
            [animations addObject:opacityAnimation];
        }
        layer.opacity = opacity;
        
        // Transform animation
        CATransform3D translationTransform = CATransform3DMakeTranslation(-layer.transform.m41, -layer.transform.m42, 0.f);
        CATransform3D convTransform = CATransform3DConcat(CATransform3DConcat(translationTransform, layerAnimation.transform),
                                                          CATransform3DInvert(translationTransform));
        CATransform3D transform = CATransform3DConcat(layer.transform, convTransform);
        
        if (animated) {
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            [transformAnimation setFromValue:[NSValue valueWithCATransform3D:layer.transform]];
            [transformAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
            [animations addObject:transformAnimation];
        }
        layer.transform = transform;
        
        // Create the animation group and attach it to the layer
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = [NSArray arrayWithArray:animations];
        [layer addAnimation:animationGroup forKey:nil];
    }
}

- (void)cancelAnimations
{
    for (CALayer *layer in [self objects]) {
        [layer removeAllAnimations];
    }
}

#pragma mark Reverse animation

- (id)reverseAnimationStep
{
    HLSLayerAnimationStep *reverseAnimationStep = [super reverseAnimationStep];
    // TODO: Add category to CAMediaTimingFunction to generate the inverse function, and add defines
    //       for the common animations (e.g. HLSMediaTimingFunctionEaseInEaseOut)
#if 0
    switch (self.curve) {
        case UIViewAnimationCurveEaseIn:
            reverseAnimationStep.curve = UIViewAnimationCurveEaseOut;
            break;
            
        case UIViewAnimationCurveEaseOut:
            reverseAnimationStep.curve = UIViewAnimationCurveEaseIn;
            break;
            
        case UIViewAnimationCurveLinear:
        case UIViewAnimationCurveEaseInOut:
        default:
            // Nothing to do
            break;
    }
#endif
    return reverseAnimationStep;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSLayerAnimationStep *animationStepCopy = [super copyWithZone:zone];
    animationStepCopy.timingFunction = self.timingFunction;
    return animationStepCopy;
}

@end

