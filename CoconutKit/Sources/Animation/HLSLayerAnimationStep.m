//
//  HLSLayerAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLayerAnimationStep.h"

#import "CALayer+HLSExtensions.h"
#import "CAMediaTimingFunction+HLSExtensions.h"
#import "HLSAnimationStep+Protected.h"
#import "HLSFloat.h"
#import "HLSLayerAnimation+Friend.h"
#import "HLSLogger.h"

#if TARGET_IPHONE_SIMULATOR
#import <dlfcn.h>
#endif

static NSString * const kLayerAnimationGroupKey = @"HLSLayerAnimationGroup";
static NSString * const kDummyViewLayerAnimationKey = @"HLSDummyViewLayerAnimation";

static NSString * const kLayerNonProjectedSublayerTransformKey = @"HLSNonProjectedSublayerTransform";
static NSString * const kLayerCameraZPositionForSublayersKey = @"HLSLayerCameraZPositionForSublayers";

// Remark: CoreAnimation default settings are duration = 0.25 and linear timing function, but
//         to be consistent with UIView block-based animations we do not override the default
//         duration received from HLSAnimationStep (0.2) and set an ease-in ease-out function

@interface HLSLayerAnimationStep ()

@property (nonatomic, retain) UIView *dummyView;

- (void)animationDidStart:(CAAnimation *)animation;
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished;

@end

@implementation HLSLayerAnimationStep

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];        
    }
    return self;
}

