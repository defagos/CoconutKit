//
//  HLSAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"
#import "HLSTransitionStyle.h"

// Forward declarations
@class HLSAnimationStep;
@class HLSZeroingWeakRef;
@protocol HLSAnimationDelegate;

/**
 * An animation (HLSAnimation) is a collection of animation steps (HLSAnimationStep), each representing collective changes
 * applied to sets of views during some time interval. An HLSAnimation object simply chains those changes together to play 
 * a complete animation. It also provides a convenient way to generate the corresponding reverse animation.
 *
 * Unlike UIView animation blocks, the animation delegate is not retained. This safety measure is not needed since
 * an HLSAnimation is automatically cancelled if it has a delegate and the delegate is deallocated. This eliminates
 * the need to cancel the animation manually when the delegate is destroyed.
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
 * If the resizeViews property is set to YES, an animation alters the frames of the involved views. If this property 
 * is set to NO, the animation only alters the view transforms, which means the views will be stretched. View resizing 
 * is currently quite experimental and is therefore disabled by default.
 *
 * When resizeViews is set to YES, only translation and scale transforms can be applied since the frame is involved.
 * Other transforms will be ignored, and a warning message will be logged
 *
 * Designated initializer: initWithAnimationSteps:
 */
@interface HLSAnimation : NSObject {
@private
    NSArray *m_animationSteps;                              // contains HLSAnimationStep objects
    NSEnumerator *m_animationStepsEnumerator;               // enumerator over steps
    HLSAnimationStep *m_currentAnimationStep;
    NSString *m_tag;
    NSDictionary *m_userInfo;
    UIView *m_dummyView;
    BOOL m_resizeViews;
    BOOL m_lockingUI;
    BOOL m_bringToFront;
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
 * is played. If nil is provided, an empty animation is created (such animations still fires animationWillStart: and 
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
 * Dictionary which can be used freely to convey additional information
 */
@property (nonatomic, retain) NSDictionary *userInfo;

/**
 * If set to YES (experimental), the views and their subviews will be resized according to their autoresizing mask during 
 * the animation. Otherwise views will only be scaled.
 * Default is NO
 */
@property (nonatomic, assign, getter=isResizeViews) BOOL resizeViews;

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

/**
 * The animation delegate. Note that the animation is automatically cancelled if the delegate is deallocated while
 * the animation is runnning
 */
@property (nonatomic, assign) id<HLSAnimationDelegate> delegate;

/**
 * Play the animation. If animated is set to NO, the end state of the animation is reached instantly (i.e. the animation 
 * does take place synchronously at the location of the call to playAnimated:)
 */
- (void)playAnimated:(BOOL)animated;

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
 * Generate the reverse animation; all attributes are copied as is, except that all tags for the animation and
 * the animation steps get and additional "reverse_" prefix (if a tag is not filled, the reverse tag is nil). 
 Moreover, the userInfo is not copied
 */
- (HLSAnimation *)reverseAnimation;

@end

@protocol HLSAnimationDelegate <NSObject>
@optional

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated;
- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated;
- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated;

@end
