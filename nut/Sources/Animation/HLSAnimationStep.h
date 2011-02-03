//
//  HLSAnimationStep.h
//  nut
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * An animation is made of animation steps, moving a view within its superview from a position into another one (and maybe animating 
 * other animatable properties as well during this process). An animation object simply applies animation steps onto the view
 * it animates. Each step is applied to the state of the animation as yielded by the previous animation step.
 *
 * Several convenience constructors are available to help you create animation steps without requiring you to calculate coordinates
 * explicitly (you can if you require this flexibility, of course). After you have created a step object, you can use the other accessors
 * to set other animatable properties or animation settings.
 *
 * Remark: This class was initially named HLSAnimationFrame, but was renamed to avoid confusion with the UIView frame property
 *         (which is the view property an animation step usually alters!)
 *
 * Designated initializer: init (create an animation step with default settings)
 */
@interface HLSAnimationStep : NSObject {
@private
    CGAffineTransform m_transform;
    CGFloat m_alphaVariation;
    NSTimeInterval m_duration;
    UIViewAnimationCurve m_curve;
    NSString *m_tag;
}

/**
 * Convenience constructor for an animation step with default settings
 */
+ (HLSAnimationStep *)animationStep;

/**
 * Animation step moving a view between two frames. Both frames must describe positions of the view to animate
 * relative to its superview (otherwise the result of the animation step is undefined)
 */
+ (HLSAnimationStep *)animationStepAnimatingViewFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;

/**
 * Animation step applying a translation to a view frame
 */
+ (HLSAnimationStep *)animationStepTranslatingViewWithDeltaX:(CGFloat)deltaX
                                                      deltaY:(CGFloat)deltaY;

/**
 * The affine transformation which must be applied during the step
 * Default value is the identity
 */
@property (nonatomic, assign) CGAffineTransform transform;

/**
 * Alpha increment or decrement to be applied during the animation step. Any value between 1.f and -1.f can be provided, 
 * though you should ensure that animation steps never add to a value outside [0, 1] during the animation.
 * Default value is 0.f
 */
@property (nonatomic, assign) CGFloat alphaVariation;

/**
 * Animation step settings
 */
@property (nonatomic, assign) NSTimeInterval duration;                      // default: 0.2
@property (nonatomic, assign) UIViewAnimationCurve curve;                   // default: UIViewAnimationCurveEaseInOut

/**
 * Optional tag to help identifying animation steps
 */
@property (nonatomic, retain) NSString *tag;

@end
