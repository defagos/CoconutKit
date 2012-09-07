//
//  HLSTransition.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/8/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSLayerAnimationStep.h"

// Default duration for a transition animation. This is a reserved value and corresponds to the intrinsic duration
// of an animation as defined by its implementation
extern const NSTimeInterval kAnimationTransitionDefaultDuration;

/**
 * Base class for transition animations involving two views (currently for use by containers). To define your
 * own transition animation, subclass HLSTransition and implement the
 *   -animationStepsWithAppearingView:disappearingView:frame:inView:
 * method to return the HLSAnimationSteps to be played when a view is brought to display, while another one is hidden
 * from view. You can also optionally implement the
 *   -reverseAnimationStepsWithAppearingView:disappearingView:frame:inView:
 * method (which by default returns nil) to define the animation to be used when performing the reverse transition.
 *
 * When implementing -animationStepsWithAppearingView:disappearingView:frame:inView: (and its reverse counterpart), keep 
 * in mind that:
 *   - appearingView, disappearingView and view must not be altered directly (in particular, you must not change their
 *     current bounds, transform or alpha directly). Those view parameters are only provided so that they can be supplied 
 *     to
 *       -[HLSAnimationStep addViewAnimationStep:forView]
 *     when building the animation steps. Only the animation is allowed to perform changes on those views
 *   - when implementing -animationStepsWithAppearingView:disappearingView:inView:, create your animation steps
 *     based on the folowing assumptions:
 *       - both the appearing and disappearing views fill the given frame entirely, i.e. they have
 *           bounds = {0.f, 0.f, CGRectGetWidth(frame), CGRectGetHeight(frame)}
 *         You can use this frame dimensions to translate the views outside the frame if your animation requires it
 *       - both views have alpha = 1.f
 *       - the layer properties are the default ones (e.g. rasterisation is disabled)
 *       - the appearing view is on top of the disappearing one, and both are displayed within view
 *     If you need your appearing view to start from a different initial state, use a first "setup" animation step
 *     with duration = 0. This way you can make it initially invisible or outside the frame. Conversely, you can
 *     add a final animation step to make the disappearing view invisible at the end of the animation (this might
 *     be required for animations moving the disappearing view outside the frame, so that it stays invisible when
 *     subsequent animations are played)
 *   - the duration of your animation steps is arbitrary. The sum of those durations defines the default duration
 *     of the resulting animation, which can be retrieved by calling the +defaultDuration method on a transition
 *     class. The duration of each animation step might be scaled depending on the total duration which is desired
 *     when the animation is actually played (refer to -[HLSAnimation animationWithDuration:] documentation for more
 *     information)
 *
 * For example, here is the implementation of a push from right animation (the usual UINavigationController animation)
 * with an intrinsic duration of 0.4:
 *
 *   + (NSArray *)animationStepsWithAppearingView:(UIView *)appearingView
 *                               disappearingView:(UIView *)disappearingView
 *                                          frame:(CGRect)frame
 *                                         inView:(UIView *)view
 *   {
 *       NSMutableArray *animationSteps = [NSMutableArray array];
 *
 *       // Setup step initially bringing the appearing view outside frame
 *       HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
 *       HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
 *       [viewAnimationStep11 translateByVectorWithX:CGRectGetWidth(frame) y:0.f z:0.f];
 *       [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
 *       animationStep1.duration = 0.;
 *       [animationSteps addObject:animationStep1];
 *
 *       // The push itself, moving both views to the left
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
 *       // Make the disappearing view invisible
 *       HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
 *       HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
 *       viewAnimationStep31.alphaVariation = -1.f;
 *       [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:disappearingView];
 *       animationStep3.duration = 0.;
 *       [animationSteps addObject:animationStep3];
 *
 *       return [NSArray arrayWithArray:animationSteps];
 *   }
 *
 * Have a look at the CoconutKit source code for more examples (HLSTransition.m). Several built-in transition classes are
 * provided by CoconutKit and should fulfill most of your needs.
 */
@interface HLSTransition : NSObject

/**
 * Return all class names corresponding to available transition animations (except HLSTransition itself). These include
 * custom transitions as well
 */
