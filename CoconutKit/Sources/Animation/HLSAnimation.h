//
//  HLSAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSAnimationStep.h"

// Forward declarations
@protocol HLSAnimationDelegate;

/**
 * HLSAnimation is the simplest way to create and manage complex animations made of Core Animation-based layer
 * and / or UIView-based animations. Usually, creating complex animations made of several steps requires the
 * implementation of delegate methods, where animations are glued together. This makes your code ugly and difficult
 * to maintain. Moreover, it is painful to create a reverse animation (e.g. when toggling a menu), to pause
 * and cancel animations properly, or to play such animations instantaneously to restore some view state.
 *
 * To eliminate all those issues and provide a convenient way to create animations for your applications, HLSAnimations
 * are defined in a declarative way when instantiated, can be stored, replayed, reversed, cancelled, paused, played
 * instantaneously, slowed down in the iOS simulator, and more. Implementing and tweaking animations has never been 
 * easier and fun!
 *
 * An animation (HLSAnimation) is a collection of animation steps (HLSAnimationStep), each representing collective
 * changes applied to sets of views or layers during some time interval. An HLSAnimation object simply chains those 
 * changes together to play a complete animation. An HLSAnimation can be made of view-based animation steps 
 * (HLSViewAnimationStep) or layer-based animation steps (HLSLayerAnimationStep). You can mix both types of animation 
 * steps within the same animation, but you must not alter a view involved both in a view and in a layer animation steps, 
 * otherwise the behavior is undefined. In general, you should use HLSLayerAnimationSteps most of the time, except if 
 * you want to animate a view whose contents must resize appropriately (in which case you must use an HLSViewAnimationStep)
 *
 * Unlike UIView animation blocks, the animation delegate is not retained. This safety measure is not needed since
 * an HLSAnimation is automatically cancelled if it has a delegate and this delegate is deallocated. This eliminates
 * the need to cancel the animation manually when the delegate is destroyed (except, of course, if no delegate has
 * been defined)
 *
 * Animations can be played animated or not (yeah, that sounds weird, but I called it that way :-) ). When played
 * non-animated, an animation reaches its end state instantaneously.
 *
 * Running animations (this includes animations which have been paused) are automatically paused and resumed (if they
 * were running before) when the application enters, respectively exits background. Note that this mechanism works 
 * perfectly within the iOS simulator and on the device, though views will appear to "jump" on the device and on
 * iOS >= 6 simulators. This is not a bug and has no negative effect on the animation behavior (in particular, delegate 
 * methods are still called correctly), but is a consequence of the application screenshot which is displayed when 
 * the application exits background. The screenshot made when the application enters background namely reflects the
 * non-animated view / layer state, which explains why the views seem to jump.
 *
 * Delegate methods can be implemented by clients to catch animation events. An animated boolean value is received
 * in each of them, corresponding to how the play method was called. For steps whose duration is 0, the boolean is
 * also YES if the animation was run with animated = YES (even though the step was not actually animated, it is still
 * part of an animation which was played animated).
 */
@interface HLSAnimation : NSObject <NSCopying>

/**
 * Convenience constructor for creating an animation from HLSAnimationStep objects. Providing nil creates an empty
 * animation
 */
+ (instancetype)animationWithAnimationSteps:(NSArray *)animationSteps;
+ (instancetype)animationWithAnimationStep:(HLSAnimationStep *)animationStep;

/**
 * Create an animation using HLSAnimationStep objects. Those steps will be chained together when the animation
 * is played. If nil is provided, an empty animation is created (such animations still fire -animationWillStart:animated:
 * and -animationDidStop:animated: events when played)
 *
 * A deep copy of the animation steps is performed to prevent further changes once the steps have been assigned to an
 * animation
 */
- (instancetype)initWithAnimationSteps:(NSArray *)animationSteps NS_DESIGNATED_INITIALIZER;

/**
 * Tag which can optionally be used to help identifying an animation
 */
@property (nonatomic, strong) NSString *tag;

/**
 * Dictionary which can be freely used to convey additional information
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 * If set to YES, the user interface interaction is blocked during the time the animation is running (see
 * the running property documentation for more information about what "running" actually means)
 *
 * Default is NO
 */
@property (nonatomic, assign) BOOL lockingUI;

/**
 * The animation delegate. Note that the animation is automatically cancelled if a delegate has been set
 * and gets deallocated while the animation is runnning
 */
@property (nonatomic, weak) id<HLSAnimationDelegate> delegate;

/**
 * Play the animation. If animated is set to NO, the end state of the animation is reached instantaneously (i.e. the 
 * animation does take place synchronously at the location of the call to this method)
 */
- (void)playAnimated:(BOOL)animated;

/**
 * Play the animation with animated = YES, but after some delay given in seconds (invalid negative delays are fixed
 * to 0)
 */
- (void)playAfterDelay:(NSTimeInterval)delay;

