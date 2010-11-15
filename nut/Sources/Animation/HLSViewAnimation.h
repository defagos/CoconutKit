//
//  HLSViewAnimation.h
//  nut
//
//  Created by Samuel DEFAGO on 8/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationFrame.h"

// Forward declarations
@protocol HLSViewAnimationDelegate;

/**
 * Class for animating an existing view between HLSAnimationFrames. The animation can also be played backwards.
 *
 * Designated initializer: initWithView:animationFrames:
 */
@interface HLSViewAnimation : NSObject {
@private
    UIView *m_view;
    NSArray *m_animationFrames;             // contains HLSAnimationFrame objects
    NSString *m_id;
    NSTimeInterval m_duration;
    NSTimeInterval m_delay;
    UIViewAnimationCurve m_curve;
    NSArray *m_parentZOrderedViews;
    id<HLSViewAnimationDelegate> m_delegate;
}

- (id)initWithView:(UIView *)view animationFrames:(NSArray *)animationFrames;

@property (nonatomic, readonly, retain) UIView *view;

// An id can optionally be assigned to an animation for identifying it if needed
@property (nonatomic, retain) NSString *id;

/**
 * Animation settings. If not set, default values are used
 */
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) UIViewAnimationCurve curve;

@property (nonatomic, assign) id<HLSViewAnimationDelegate> delegate;

/**
 * Play the animation
 */
- (void)animate;
- (void)animateReverse;

@end

@protocol HLSViewAnimationDelegate <NSObject>

- (void)viewAnimationFinished:(HLSViewAnimation *)viewAnimation;
- (void)viewAnimationFinishedReverse:(HLSViewAnimation *)viewAnimation;

@end