+ (NSArray *)availableTransitionNames;

/**
 * The method to be overridden by subclasses to return the transition animation steps which the animation is made of.
 * The returned array must only contain HLSAnimationStep objects
 *
 * The default implementation of this method returns nil, which corresponds to an empty animation (i.e. an animation
 * which does not alter any view)
 */
+ (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
                                            frame:(CGRect)frame
                                           inView:(UIView *)view;

/**
 * The method which subclasses can optionally override to define a custom reverse transition animation. The base
 * class implementation returns nil, in which case the reverse animation will be generated from the transition
 * animation using -[HLSAnimation reverseAnimation] (which is in general what you want)
 *
 * appearingView (respectively disappearing view) is the view which appears (respectively disappears) during the 
 * reverse transition
 */
+ (NSArray *)reverseLayerAnimationStepsWithAppearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView
                                                   frame:(CGRect)frame
                                                  inView:(UIView *)view;

/**
 * Return the intrinsic duration of a transition as given by its implementation
 */
+ (NSTimeInterval)defaultDuration;

/**
 * Return the transition animation for an appearing view and disappearing view pair (both of which must be subviews of
 * view)
 *
 * view must not be nil. Appearing view is allowed to be nil (in which case view won't be animated as well). This is 
 * a special use of this method when replaying an animation for a resurrected disappearing view, while appearingView 
 * (and therefore view) are already loaded and were already correctly animated to their final location. disappearingView
 * can be nil (this is the case when the first view in the container is being animated)
 *
 * Not meant to be subclassed
 */
+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                      inView:(UIView *)view
                                    duration:(NSTimeInterval)duration;

/**
 * Return the reverse transition animation to be played for an appearing view and disappearing view pair (both of which
 * must be subviews of view)
 *
 * appearingView (respectively disappearing view) is the view which appears (respectively disappears) during the
 * reverse transition. view must and disappearing view must not be nil. appearingView can be nil (this is the case
 * when the last view in the container is being removed)
 *
 * Not meant to be subclassed
 */
+ (HLSAnimation *)reverseAnimationWithAppearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView
                                             inView:(UIView *)view
                                           duration:(NSTimeInterval)duration;

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
@interface HLSTransitionCoverFromBottomPushToBack : HLSTransition
@end

/**
 * The new view covers the old one starting from the top (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromTopPushToBack : HLSTransition
@end

/**
 * The new view covers the old one starting from the left (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromLeftPushToBack : HLSTransition
@end

/**
 * The new view covers the old one starting from the right (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromRightPushToBack : HLSTransition
@end

/**
 * The new view covers the old one starting from the top left corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromTopLeftPushToBack : HLSTransition
@end

/**
 * The new view covers the old one starting from the top right corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromTopRightPushToBack : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom left corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromBottomLeftPushToBack : HLSTransition
@end

/**
 * The new view covers the old one starting from the bottom right corner (the old view is slightly pushed to the back)
 */
@interface HLSTransitionCoverFromBottomRightPushToBack : HLSTransition
@end

/**
 * The new view fades in, the old one does not change
 */
@interface HLSTransitionFadeIn : HLSTransition
@end

/**
 * The new view fades in, the old one is slightly pushed to the back
 */
@interface HLSTransitionFadeInPushToBack : HLSTransition
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
 * The old view is pushed from the bottom to the back by the new view
 */
@interface HLSTransitionPushToBackFromBottom : HLSTransition
@end

/**
 * The old view is pushed from the bottom to the back by the new view
 */
@interface HLSTransitionPushToBackFromTop : HLSTransition
@end

/**
 * The old view is pushed from the bottom to the back by the new view
 */
@interface HLSTransitionPushToBackFromLeft : HLSTransition
@end

/**
 * The old view is pushed from the bottom to the back by the new view
 */
@interface HLSTransitionPushToBackFromRight : HLSTransition
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
 * The new view emerges from the center of the frame while the old one is slightly pushed to the back
 */
@interface HLSTransitionEmergeFromCenterPushToBack : HLSTransition
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

@interface HLSTransitionRotateFromLeftCounterclockwise : HLSTransition
@end
