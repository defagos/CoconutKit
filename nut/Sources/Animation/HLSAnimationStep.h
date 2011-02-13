//
//  HLSAnimationStep.h
//  nut
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimationStep.h"

/**
 * An animation step (HLSAnimationStep) is the combination of several view animation steps (HLSViewAnimationStep) applied
 * to a set of views, and represent the collective set of changes applied to these views during some time interval. An 
 * animation (HLSAnimation) is then simply a collection of animation steps.
 *
 * Several convenience constructors are available to help you create animation steps for common cases, most notably
 * when a single view is involved (in such cases, you do no really want to instantiate view animation step objects
 * individually, do you?)
 *
 * Remark: This class was initially named HLSAnimationFrame, but was renamed to avoid confusion with the UIView frame property
 *         (which is the view property an animation step usually alters!)
 *
 * Designated initializer: init (create an animation step with default settings)
 */
@interface HLSAnimationStep : NSObject {
@private
    NSMutableArray *m_viewKeys;                             // track in which order views were added to the animation step
    NSMutableDictionary *m_viewToViewAnimationStepMap;      // map a UIView objects to the view animation step to be applied on it
    NSTimeInterval m_duration;
    UIViewAnimationCurve m_curve;
    NSString *m_tag;
}

/**
 * Convenience constructor for an animation step with default settings and no view to animate
 */
+ (HLSAnimationStep *)animationStep;

/**
 * Animation step moving a single view between two frames. Both frames must describe positions of the view to animate
 * in the coordinate system of its superview (otherwise the result of the animation step is undefined)
 */
+ (HLSAnimationStep *)animationStepAnimatingView:(UIView *)view 
                                       fromFrame:(CGRect)fromFrame 
                                         toFrame:(CGRect)toFrame;

+ (HLSAnimationStep *)animationStepAnimatingView:(UIView *)view 
                                       fromFrame:(CGRect)fromFrame 
                                         toFrame:(CGRect)toFrame
                              withAlphaVariation:(CGFloat)alphaVariation;

/**
 * Animation step applying a translation to a view or an NSArray of UIView objects
 */
+ (HLSAnimationStep *)animationStepTranslatingView:(UIView *)view 
                                        withDeltaX:(CGFloat)deltaX
                                            deltaY:(CGFloat)deltaY;

+ (HLSAnimationStep *)animationStepTranslatingView:(UIView *)view 
                                        withDeltaX:(CGFloat)deltaX
                                            deltaY:(CGFloat)deltaY
                                    alphaVariation:(CGFloat)alphaVariation;

+ (HLSAnimationStep *)animationStepTranslatingViews:(NSArray *)views 
                                         withDeltaX:(CGFloat)deltaX
                                             deltaY:(CGFloat)deltaY;

+ (HLSAnimationStep *)animationStepTranslatingViews:(NSArray *)views 
                                         withDeltaX:(CGFloat)deltaX
                                             deltaY:(CGFloat)deltaY
                                     alphaVariation:(CGFloat)alphaVariation;

/**
 * Animation step applying a transform and an alpha variation to a view or an NSArray of UIView objects
 */
+ (HLSAnimationStep *)animationStepUpdatingView:(UIView *)view
                                  withTransform:(CGAffineTransform)transform
                                 alphaVariation:(CGFloat)alphaVariation;

+ (HLSAnimationStep *)animationStepUpdatingViews:(NSArray *)views
                                   withTransform:(CGAffineTransform)transform
                                  alphaVariation:(CGFloat)alphaVariation;

/**
 * Animation step varying the alpha of a view or of an NSArray of UIView objects
 */
+ (HLSAnimationStep *)animationStepUpdatingView:(UIView *)view
                             withAlphaVariation:(CGFloat)alphaVariation;

+ (HLSAnimationStep *)animationStepUpdatingViews:(NSArray *)views
                              withAlphaVariation:(CGFloat)alphaVariation;

/**
 * Setting a view animation step for a view. Only one animation step can be defined at most for a view during
 * an animation step. The view is not retained. The order in which view animation steps are added is important
 * if your animation changes their z-ordering (refer to the HLSAnimation bringToFront property documentation)
 */
- (void)addViewAnimationStep:(HLSViewAnimationStep *)viewAnimationStep forView:(UIView *)view;

/**
 * All views changed by the animation, returned in the order they were added to the animation step object
 */
- (NSArray *)views;

/**
 * Return the view animation step defined for a view, or nil if none is found
 */
- (HLSViewAnimationStep *)viewAnimationStepForView:(UIView *)view;

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