/**
 * Play the animation some number of times (repeatCount must be different from 0). If repeatCount = NSUIntegerMax,
 * the animation is repeated forever (in such cases, animated must be YES)
 *
 * If animated is set to NO, the end state of the animation is reached instantaneously (i.e. the
 * animation does take place synchronously at the location of the call to this method)
 *
 * The -animationWillStart:animated: and -animationDidStop:animated delegate methods will be respectively
 * called once at the start and at the end of the whole animation
 */
- (void)playWithRepeatCount:(NSUInteger)repeatCount animated:(BOOL)animated;

/**
 * Play the animation some number of times (repeatCount must be different from 0) after some delay, with
 * animated = YES. If repeatCount = NSUIntegerMax, the animation is repeated forever
 *
 * The -animationWillStart:animated: and -animationDidStop:animated: delegate methods will be respectively
 * called once at the start and at the end of the whole animation
 */
- (void)playWithRepeatCount:(NSUInteger)repeatCount afterDelay:(NSTimeInterval)delay;

/**
 * Play part of an animation, starting at startTime (if 0, the animation starts at the beginning), with
 * animated = YES. The delegate events which would have been triggered prior to startTime are not received
 *
 * Remark: Core Animation steps support arbitrary start times. For UIView-based animation steps, the animation
 *         starts at the end of the step which startTime belongs to
 */
- (void)playWithStartTime:(NSTimeInterval)startTime;

/**
 * Play part of an animation, starting at startTime (if 0, the animation starts at the beginning) and repeating
 * it at the end, with animated = YES. If repeatCount = NSUIntegerMax, the animation is repeated forever. The 
 * delegate events which would have occurred prior to startTime are not received
 *
 * Remark: Core Animation steps support arbitrary start times. For UIView-based animation steps, the animation
 *         starts at the end of the step which startTime belongs to
 */
- (void)playWithStartTime:(NSTimeInterval)startTime repeatCount:(NSUInteger)repeatCount;

/**
 * Pause an animation being played animated (does nothing if the animation is not running or not animated). This 
 * method can also be used to pause an animation during its initial delay period
 */
- (void)pause;

/**
 * Resume a paused animation (does nothing if the animation has not been paused)
 */
- (void)resume;

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
 * Return the total duration of the animation. This does not include delays or repeat count multiplicators which
 * are not intrinsic properties of an animation, but rather specified when the animation is played
 */
@property (nonatomic, readonly, assign) NSTimeInterval duration;

/**
 * Return YES while the animation is running. An animation is considered running from the call to a play method until
 * right after -animationDidStop:animated: has been called. Note that this property also returns YES even when the 
 * animation has been paused or is being terminated / cancelled
 */
@property (nonatomic, readonly, assign, getter=isRunning) BOOL running;

/**
 * Return YES while the animation is being played. An animation is considered being played from the time a play
 * method has been called, and until right before -animationDidStop:animated: is called. Note that this property
 * also returns YES even when the animation has been paused or is being terminated / cancelled
 */
@property (nonatomic, readonly, assign, getter=isPlaying) BOOL playing;

/**
 * Return YES while the animation is started. An animation is considered started right after -animationWillStart:animated:
 * has been called, and until right before -animationDidStop:animated: is called. Note that this property also returns YES 
 * even if the animation was played with animated = NO, has been paused, terminated or cancelled
 */
@property (nonatomic, readonly, assign, getter=isStarted) BOOL started;

/**
 * Return YES iff the animation has been paused
 */
@property (nonatomic, readonly, assign, getter=isPaused) BOOL paused;

/**
 * Return YES iff the animation is being cancelled (i.e. from the time -cancel is called until after -animationDidStop:animated:
 * has been called)
 */
@property (nonatomic, readonly, assign, getter=isCancelling) BOOL cancelling;

/**
 * Return YES iff the animation is being terminated (i.e. from the time -terminate is called until after -animationDidStop:animated:
 * has been called)
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
 * animation steps get and additional "reverse_" prefix. If a tag has not been filled for the receiver, the
 * corresponding tag of the reverse animation is nil
 */
- (HLSAnimation *)reverseAnimation;

/**
 * Generate the corresponding loop animation by concatening self with its reverse animation. All attributes are
 * copied as is, except that all tags for the animation and animation steps get and additional "loop_" prefix
 * (reverse animation steps therefore begin with a "loop_reverse_" prefix). If a tag has not been filled for
 * the receiver, the corresponding tag of the reverse animation is nil
 */
- (HLSAnimation *)loopAnimation;

@end

@interface HLSAnimation (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

@protocol HLSAnimationDelegate <NSObject>
@optional

/**
 * Called right before the first animation step is executed, but after any delay which might have been set
 */
- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated;

/**
 * Called right after the last animation step has been executed. You can check -terminating or -cancelling
 * to find if the animation ended normally
 */
- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated;

/**
 * Called when a step has been executed. Since animation steps are deeply copied when assigned to an animation,
 * you must not use animation step pointers to identify animation steps when implementing this method. Use 
 * animation step tags instead
 */
- (void)animation:(HLSAnimation *)animation didFinishStep:(HLSAnimationStep *)animationStep animated:(BOOL)animated;

@end
