//
//  HLSAnimation.h
//  nut
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"
#import "HLSTransitionStyle.h"

// Default duration for a transition.
extern const NSTimeInterval kAnimationTransitionDefaultDuration;

// Forward declarations
@protocol HLSAnimationDelegate;

/**
 * An animation (HLSAnimation) is a collection of animation steps (HLSAnimationStep), each representing collective changes
 * applied to sets of views during some time interval. An HLSAnimation object simply chains those changes together to play 
 * a complete animation. It also provides a convenient way to generate the corresponding reverse animation.
 *
 * Currently, there is sadly no way to stop an animation once it has begun. You must therefore be especially careful
 * if a delegate registered for an animation dies before the animation ends (do not forget to unregister it before).
 * Moreover, an animation does not retain the view it animates (see HLSViewAnimationStep documentation). You should
 * therefore ensure that an animation has ended before its views are destroyed. The easiest solution to both problems
 * is to lock the UI during the animation (lockingUI animation property). This prevents the user from doing anything
 * nasty (like navigating away).
 *
 * Animations can be played animated or not (yeah, that sounds weird, but I called it that way :-) ). When played
 * non-animated, an animation reaches its end state instantaneously. This is a perfect way to replay an animation
 * when rebuilding a view which has been unloaded (typically after a memory warning has been received). Animation
 * steps with duration equal to 0 also occur instantaneously.
 *
 * Delegate methods can be implemented by clients to catch animation events. An animated boolean value is received
 * in each of them, corresponding to how playAnimated: was called. For steps whose duration is 0, the boolean is
 * also YES if the animation was run using playAnimated:YES (even though the step was not animated, it is still
 * part of an animation which was played animated).
 *
 * An HLSAnimation applies transforms to views. It does not alter the frame, which means view inside it won't resize
 * (according to their autoresizing mask) but rather scale. If scaling is not what you want, you cannot use HLSAnimation
 * objects to manage your animation. In such cases, stick with usual UIView animation blocks for the moment.
 *
 * Designated initializer: initWithAnimationSteps:
 */
@interface HLSAnimation : NSObject {
@private
    NSArray *m_animationSteps;                              // contains HLSAnimationStep objects
    NSEnumerator *m_animationStepsEnumerator;               // enumerator over steps
    NSString *m_tag;
    NSDictionary *m_userInfo;
    BOOL m_lockingUI;
    BOOL m_bringToFront;
    BOOL m_firstStep;
    BOOL m_running;
    BOOL m_animated;
    id<HLSAnimationDelegate> m_delegate;
}

/**
 * Convenience constructor for creating an animation from HLSAnimationStep objects. Providing nil creates an empty
 * animation
 */
+ (HLSAnimation *)animationWithAnimationSteps:(NSArray *)animationSteps;
+ (HLSAnimation *)animationWithAnimationStep:(HLSAnimationStep *)animationStep;

/**
 * Creating an animation corresponding to some transition style. The disappearing views will be applied a corresponding
 * disapperance effect, the appearing views an appearance effect. The commonFrame parameter is the frame where all
 * animations take place.
 * The timing of the animation depends on the transition style
 */
+ (HLSAnimation *)animationForTransitionStyle:(HLSTransitionStyle)transitionStyle
                        withDisappearingViews:(NSArray *)disappearingViews
                               appearingViews:(NSArray *)appearingViews
                                  commonFrame:(CGRect)commonFrame;

/**
 * Same as the previous method, but with the default transition duration overridden. The total duration is distributed
 * among the animation steps so that the animation still looks the same, only slower / faster. Use the special value
 * kAnimationTransitionDefaultDuration as duration to get the default transition duration (same result as the method
 * above)
 */
+ (HLSAnimation *)animationForTransitionStyle:(HLSTransitionStyle)transitionStyle
                        withDisappearingViews:(NSArray *)disappearingViews
                               appearingViews:(NSArray *)appearingViews
                                  commonFrame:(CGRect)commonFrame
                                     duration:(NSTimeInterval)duration;

/**
 * Create a animation using HLSAnimationStep objects. Those steps will be chained together when the animation
 * is played. If nil is provided, an empty animation is created (such animations still fires animationWillStart: and 
 * animationDidStop: events when played)
 */
- (id)initWithAnimationSteps:(NSArray *)animationSteps;

/**
 * Tag which can optionally be used to help identifying an animation
 */
@property (nonatomic, retain) NSString *tag;

/**
 * Dictionary which can be used freely to convey additional information
 */
@property (nonatomic, retain) NSDictionary *userInfo;

/**
 * If set to YES, the user interface interaction is blocked during animation
 * Default is NO
 */
@property (nonatomic, assign) BOOL lockingUI;

/**
 * If set to YES, the views to animate are brought to the front during the animation (their original z-ordering is
 * not restored at the end). When an animation step is played with bringToFront set to YES, all involved views are 
 * brought to the front. The relative z-ordering between these views is given by the order in which they were 
 * registered with the animation step (first one added will be bottommost one)
 * Default is NO
 */
@property (nonatomic, assign) BOOL bringToFront;

/**
 * Return YES while the animation is running
 */
@property (nonatomic, readonly, assign, getter=isRunning) BOOL running;

@property (nonatomic, assign) id<HLSAnimationDelegate> delegate;

/**
 * Play the animation; there is no way to stop an animation once it has been started. If animated is set to NO,
 * the end state of the animation is reached instantly (i.e. the animation does take place synchronously at
 * the location of the call to playAnimated:)
 */
- (void)playAnimated:(BOOL)animated;

/**
 * Generate the reverse animation; all attributes are copied as is, except the tag which gets an additional
 * "reverse_" prefix, and the userInfo. You might of course change these attributes if needed
 */
- (HLSAnimation *)reverseAnimation;

@end

@protocol HLSAnimationDelegate <NSObject>
@optional

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated;
- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated;
- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated;

@end
