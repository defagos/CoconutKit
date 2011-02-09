//
//  HLSAnimation.h
//  nut
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

// Forward declarations
@protocol HLSAnimationDelegate;

/**
 * An animation (HLSAnimation) is a collection of animation steps (HLSAnimationStep), each representing collective changes
 * applied to sets of views during some time interval. An HLSAnimation object simply chains those changes together to play 
 * a complete animation. It also provide a convenient way to generate the corresponding reverse animation.
 *
 * Currently, there is sadly no way to stop an animation once it has begun. You must therefore be especially careful
 * if a delegate registered for an animation dies before the animation ends (do not forget to unregister it before).
 * Moreover, an animation does not retain the view it animates (see HLSViewAnimationStep documentation). You should
 * therefore ensure that an animation has ended before its views are destroyed.
 *
 * Designated initializer: initWithAnimationSteps:
 */
@interface HLSAnimation : NSObject {
@private
    NSArray *m_animationSteps;                              // contains HLSAnimationStep objects
    NSEnumerator *m_animationStepsEnumerator;               // enumerator over steps
    NSString *m_tag;
    BOOL m_lockingUI;
    BOOL m_bringToFront;
    BOOL m_alwaysOnTop;
    id<HLSAnimationDelegate> m_delegate;
}

/**
 * Convenience constructor for creating an animation from HLSAnimationStep objects
 */
+ (HLSAnimation *)animationWithAnimationSteps:(NSArray *)animationSteps;

/**
 * Create a animation using HLSAnimationStep objects. Those steps will be chained together when the animation
 * is played
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
 * If set to YES, the views to animate are brought to the front during the animation (their original z-ordering is
 * not restored at the end). When an animation step is played with bringToFront set to YES, all involved views are 
 * brought to the front. The relative z-ordering between these views is given by the order in which they were 
 * registered with the animation step (first one added will be bottommost one)
 * Default is NO
 */
@property (nonatomic, assign) BOOL bringToFront;

@property (nonatomic, assign) id<HLSAnimationDelegate> delegate;

/**
 * Play the animation; there is no way to stop an animation once it has been started
 */
- (void)play;

/**
 * Generate the reverse animation; all attributes are copied as is, except the tag which gets an additional
 * "reverse_" prefix. You might of course change these attributes if needed
 */
- (HLSAnimation *)reverseAnimation;

@end

@protocol HLSAnimationDelegate <NSObject>
@optional

- (void)animationFinished:(HLSAnimation *)animation;
- (void)animationStepFinished:(HLSAnimationStep *)animationStep;

@end
