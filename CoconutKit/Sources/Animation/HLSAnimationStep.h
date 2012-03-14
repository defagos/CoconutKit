//
//  HLSAnimationStep.h
//  CoconutKit
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
 * Setting a view animation step for a view. Only one animation step can be defined at most for a view during
 * an animation step. The view is not retained. The order in which view animation steps are added is important
 * if your animation changes their z-ordering (refer to the HLSAnimation bringToFront property documentation)
 */
- (void)addViewAnimationStep:(HLSViewAnimationStep *)viewAnimationStep forView:(UIView *)view;

/**
 * All views changed by the animation step, returned in the order they were added to the animation step object
 */
- (NSArray *)views;

/**
 * Return the view animation step defined for a view, or nil if none is found
 */
- (HLSViewAnimationStep *)viewAnimationStepForView:(UIView *)view;

/**
 * Animation step settings. Unlike UIView animation blocks, the duration of an animation step is never reduced
 * to 0 if no view is altered by the animation block
 */
@property (nonatomic, assign) NSTimeInterval duration;                      // default: 0.2
@property (nonatomic, assign) UIViewAnimationCurve curve;                   // default: UIViewAnimationCurveEaseInOut

/**
 * Optional tag to help identifying animation steps
 */
@property (nonatomic, retain) NSString *tag;

@end
