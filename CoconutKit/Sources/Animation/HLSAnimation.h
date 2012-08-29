//
//  HLSAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

// Forward declarations
@class HLSZeroingWeakRef;
@protocol HLSAnimationDelegate;

/**
 * An animation (HLSAnimation) is a collection of animation steps (HLSAnimationStep), each representing collective changes
 * applied to sets of views or layers during some time interval. An HLSAnimation object simply chains those changes together 
 * to play a complete animation. It also provides a convenient way to generate the corresponding reverse animation.
 *
 * An HLSAnimation can be made of view-based animation steps (HLSViewAnimationStep) or layer-based animation steps
 * (HLSLayerAnimationStep). You can mix both types of animation steps within the same animation, but you must
 * not alter a view both in a view and in a layer animation step, otherwise the behavior is undefined. In general,
 * you should use HLSLayerAnimationSteps, except if you want to animate a view whose contents must resize appropriately
 * (in which case use an HLSViewAnimationStep)
 *
 * Unlike UIView animation blocks, the animation delegate is not retained. This safety measure is not needed since
 * an HLSAnimation is automatically cancelled if it has a delegate and the delegate is deallocated. This eliminates
 * the need to cancel the animation manually when the delegate is destroyed (except, of course, if no delegate has
 * been defined)
 *
 * Animations can be played animated or not (yeah, that sounds weird, but I called it that way :-) ). When played
 * non-animated, an animation reaches its end state instantaneously. This is a perfect way to replay an animation
 * when rebuilding a view which has been unloaded (typically after a view controller received a memory warning 
 * notification).
 *
 * HLSAnimation does not provide any safety measures against non-integral frames (which ultimately lead to blurry
 * views). The reason is that fixing such issues in an automatic way would make reverse animations difficult to
 * generate, since HLSAnimation does not store any information about the original state of the views which are 
 * animated.
 *
 * Delegate methods can be implemented by clients to catch animation events. An animated boolean value is received
 * in each of them, corresponding to how playAnimated: was called. For steps whose duration is 0, the boolean is
 * also YES if the animation was run with animated = YES (even though the step was not animated, it is still
 * part of an animation which was played animated).
 *
 * Designated initializer: initWithAnimationSteps:
 */
@interface HLSAnimation : NSObject <NSCopying> {
@private
    NSArray *m_animationSteps;                                     // contains HLSAnimationStep objects
    NSEnumerator *m_animationStepsEnumerator;                      // enumerator over steps
    HLSAnimationStep *m_currentAnimationStep;
    NSString *m_tag;
    NSDictionary *m_userInfo;
    UIView *m_dummyView;
    BOOL m_lockingUI;
    NSTimeInterval m_delay;
    BOOL m_animated;
    BOOL m_running;
    BOOL m_cancelling;
    BOOL m_terminating;
    HLSZeroingWeakRef *m_delegateZeroingWeakRef;
}

/**
 * Convenience constructor for creating an animation from HLSAnimationStep objects. Providing nil creates an empty
 * animation
 */
+ (HLSAnimation *)animationWithAnimationSteps:(NSArray *)animationSteps;
+ (HLSAnimation *)animationWithAnimationStep:(HLSAnimationStep *)animationStep;

/**
 * Create a animation using HLSAnimationStep objects. Those steps will be chained together when the animation
 * is played. If nil is provided, an empty animation is created (such animations still fire animationWillStart: and 
 * animationDidStop: events when played)
 */
- (id)initWithAnimationSteps:(NSArray *)animationSteps;

/**
 * The animation steps the animation is made of
 */
@property (nonatomic, readonly, retain) NSArray *animationSteps;

/**
 * Tag which can optionally be used to help identifying an animation
 */
@property (nonatomic, retain) NSString *tag;

/**
 * Dictionary which can be freely used to convey additional information
 */
@property (nonatomic, retain) NSDictionary *userInfo;

/**
 * If set to YES, the user interface interaction is blocked during the time the animation is running (see
 * the -running documentation for more information about what this means)
 *
 * Default is NO
 */
@property (nonatomic, assign) BOOL lockingUI;

/**
 * Return YES while the animation is running. An animation is running from the call to a play method until
 * it ends, and is considered running from the start even if a delay has been set
 */
@property (nonatomic, readonly, assign, getter=isRunning) BOOL running;

/**
 * The animation delegate. Note that the animation is automatically cancelled if the delegate is deallocated while
 * the animation is runnning
 */
@property (nonatomic, assign) id<HLSAnimationDelegate> delegate;

/**
 * Return the total duration of the animation
 */
- (NSTimeInterval)duration;

/**
 * Play the animation. If animated is set to NO, the end state of the animation is reached instantaneously (i.e. the 
 * animation does take place synchronously at the location of the call to -playAnimated:)
 */
- (void)playAnimated:(BOOL)animated;

/**
 * Play the animation with animated = YES, but after some delay given in seconds (invalid negative delays are fixed
 * to 0)
 */
- (void)playAfterDelay:(NSTimeInterval)delay;

/**
 * Cancel the animation. The animation immediately reaches its end state. The delegate does not receive subsequent
 * events
 */
- (void)cancel;

/**
 * Terminate the animation. The animation immediately reaches its end state. The delegate still receives all
 * subsequent events, but with animated = NO
 */
- (void)terminate;

/**
 * Return YES iff the animation is being cancelled
 */
@property (nonatomic, readonly, assign, getter=isCancelling) BOOL cancelling;

/**
 * Return YES iff the animation is being terminated
 */
@property (nonatomic, readonly, assign, getter=isTerminating) BOOL terminating;

/**
 * Generate a copy of the animation, but overrides its total duration with a new one. The original appearance of
 * the animation is preserved (it is only faster or slower depending on the new duration). If an invalid negative
 * duration is provided, the method returns nil
 */
- (HLSAnimation *)animationWithDuration:(NSTimeInterval)duration;

/**
 * Generate the reverse animation; all attributes are copied as is, except that all tags for the animation and
 * animation steps get and additional "reverse_" prefix (if a tag has not been filled, the reverse tag is nil). 
 * The userInfo dictionary is not copied
 */
- (HLSAnimation *)reverseAnimation;

@end

@protocol HLSAnimationDelegate <NSObject>
@optional

/**
 * Called right before the first animation step is executed, after any delay which might have been set
 */
- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated;

/**
 * Called right after the last animation step has been executed
 */
- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated;

/**
 * Called when a step has been executed
 */
- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated;

@end
