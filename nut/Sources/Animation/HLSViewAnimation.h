//
//  HLSViewAnimation.h
//  nut
//
//  Created by Samuel DEFAGO on 8/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

// TODO: Add a repeat count (& forever). Document the fact that there is (sadly) no way to cancel an animation, so beware
// of registered delegates which could die before an animation notifying them is over! 

// Forward declarations
@protocol HLSViewAnimationDelegate;

/**
 * Class for animating an existing view using a given animation sequence.
 *
 * Designated initializer: initWithView:animationSequence:
 */
@interface HLSViewAnimation : NSObject {
@private
    UIView *m_view;                                         // points to the animated view during an animation, nil otherwise
    NSArray *m_animationSteps;                              // contains HLSAnimationStep objects
    NSEnumerator *m_stepsEnumerator;                        // enumerator over sequence steps
    NSString *m_tag;
    BOOL m_lockingUI;
    BOOL m_alwaysOnTop;
    id<HLSViewAnimationDelegate> m_delegate;
}

/**
 * Convenience constructor for creating an animation from HLSAnimationStep objects
 */
+ (HLSViewAnimation *)viewAnimationWithAnimationSteps:(NSArray *)animationSteps;

/**
 * Expect the view to animate, as well as the array of HLSAnimationStep objects which must be applied to it when the animation is played
 */
- (id)initWithAnimationSteps:(NSArray *)animationSteps;

/**
 * Tag which can optionally be used to help identifying an animation
 */
@property (nonatomic, retain) NSString *tag;

/**
 * If set to YES, the user interface interaction is blocked during animation
 * Default is NO
 */
@property (nonatomic, assign) BOOL lockingUI;

/**
 * If set to YES, the view to animate is brought to the front at the beginning of the animation, otherwise its
 * z-order is not altered
 * Default is NO
 */
@property (nonatomic, assign) BOOL bringToFront;

@property (nonatomic, assign) id<HLSViewAnimationDelegate> delegate;

/**
 * Apply the animation on the specified view; an animation cannot be played if already running (even on another view)
 */
- (void)animateView:(UIView *)view;

/**
 * Generate the reverse animation; all attributes are copied as is, except tag which gets an additional
 * "reverse_" prefix. You might of course change these attributes if needed
 */
- (HLSViewAnimation *)reverseViewAnimation;

@end

@protocol HLSViewAnimationDelegate <NSObject>
@optional

- (void)viewAnimationFinished:(HLSViewAnimation *)viewAnimation;
- (void)viewAnimationStepFinished:(HLSAnimationStep *)animationStep;

@end
