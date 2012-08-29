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
#import "HLSLogger.h"

#if TARGET_IPHONE_SIMULATOR
#import <dlfcn.h>
#endif

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
        
        // Reinitialize layer properties which could have been changed when pausing the animation
        // during a previous step
        layer.timeOffset = 0.;
        layer.beginTime = delay;
        
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
        else {
            layer.opacity = opacity;
        }
        
        // Animate the frame. The transform has to be applied on the layer center. This requires a conversion in the coordinate system
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
        
        // Create the animation group and attach it to the layer
        if (animated) {
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.animations = [NSArray arrayWithArray:animations];
            animationGroup.beginTime = beginTime;
            [layer addAnimation:animationGroup forKey:@"layerAnimationGroup"];
        }
    }
    
    // Animate the dummy view. It is also used to set a delegate (one for all animations in the transaction)
    // which will receive the start / end animation events
    if (animated) {
        // Reinitialize layer properties which could have been changed when pausing the animation
        // during a previous step
        self.dummyView.layer.timeOffset = 0.;
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

- (void)togglePauseAnimation
{
    for (CALayer *layer in [self objects]) {
        [layer togglePauseAnimations];
    }
    [self.dummyView.layer togglePauseAnimations];
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
        CAAnimationGroup *animationGroup = (CAAnimationGroup *)[layer animationForKey:@"layerAnimationGroup"];
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

