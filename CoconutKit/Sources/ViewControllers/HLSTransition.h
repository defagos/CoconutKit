//
//  HLSTransition.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/8/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

// Default duration for a transition animation. This is a reserved value and corresponds to the intrinsic duration
// of an animation as defined by its implementation
extern const NSTimeInterval kAnimationTransitionDefaultDuration;

/**
 * Common class for transition animations involving two views (currently for use by containers). To define your
 * own transition animations, subclass HLSTransition and implement the 
 *   -animationStepsWithAppearingView:disappearingView:inFrame:
 * method to return the HLSAnimationSteps to be played when a view is brought to display, while another one is hidden
 * from view.
 *
 * Implement your animations based on the following assumptions:
 *   - appearingView and disappearingView initially fill the given frame entirely (i.e. they have
 *     bounds = (0.f, 0.f, CGRectGetWidth(frame), CGRectGetHeight(frame)). This means that if you want the
 *     appearingView to start outside the frame you will need to use a first "setup" animation step bringing
 *     it into its initial position with a duration of 0
 *   - appearingView and disappearingView both have alpha = 1
 *   - appearingView is on top of disappearingView and both have the same superview
 *   - the duration of your steps is arbitrary. The sum of those durations defines the default duration of the 
 *     resulting animation. This might be scaled depending on the duration which is desired when the animation 
 *     is actually played (refer to -[HLSAnimation animationWithDuration:] documentation
 *
 * For example, here is the implementation of a push from right animation (the usual UINavigationController 
 * animation) with an intrinsic duration of 0.4:
 *
 *   + (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
 *                               disappearingView:(UIView *)disappearingView
 *                                        inFrame:(CGRect)frame
 *   {
 *       NSMutableArray *animationSteps = [NSMutableArray array];
 *
 *       // Setup step bringing the appearingView outside the frame
 *       HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
 *       HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
 *       [viewAnimationStep11 translateByVectorWithX:CGRectGetWidth(frame) y:0.f z:0.f];
 *       [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
 *       animationStep1.duration = 0.;
 *       [animationSteps addObject:animationStep1];
 *
 *       // The push itself, moving the two views to the left
 *       HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
 *       HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
 *       [viewAnimationStep21 translateByVectorWithX:-CGRectGetWidth(frame) y:0.f z:0.f];
 *       [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
 *       HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
 *       [viewAnimationStep22 translateByVectorWithX:-CGRectGetWidth(frame) y:0.f z:0.f];
 *       [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
 *       animationStep2.duration = 0.4;
 *       [animationSteps addObject:animationStep2];
 *
 *       return [NSArray arrayWithArray:animationSteps];
 *   }
 *
 * Have a look at the CoconutKit source code for more examples (HLSTransition.m). Several built-in transition
 * classes are defined below
 */
@interface HLSTransition : NSObject

/**
 * Return an array of string identifiers for the available transitions. These include any custom transitions
 * as well
 */
+ (NSArray *)availableTransitionNames;

/**
 * The method to be overridden by subclasses to return the transition animation steps for the animation class.
 * The returned array must only contain HLSAnimationStep objects
 *
 * The default implementation of this method returns an empty animation (which do not alter any of the
 * views)
 */
+ (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame;

@end

/**
 *  No transition
 */
@interface HLSTransitionNone : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom
 */
@interface HLSTransitionCoverFromBottom : HLSTransition
@end

/**
 * The new view covers the old one starting from the top
 */
@interface HLSTransitionCoverFromTop : HLSTransition
@end

/**
 * The new view covers the old one starting from the left
 */
@interface HLSTransitionCoverFromLeft : HLSTransition
@end

/**
 * The new view covers the old one starting from the right
 */
@interface HLSTransitionCoverFromRight : HLSTransition
@end

/**
 * The new view covers the old one starting from the top left corner
 */
@interface HLSTransitionCoverFromTopLeft : HLSTransition
@end

/**
 * The new view covers the old one starting from the top right corner
 */
@interface HLSTransitionCoverFromTopRight : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom left corner
 */
@interface HLSTransitionCoverFromBottomLeft : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom right corner
 */
@interface HLSTransitionCoverFromBottomRight : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromBottom2 : HLSTransition
@end

/**
 * The new view covers the old one starting from the top (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromTop2 : HLSTransition
@end

/**
 * The new view covers the old one starting from the left (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromLeft2 : HLSTransition
@end

/**
 * The new view covers the old one starting from the right (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromRight2 : HLSTransition
@end

/**
 * The new view covers the old one starting from the top left corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromTopLeft2 : HLSTransition
@end

/**
 * The new view covers the old one starting from the top right corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromTopRight2 : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom left corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromBottomLeft2 : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom right corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromBottomRight2 : HLSTransition
@end

/**
 * The new view fades in, the old one does not change
 */
@interface HLSTransitionFadeIn : HLSTransition
@end

/**
 * The new view fades in, the old one is slightly pushed to the back
 */
@interface HLSTransitionFadeIn2 : HLSTransition
@end

/**
 * The old view fades out and disappears as the new one fades in
 */
@interface HLSTransitionCrossDissolve : HLSTransition
@end

/**
 * The new view pushes up the old one (which disappears)
 */
@interface HLSTransitionPushFromBottom : HLSTransition
@end

/**
 * The new view pushes down the old one (which disappears)
 */
@interface HLSTransitionPushFromTop : HLSTransition
@end

/**
 * The new view pushes the old one to the left (which disappears)
 */
@interface HLSTransitionPushFromLeft : HLSTransition
@end

/**
 * The new view pushes the old one to the right (which disappears)
 */
@interface HLSTransitionPushFromRight : HLSTransition
@end

/**
 * The old view is pushed from the bottom, then the new one appears with a fade in animation
 */
@interface HLSTransitionPushFromBottomFadeIn : HLSTransition
@end

/**
 * The old view is pushed from the top, then the new one appears with a fade in animation
 */
@interface HLSTransitionPushFromTopFadeIn : HLSTransition
@end

/**
 * The old view is pushed from the left, then the new one appears with a fade in animation
 */
@interface HLSTransitionPushFromLeftFadeIn : HLSTransition
@end

/**
 * The old view is pushed from the right, then the new one appears with a fade in animation
 */
@interface HLSTransitionPushFromRightFadeIn : HLSTransition
@end

/**
 * The old view is slightly pushed to the back, pushed from the bottom by the new one, which is then brought to the front
 */
@interface HLSTransitionFlowFromBottom : HLSTransition
@end

/**
 * The old view is slightly pushed to the back, pushed from the top by the new one, which is then brought to the front
 */
@interface HLSTransitionFlowFromTop : HLSTransition
@end

/**
 * The old view is slightly pushed to the back, pushed from the left by the new one, which is then brought to the front
 */
@interface HLSTransitionFlowFromLeft : HLSTransition
@end

/**
 * The old view is slightly pushed to the back, pushed from the right by the new one, which is then brought to the front
 */
@interface HLSTransitionFlowFromRight : HLSTransition
@end

/**
 * The new view emerges from the center of the frame, the old one is left as is
 */
@interface HLSTransitionEmergeFromCenter : HLSTransition
@end

/**
 * The two views are flipped vertically
 */
@interface HLSTransitionFlipVertical : HLSTransition
@end

/**
 * The two views are flipped horizontally
 */
@interface HLSTransitionFlipHorizontal : HLSTransition
@end
