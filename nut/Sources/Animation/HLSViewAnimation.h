//
//  HLSViewAnimation.h
//  nut
//
//  Created by Samuel DEFAGO on 8/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

// Forward declarations
@protocol HLSViewAnimationDelegate;

/**
 * Class for animating an existing view between HLSAnimationSteps. The animation can then easily be played backwards
 * by generating the corresponding reverse animation and playing it.
 *
 * Designated initializer: initWithView:animationSteps:
 */
@interface HLSViewAnimation : NSObject {
@private
    UIView *m_view;
    NSArray *m_animationSteps;              // contains HLSAnimationStep objects
    NSEnumerator *m_stepsEnumerator;        // enumerator over m_animationSteps
    NSString *m_tag;
    BOOL m_lockingUI;
    BOOL m_alwaysOnTop;
    id<HLSViewAnimationDelegate> m_delegate;
}

/**
 * Convenience constructor for creating an animation, specifying each of the steps
 */
+ (HLSViewAnimation *)viewAnimationWithView:(UIView *)view animationSteps:(NSArray *)animationSteps;

/**
 * Expect the view to animate, as well as the HLSAnimationStep sequence which must be applied to it
 */
- (id)initWithView:(UIView *)view animationSteps:(NSArray *)animationSteps;

/**
 * The view which gets animated
 */
@property (nonatomic, readonly, retain) UIView *view;

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

/**
 * Return the reverse animation for the specified view. All properties are set to their default values, they are not copied over from
 * the original animation. If the view parameter is set to nil, the view attached to the normal animation is used.
 * You may ask why we do not always use the view of the normal animation. The reason is that animations can be stored to be played
 * backwards at a later time. But memory warnings can release the original view between the time the original animation is created
 * and the time it is played backwards. In cases were you are sure that the view has not changed, you can safely use nil, otherwise
 * you should provide the view to animate again.
 */
- (HLSViewAnimation *)reverseViewAnimationWithView:(UIView *)viewOrNil;

@property (nonatomic, assign) id<HLSViewAnimationDelegate> delegate;

/**
 * Play the animation
 */
- (void)play;

@end

@protocol HLSViewAnimationDelegate <NSObject>
@optional

- (void)viewAnimationFinished:(HLSViewAnimation *)viewAnimation;
- (void)viewAnimationStepFinished:(HLSAnimationStep *)animationStep;

@end
