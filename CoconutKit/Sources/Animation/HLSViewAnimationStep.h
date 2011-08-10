//
//  HLSViewAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view animation step describes the changes applied to a view during an animation step (HLSAnimationStep). An 
 * animation step is the combination of several view animation steps (HLSViewAnimationStep) applied to a set of views, and 
 * represent the collective set of changes applied to these views during some time interval. An animation (HLSAnimation) 
 * is then simply a collection of animation steps.
 *
 * Several convenience constructors are available to help you create view animation steps without requiring you to calculate 
 * coordinates explicitly (you can if you require this flexibility, of course). After you have created a view animation step 
 * object, you can use the other available accessors to set more properties.
 *
 * Designated initializer: init (create a view animation step with default settings)
 */
@interface HLSViewAnimationStep : NSObject {
@private
    CGAffineTransform m_transform;
    CGFloat m_alphaVariation;
}

/**
 * Convenience constructor for instantiating a view animation step with default settings (no change)
 */
+ (HLSViewAnimationStep *)viewAnimationStep;

/**
 * View animation step moving a view between two frames. Both frames must describe positions of the view to animate
 * in the coordinate system of its superview (otherwise the result of the animation step is undefined)
 */
+ (HLSViewAnimationStep *)viewAnimationStepAnimatingViewFromFrame:(CGRect)fromFrame 
                                                          toFrame:(CGRect)toFrame;

+ (HLSViewAnimationStep *)viewAnimationStepAnimatingViewFromFrame:(CGRect)fromFrame 
                                                          toFrame:(CGRect)toFrame
                                               withAlphaVariation:(CGFloat)alphaVariation;

/**
 * View animation step applying a translation to a view frame
 */
+ (HLSViewAnimationStep *)viewAnimationStepTranslatingViewWithDeltaX:(CGFloat)deltaX
                                                              deltaY:(CGFloat)deltaY;

+ (HLSViewAnimationStep *)viewAnimationStepTranslatingViewWithDeltaX:(CGFloat)deltaX
                                                              deltaY:(CGFloat)deltaY
                                                      alphaVariation:(CGFloat)alphaVariation;

/**
 * View animation step applying a transform and an alpha variation
 */
+ (HLSViewAnimationStep *)viewAnimationStepUpdatingViewWithTransform:(CGAffineTransform)transform
                                                      alphaVariation:(CGFloat)alphaVariation;

/**
 * View animation step varying the alpha of a view
 */
+ (HLSViewAnimationStep *)viewAnimationStepUpdatingViewWithAlphaVariation:(CGFloat)alphaVariation;

/**
 * The affine transformation which must be applied during the view animation step
 * Default value is the identity
 */
@property (nonatomic, assign) CGAffineTransform transform;

/**
 * Alpha increment or decrement to be applied during the view animation step. Any value between 1.f and -1.f can be provided, 
 * though you should ensure that alphas never add to a value outside [0, 1] during an animation.
 * Default value is 0.f
 */
@property (nonatomic, assign) CGFloat alphaVariation;

@end
