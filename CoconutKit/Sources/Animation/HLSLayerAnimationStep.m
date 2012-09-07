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
static NSString * const kLayerNonProjectedSublayerTransformKey = @"HLSNonProjectedSublayerTransform";
static NSString * const kLayerCameraZPositionForSublayersKey = @"HLSLayerCameraZPositionForSublayers";

// Remark: CoreAnimation default settings are duration = 0.25 and linear timing function, but
//         to be consistent with UIView block-based animations we do not override the default
//         duration received from HLSAnimationStep (0.2) and set an ease-in ease-out function

@interface HLSLayerAnimationStep ()

@property (nonatomic, retain) UIView *dummyView;

- (void)updateToFinalState;

- (void)animationDidStart:(CAAnimation *)animation;
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished;

@end

@implementation HLSLayerAnimationStep

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        // This dummy view is always animated. There is no way to set a start callback for a CATransaction.
        // Therefore, we always ensure the transaction is never empty by animating a dummy view, and we set
        // animation callbacks for its associated animation (which, since it is part of the transaction,
        // will be triggered when the transaction begins / ends animating)
        self.dummyView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [[UIApplication sharedApplication].keyWindow addSubview:self.dummyView];
    }
    return self;
}

- (void)dealloc
{
    self.timingFunction = nil;
    
    [self.dummyView removeFromSuperview];
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

- (void)playAnimationAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated
{
    if (animated) {
        [CATransaction begin];
        
        NSTimeInterval duration = self.duration;
        
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
        }
#endif
        [CATransaction setAnimationDuration:duration];
        [CATransaction setAnimationTimingFunction:self.timingFunction];
    }
    
    if (! animated && ! doubleeq(delay, 0.f)) {
        HLSLoggerWarn(@"A delay has been defined, but animated = NO. Ignored");
    }
    
    CFTimeInterval beginTime = CACurrentMediaTime() + delay;
    
    // Animate all layers involved in the animation step
    for (CALayer *layer in [self objects]) {        
        HLSLayerAnimation *layerAnimation = (HLSLayerAnimation *)[self objectAnimationForObject:layer];
        NSAssert(layerAnimation != nil, @"Missing layer animation; data consistency failure");
                
        // Remark: For each property we animate, we still must set the final value manually (CoreAnimations
        //         animate properties but do not set them). Usually, we can do this right where the CoreAnimation
        //         is created, but this does not work if a delay has been set (in which case this will be
        //         noticed before the animation actually starts). We therefore apply the following strategy:
        //           1) If animated, we create the animation, and set the final properties in the start
        //              callback
        //           2) If not animated we set the final properties on the spot
        //           3) If an animation step is terminated, we set the final properties right when terminatingm
        //              and not anymore in the start callback. This behaves correctly whether the animation
        //              step is terminated while animating layers or during its initial delay period
        
        NSMutableArray *animations = [NSMutableArray array];
        
        // Opacity animation (opacity must always lie between 0.f and 1.f)
        CGFloat opacity = layer.opacity + layerAnimation.opacityIncrement;
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
        else {
            layer.opacity = opacity;
        }
        
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
        else {
            layer.transform = transform;
        }
        
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
        else {
            layer.anchorPoint = anchorPoint;
            layer.anchorPointZ = anchorPointZ;
        }
        
        // Rasterization
        if (layerAnimation.togglingShouldRasterize) {
            BOOL shouldRasterize = ! layer.shouldRasterize;
            if (animated) {
                CABasicAnimation *shouldRasterizeAnimation = [CABasicAnimation animationWithKeyPath:@"shouldRasterize"];
                [shouldRasterizeAnimation setFromValue:[NSNumber numberWithBool:layer.shouldRasterize]];
                [shouldRasterizeAnimation setToValue:[NSNumber numberWithBool:shouldRasterize]];
                [animations addObject:shouldRasterizeAnimation];
            }
            else {
                layer.shouldRasterize = shouldRasterize;
            }
        }
        
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
        else {
            layer.sublayerTransform = sublayerTransform;
        }
        
        // Create the animation group and attach it to the layer
        if (animated) {
            // Needed so that pausing layers behaves nicely
            layer.beginTime = delay;
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.animations = [NSArray arrayWithArray:animations];
            animationGroup.beginTime = beginTime;
            [layer addAnimation:animationGroup forKey:kLayerAnimationGroupKey];
        }
    }
    
    // Animate the dummy view. It is also used to set a delegate (one for all animations in the transaction)
    // which will receive the start / end animation events
    if (animated) {
        // Needed so that pausing layers behaves nicely
        self.dummyView.layer.beginTime = delay;
        
        CABasicAnimation *dummyViewOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        dummyViewOpacityAnimation.fromValue = [NSNumber numberWithFloat:self.dummyView.layer.opacity];
        dummyViewOpacityAnimation.toValue = [NSNumber numberWithFloat:1.f - self.dummyView.layer.opacity];
        dummyViewOpacityAnimation.beginTime = beginTime;
        dummyViewOpacityAnimation.delegate = self;
        [self.dummyView.layer addAnimation:dummyViewOpacityAnimation forKey:nil];
    }
    else {
        self.dummyView.layer.opacity = 1.f - self.dummyView.layer.opacity;
    }
    
    // Animated
    if (animated) {
        [CATransaction commit];
    }
}

