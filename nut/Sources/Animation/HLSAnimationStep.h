//
//  HLSAnimationStep.h
//  nut
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * An animation is made of animation steps, moving a view from a position into another one (and maybe animating other animatable 
 * properties as well). The view itself is not part of the HLSAnimationStep object but is managed by the animation, which 
 * successively applies its steps onto it. Each one is applied to the state of the animation as yielded by the previous animation step.
 *
 * Several convenience constructors are available to help you create animation steps without requiring you to calculate coordinates
 * explicitly (you can if you require this flexibility, of course). After you have created a step object, use the other accessors
 * to set other animatable properties or animation settings.
 *
 * Remark: This class was initially named HLSAnimationFrame, but was renamed to avoid confusion with the UIView frame property
 *         which an animation step usually alters
 *
 * Designated initializer: init (identity frame)
 */
@interface HLSAnimationStep : NSObject {
@private
    CGAffineTransform m_transform;
    CGFloat m_deltaAlpha;
    NSTimeInterval m_duration;
    NSTimeInterval m_delay;
    UIViewAnimationCurve m_curve;    
}

/**
 * Identity animation step (leaves a view intact)
 */
+ (HLSAnimationStep *)animationStep;

/**
 * Animation step moving a view between two frames. Both frames must be given relatively to the view's parent coordinate system
 */
+ (HLSAnimationStep *)animationStepMovingView:(UIView *)view fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;

/**
 * Animation step moving a view from its current frame into some other frame. The destination frame must be given relatively 
 * to the view's parent coordinate system
 */
+ (HLSAnimationStep *)animationStepMovingView:(UIView *)view toFrame:(CGRect)toFrame;

/**
 * Animation step applying a translation to a view frame
 */
+ (HLSAnimationStep *)animationStepTranslatingView:(UIView *)view
                                            deltaX:(CGFloat)deltaX
                                            deltaY:(CGFloat)deltaY;

/**
 * The affine transformation which must be applied during the step (the default value is the identity)
 */
@property (nonatomic, assign) CGAffineTransform transform;

/**
 * The opacity change to apply during the animation (between -1.f and 1.f). Default is 0.f. You should be careful
 * that the total alpha never crosses 0.f or 1.f
 */
@property (nonatomic, assign) CGFloat deltaAlpha;

/**
 * Animation step settings
 */
@property (nonatomic, assign) NSTimeInterval duration;                      // default: 0.2f
@property (nonatomic, assign) NSTimeInterval delay;                         // default: 0.f
@property (nonatomic, assign) UIViewAnimationCurve curve;                   // default: UIViewAnimationCurveEaseInOut

@end
