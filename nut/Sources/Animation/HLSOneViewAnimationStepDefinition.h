//
//  HLSOneViewAnimationStepDefinition.h
//  nut
//
//  Created by Samuel Défago on 2/9/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"
#import "HLSViewAnimationStep.h"

/**
 * When creating an animation step (HLSAnimationStep), you need to know which views you are animating. This is perfectly 
 * fine as long as you can get your hands on the views to animate. Some objects might want to hide the internal details 
 * of their views, though, but still want to let you customize the animations they apply on them. In such cases,
 * instantiating animation steps directly is not an option.
 *
 * An HLSOneViewAnimationStepDefinition is a way to provide the components of an animation step involving at most one 
 * unknown view. Conceptually, it is similar to a functor with one argument. This functor can then be applied to generate
 * an animation step once the view is known.
 *
 * The usual example is a view controller container which manages the view controller's views it displays, but which
 * lets you customize the transition animations it uses to present them. By not requiring you to access a view
 * controller's view directly (which would lazily create it), the container can defer instantiation until it really
 * needs to instantiate it.
 *
 * Designated initializer: init
 */
@interface HLSOneViewAnimationStepDefinition : NSObject {
@private
    HLSViewAnimationStep *m_viewAnimationStep;
    NSTimeInterval m_duration;
    UIViewAnimationCurve m_curve;
}

/**
 * Create a definition with standard settings
 */
+ (HLSOneViewAnimationStepDefinition *)oneViewAnimationStepDefinition;

/**
 * View animation steps for the involved view
 */
@property (nonatomic, retain) HLSViewAnimationStep *viewAnimationStep;

/**
 * Animation step properties
 */
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIViewAnimationCurve curve;

/**
 * Generate the animation step for the view given as parameter. If the view is nil, it will not be part of
 * the animation step (note that a valid animation step object is returned, not nil; this lets callers further
 * customize the animation step if they need to)
 */
- (HLSAnimationStep *)animationStepWithView:(UIView *)viewOrNil;

@end