- (void)pauseAnimation
{
    for (CALayer *layer in [self objects]) {
        [layer pauseAllAnimations];
    }
    [self.dummyView.layer pauseAllAnimations];
}

- (void)resumeAnimation
{
    for (CALayer *layer in [self objects]) {
        [layer resumeAllAnimations];
    }
    [self.dummyView.layer resumeAllAnimations];
}

- (BOOL)isAnimationPaused
{
    return [self.dummyView.layer isPaused];
}

- (void)terminateAnimation
{
    // Set the final values immediately (won't be done anymore in the animation start callback)
    [self updateToFinalState];
    
    // We recursively cancel subview animations. It does not seem to be an issue here (like for UIViews, see
    // HLSViewAnimationStep.m), since we do not alter layer frames, but this is a safety measure and is the
    // correct way to cancel animations attached to a layer
    for (CALayer *layer in [self objects]) {
        [layer removeAllAnimationsRecursively];
    }
    [self.dummyView.layer removeAllAnimationsRecursively];
}

#pragma mark Reverse animation

- (id)reverseAnimationStep
{
    HLSLayerAnimationStep *reverseAnimationStep = [super reverseAnimationStep];
    self.timingFunction = [self.timingFunction inverseFunction];
    return reverseAnimationStep;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSLayerAnimationStep *animationStepCopy = [super copyWithZone:zone];
    animationStepCopy.timingFunction = self.timingFunction;
    return animationStepCopy;
}

#pragma mark Setting the animation final state

- (void)updateToFinalState
{
    // Set all final values
    for (CALayer *layer in [self objects]) {
        CAAnimationGroup *animationGroup = (CAAnimationGroup *)[layer animationForKey:kLayerAnimationGroupKey];
        for (CABasicAnimation *layerAnimation in animationGroup.animations) {
            [layer setValue:layerAnimation.toValue forKeyPath:layerAnimation.keyPath];
        }
    }
    self.dummyView.layer.opacity = 1.f - self.dummyView.layer.opacity;
}

#pragma mark Animation callbacks

- (void)animationDidStart:(CAAnimation *)animation
{
    // If the animation is being terminated, this already was made when -terminateAnimation was called
    if (! self.terminating) {
        [self updateToFinalState];
    }
    
    [self notifyAsynchronousAnimationStepWillStart];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished
{
    [self notifyAsynchronousAnimationStepDidStopFinished:finished];
}

@end