- (void)dealloc
{
    self.timingFunction = nil;
    self.dummyView = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize timingFunction = m_timingFunction;

@synthesize dummyView = m_dummyView;

#pragma mark Managing the animation

- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forLayer:(CALayer *)layer
{
    [self addObjectAnimation:layerAnimation forObject:layer];
}

- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forView:(UIView *)view
{
    [self addLayerAnimation:layerAnimation forLayer:view.layer];
}

- (void)playAnimationWithStartTime:(NSTimeInterval)startTime animated:(BOOL)animated
{
    NSAssert(doublele(startTime, self.duration), @"The start time of a step cannot be greater than its duration");
    
    NSTimeInterval duration = self.duration;
    if (animated) {
        // This dummy view is always animated. There is no way to set a start callback for a CATransaction.
        // Therefore, we always ensure the transaction is never empty by animating a dummy view, and we set
        // animation callbacks for its associated animation (which, since it is part of the transaction,
        // will be triggered when the transaction begins / ends animating)
        self.dummyView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [[UIApplication sharedApplication].keyWindow addSubview:self.dummyView];
        
        [CATransaction begin];
        
        // For tests within the iOS simulator only: Slow down Core Animations as UIView block-based animations (when
        // quickly pressing the shift key three times)
        //
        // Credits to Cédric Luthi, see http://twitter.com/0xced/statuses/232860477317869568
#if TARGET_IPHONE_SIMULATOR
        static CGFloat (*s_UIAnimationDragCoefficient)(void) = NULL;
        static BOOL s_firstLoad = YES;
        if (s_firstLoad) {
            void *UIKitDylib = dlopen([[[NSBundle bundleForClass:[UIApplication class]] executablePath] fileSystemRepresentation], RTLD_LAZY);
            s_UIAnimationDragCoefficient = (CGFloat (*)(void))dlsym(UIKitDylib, "UIAnimationDragCoefficient");
            if (! s_UIAnimationDragCoefficient) {
                HLSLoggerInfo(@"UIAnimationDragCoefficient not found. Slow animations won't be available for animations based on Core Animation");
            }
            
            s_firstLoad = NO;
        }
        
        if (s_UIAnimationDragCoefficient) {
            duration *= s_UIAnimationDragCoefficient();
            startTime *= s_UIAnimationDragCoefficient();
        }
#endif
        // If we want to play an animation from somewhere in its middle, we need to reduce the duration of the enclosing
        // group or transaction accordingly, while letting the duration of the individual animations unchanged (see the
        // CAAnimationGroup creation below). The child animation is not scaled, rather cut at its end (see the CAAnimationGroup
        // class documentation), yielding the desired effect. For the same reason, the timing function must be applied on
        // the animation, not on the transaction
        [CATransaction setAnimationDuration:duration - startTime];
    }
    
    // Animate all layers involved in the animation step
    for (CALayer *layer in [self objects]) {        
        HLSLayerAnimation *layerAnimation = (HLSLayerAnimation *)[self objectAnimationForObject:layer];
        NSAssert(layerAnimation != nil, @"Missing layer animation; data consistency failure");
                
        // Remark: For each property we animate, we still must set the final value manually (CoreAnimations animate properties
        // but do not set them). Since we do not need to support delays (which are implemented at the HLSAnimation level), we
        // can do it right here, eliminating potentially flickering animations (for more information, see HLSAnimation.m)
        NSMutableArray *animations = [NSMutableArray array];
        
        // Opacity animation (opacity must always lie between 0.f and 1.f)
        CGFloat opacity = layer.opacity + layerAnimation.opacityIncrement;
        if (floatlt(opacity, -1.f)) {
            HLSLoggerWarn(@"Layer animations adding to an opacity value larger than -1 for layer %@. Fixed to -1, but your animation is incorrect", layer);
            opacity = -1.f;
        }
        else if (floatgt(opacity, 1.f)) {
            HLSLoggerWarn(@"Layer animations adding to an opacity value larger than 1 for layer %@. Fixed to 1, but your animation is incorrect", layer);
            opacity = 1.f;
        }
        
        if (animated) {
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [opacityAnimation setFromValue:[NSNumber numberWithFloat:layer.opacity]];
            [opacityAnimation setToValue:[NSNumber numberWithFloat:opacity]];
            [animations addObject:opacityAnimation];
        }
        layer.opacity = opacity;
        
        // Animate the transform. The transform has to be applied on the layer center. This requires a conversion in the coordinate system
        // centered on the layer
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
        
        // Animate the anchor point
        CGPoint anchorPoint = CGPointMake(layer.anchorPoint.x + layerAnimation.anchorPointTranslationParameters.v1,
                                          layer.anchorPoint.y + layerAnimation.anchorPointTranslationParameters.v2);
        CGFloat anchorPointZ = layer.anchorPointZ + layerAnimation.anchorPointTranslationParameters.v3;
        
        if (animated) {
            CABasicAnimation *anchorPointAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
            [anchorPointAnimation setFromValue:[NSValue valueWithCGPoint:layer.anchorPoint]];
            [anchorPointAnimation setToValue:[NSValue valueWithCGPoint:anchorPoint]];
            [animations addObject:anchorPointAnimation];
            
            CABasicAnimation *anchorPointZAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPointZ"];
            [anchorPointZAnimation setFromValue:[NSNumber numberWithFloat:layer.anchorPointZ]];
            [anchorPointZAnimation setToValue:[NSNumber numberWithFloat:anchorPointZ]];
            [animations addObject:anchorPointZAnimation];
        }
        layer.anchorPoint = anchorPoint;
        layer.anchorPointZ = anchorPointZ;
        
        // Rasterization
        if (layerAnimation.togglingShouldRasterize) {
            BOOL shouldRasterize = ! layer.shouldRasterize;
            if (animated) {
                CABasicAnimation *shouldRasterizeAnimation = [CABasicAnimation animationWithKeyPath:@"shouldRasterize"];
                [shouldRasterizeAnimation setFromValue:[NSNumber numberWithBool:layer.shouldRasterize]];
                [shouldRasterizeAnimation setToValue:[NSNumber numberWithBool:shouldRasterize]];
                [animations addObject:shouldRasterizeAnimation];
            }
            layer.shouldRasterize = shouldRasterize;
        }
        
        // Rasterization scale
        CGFloat rasterizationScale = layer.rasterizationScale + layerAnimation.rasterizationScaleIncrement;
        if (animated) {
            CABasicAnimation *rasterizationScaleAnimation = [CABasicAnimation animationWithKeyPath:@"rasterizationScale"];
            [rasterizationScaleAnimation setFromValue:[NSNumber numberWithFloat:layer.rasterizationScale]];
            [rasterizationScaleAnimation setToValue:[NSNumber numberWithFloat:rasterizationScale]];
            [animations addObject:rasterizationScaleAnimation];
        }
        layer.rasterizationScale = rasterizationScale;
        
        // Get the sublayer transform without its perspective component (saved as additional layer information)
        NSValue *nonProjectedSublayerTransformValue = [layer valueForKey:kLayerNonProjectedSublayerTransformKey];
        CATransform3D nonProjectedSublayerTransform = CATransform3DIdentity;
        if (nonProjectedSublayerTransformValue) {
            nonProjectedSublayerTransform = [nonProjectedSublayerTransformValue CATransform3DValue];
        }
        else {
            nonProjectedSublayerTransform = layer.sublayerTransform;
        }
        
        // Get the current camera position (saved as additional layer information)
        NSNumber *sublayerCameraZPositionNumber = [layer valueForKey:kLayerCameraZPositionForSublayersKey];
        CGFloat sublayerCameraZPosition = 0.f;
        if (sublayerCameraZPositionNumber) {
            sublayerCameraZPosition = [sublayerCameraZPositionNumber floatValue];
        }
        else {
            sublayerCameraZPosition = floateq(layer.sublayerTransform.m34, 0.f) ? 0.f : 1.f / layer.sublayerTransform.m34;
        }
        
        // Calculate the sublayer transform (without perspective component)
        CATransform3D sublayerTranslationTransform = CATransform3DMakeTranslation(-nonProjectedSublayerTransform.m41, -nonProjectedSublayerTransform.m42, 0.f);
        CATransform3D sublayerConvTransform = CATransform3DConcat(CATransform3DConcat(sublayerTranslationTransform, layerAnimation.sublayerTransform),
                                                                  CATransform3DInvert(sublayerTranslationTransform));
        CATransform3D sublayerTransform = CATransform3DConcat(nonProjectedSublayerTransform, sublayerConvTransform);
        
        // Calculate the new z-position of the camera
        sublayerCameraZPosition += layerAnimation.sublayerCameraTranslationZ;
        
        // Save the information relative / not relative to the perspective separately
        [layer setValue:[NSNumber numberWithFloat:sublayerCameraZPosition] forKey:kLayerCameraZPositionForSublayersKey];
        [layer setValue:[NSValue valueWithCATransform3D:sublayerTransform] forKey:kLayerNonProjectedSublayerTransformKey];
        
        // Create the perspective matrix (see http://en.wikipedia.org/wiki/3D_projection#Perspective_projection)
        CATransform3D perspectiveProjectionTransform = CATransform3DIdentity;
        if (! floateq(sublayerCameraZPosition, 0.f)) {
            perspectiveProjectionTransform.m34 = -1.f / sublayerCameraZPosition;
        }
        
        // Apply the perspective
        sublayerTransform = CATransform3DConcat(sublayerTransform, perspectiveProjectionTransform);
        
        if (animated) {
            CABasicAnimation *sublayerTransformAnimation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
            [sublayerTransformAnimation setFromValue:[NSValue valueWithCATransform3D:layer.sublayerTransform]];
            [sublayerTransformAnimation setToValue:[NSValue valueWithCATransform3D:sublayerTransform]];
            [animations addObject:sublayerTransformAnimation];
        }
        layer.sublayerTransform = sublayerTransform;
        
        // Create the animation group and attach it to the layer
        if (animated) {
            // All animations must have the expected duration, but must be offset according to the start time
            // when played from somewhere in their middle. The timing function must also be attached to each
            // animation
            for (CAAnimation *animation in animations) {
                animation.duration = duration;
                animation.timeOffset = startTime;
                animation.timingFunction = self.timingFunction;
            }
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.animations = [NSArray arrayWithArray:animations];
            animationGroup.delegate = self;
            [layer addAnimation:animationGroup forKey:kLayerAnimationGroupKey];
        }
    }
    
    // Animate the dummy view. It is also used to set a delegate (one for all animations in the transaction)
    // which will receive the start / end animation events
    if (animated) {
        CABasicAnimation *dummyViewOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        dummyViewOpacityAnimation.fromValue = [NSNumber numberWithFloat:self.dummyView.layer.opacity];
        dummyViewOpacityAnimation.toValue = [NSNumber numberWithFloat:1.f - self.dummyView.layer.opacity];
        dummyViewOpacityAnimation.delegate = self;
        [self.dummyView.layer addAnimation:dummyViewOpacityAnimation forKey:kDummyViewLayerAnimationKey];
    }
        
    // Animated
    if (animated) {
        // We need to keep track of animations which have started / ended (there is no way to known when a
        // CATransaction has started or ended, and there order in which the child animations are started or
        // ended is unspecified)
        m_numberOfStartedLayerAnimations = 0;
        m_numberOfFinishedLayerAnimations = 0;
        
        // We want to be able to test the number of animations in the animation stop callback. If the animated
        // layers are dead when the end callback is called (which can happen if the layer they are on is
        // destroyed while the animation was running), we cannot compare to self.objects anymore (otherwise
        // the application will crash). We therefore keep track of how animations are expected, but in a safe way
        // (+ 1 for the dummy view animation)
        m_numberOfLayerAnimations = [self.objects count] + 1;
        
        // When a start time has been defined, the animation must look like it started earlier
        m_startTime = CACurrentMediaTime() - startTime;
        
        [CATransaction commit];
    }
}

- (void)pauseAnimation
{
    for (CALayer *layer in [self objects]) {
        [layer pauseAllAnimations];
    }
    [self.dummyView.layer pauseAllAnimations];
    
    m_pauseTime = CACurrentMediaTime();
}

- (void)resumeAnimation
{
    for (CALayer *layer in [self objects]) {
        [layer resumeAllAnimations];
    }
    [self.dummyView.layer resumeAllAnimations];
    
    m_previousPauseDuration += CACurrentMediaTime() - m_pauseTime;
    m_pauseTime = 0.;
}

- (BOOL)isAnimationPaused
{
    return [self.dummyView.layer isPaused];
}

- (void)terminateAnimation
{
    // We recursively cancel subview animations. It does not seem to be an issue here (like for UIViews, see
    // HLSViewAnimationStep.m), since we do not alter layer frames, but this is a safety measure and is the
    // correct way to cancel animations attached to a layer
    for (CALayer *layer in [self objects]) {
        [layer removeAllAnimationsRecursively];
    }
    [self.dummyView.layer removeAllAnimationsRecursively];
}

- (NSTimeInterval)elapsedTime
{
    NSTimeInterval currentPauseDuration = 0.;
    if (! doubleeq(m_pauseTime, 0.)) {
        currentPauseDuration = CACurrentMediaTime() - m_pauseTime;
    }
    
    return CACurrentMediaTime() - m_startTime - m_previousPauseDuration - currentPauseDuration;
}

#pragma mark Reverse animation

- (id)reverseAnimationStep
{
    HLSLayerAnimationStep *reverseAnimationStep = [super reverseAnimationStep];
    reverseAnimationStep.timingFunction = [self.timingFunction inverseFunction];
    return reverseAnimationStep;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSLayerAnimationStep *animationStepCopy = [super copyWithZone:zone];
    animationStepCopy.timingFunction = self.timingFunction;
    return animationStepCopy;
}

#pragma mark Animation callbacks

- (void)animationDidStart:(CAAnimation *)animation
{
    m_numberOfStartedLayerAnimations++;
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished
{
    m_numberOfFinishedLayerAnimations++;
    
    if (m_numberOfFinishedLayerAnimations == m_numberOfLayerAnimations) {
        NSAssert(m_numberOfStartedLayerAnimations == m_numberOfFinishedLayerAnimations,
                 @"The number of started and finished animations must be the same");
        
        [self.dummyView removeFromSuperview];
        self.dummyView = nil;
        
        [self notifyAsynchronousAnimationStepDidStopFinished:finished];
    }
}

@end

