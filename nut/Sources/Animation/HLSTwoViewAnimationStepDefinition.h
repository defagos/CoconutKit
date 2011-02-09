//
//  HLSTwoViewAnimationStepDefinition.h
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
 * An HLSTwoViewAnimationStepDefinition is a way to provide the components of an animation step involving at most two 
 * unknown views. Conceptually, it is similar to a functor with two arguments. This functor can then be applied to generate
 * an animation step once the views are known.
 *
 * The usual example is a view controller container which manages the view controller's views it displays, but which
 * lets you customize the transition animations it uses to present them. By not requiring you to access a view
 * controller's view directly (which would lazily create it), the container can defer instantiation until it really
 * needs to instantiate it.
 *
 * Designated initializer: init
 */
@interface HLSTwoViewAnimationStepDefinition : NSObject {
@private
    HLSViewAnimationStep *m_firstViewAnimationStep;
    HLSViewAnimationStep *m_secondViewAnimationStep;
    NSTimeInterval m_duration;
    UIViewAnimationCurve m_curve;
}

/**
 * Create a definition with standard settings
 */
+ (HLSTwoViewAnimationStepDefinition *)twoViewAnimationStepDefinition;

/**
 * View animation steps for the involved views
 */
@property (nonatomic, retain) HLSViewAnimationStep *firstViewAnimationStep;
@property (nonatomic, retain) HLSViewAnimationStep *secondViewAnimationStep;

/**
 * Animation step properties
 */
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIViewAnimationCurve curve;

/**
 * Generate the animation step for the views given as parameter. If one of the views is nil, it will not be part of
 * the animation step
 */
- (HLSAnimationStep *)animationStepWithFirstView:(UIView *)firstViewOrNil
                                      secondView:(UIView *)secondViewOrNil;

@end
