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
 *
 * Designated initializer: initWithView:animationSteps:
 */
@interface HLSViewAnimation : NSObject {
@private
    UIView *m_view;
    CGFloat m_alpha;                        // calculate the alpha value obtained by accumulating deltas during steps
    NSArray *m_animationSteps;              // contains HLSAnimationStep objects
    NSEnumerator *m_stepsEnumerator;        // enumerator over m_animationSteps
    NSString *m_tag;
    BOOL m_lockingUI;
    BOOL m_alwaysOnTop;
    NSArray *m_parentZOrderedViews;
    id<HLSViewAnimationDelegate> m_delegate;
}

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
 * If this property is set to YES, then the view will be brought on top at the beginning of the forward animation to
 * avoid being hidden or overlapping with other views. The new view depth is kept at the end of the forward animation, 
 * the original one is only restored at the end of the backward animation. If this property is set to NO, the original
 * depth is kept during both animations
 * Default value is NO.
 */
@property (nonatomic, assign) BOOL alwaysOnTop;

@property (nonatomic, assign) id<HLSViewAnimationDelegate> delegate;

/**
 * Play the animation
 */
- (void)animate;

/**
 * Play the animation reverse; playing the reverse animation before the normal one leads to undefined behavior
 */
- (void)animateReverse;

@end

@protocol HLSViewAnimationDelegate <NSObject>
@optional

- (void)viewAnimationFinished:(HLSViewAnimation *)viewAnimation;
- (void)viewAnimationFinishedReverse:(HLSViewAnimation *)viewAnimation;

@end
