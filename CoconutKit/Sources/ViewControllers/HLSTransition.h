//
//  HLSTransition.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/8/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLayerAnimationStep.h"

// Default duration for a transition animation. This is a reserved value and corresponds to the intrinsic duration
// of an animation as defined by its implementation
extern const NSTimeInterval kAnimationTransitionDefaultDuration;

/**
 * Base class for transition animations involving two views (currently for use by containers). To define your
 * own transition animation, subclass HLSTransition and implement the
 *   -layerAnimationStepsWithAppearingView:disappearingView:inFrame:
 * method to return the HLSLayerAnimationSteps to be played when a view is brought to display, while another one
 * is hidden from view. Only layer animations are supported. You can also optionally implement the
 *   -reverseLayerAnimationStepsWithAppearingView:disappearingView:inFrame:
 * method (which by default returns nil) to define the animation to be used when performing the reverse transition.
 *
 * When implementing -layerAnimationStepsWithAppearingView:disappearingView:inFrame:, keep in mind that:
 *   - appearingView and disappearingView must not be used directly (in particular, you must not access their current
 *     frame or alpha). Those view parameters are only provided so that they can be supplied to
 *       -[HLSLayerAnimationStep addLayerAnimation:forView:]
 *     when building the animation steps
 *   - when implementing -layerAnimationStepsWithAppearingView:disappearingView:inFrame:, create your animation steps
 *     based on the folowing assumptions (regardless of the current appearingView and disappearingView properties,
 *     which you should ignore, as said above):
 *       - both the appearing and disappearing views fill the given frame entirely, i.e. they have
 *           bounds = {0.f, 0.f, CGRectGetWidth(frame), CGRectGetHeight(frame)}
 *       - both views have alpha = 1.f
 *       - the appearing view is on top of the disappearing one
 *     If you need your appearing view to start from a different initial state, use a first "setup" animation step
 *     with duration = 0. This way you can make it initially invisible or outside the frame. Conversely, you can
 *     add a final animation step to make the disappearing view invisible at the end of the animation (this might
 *     be required for animations moving the disappearing view outside the frame, so that it stays invisible when
 *     subsequent animations are played)
 *   - the duration of your animation steps is arbitrary. The sum of those durations defines the default duration
 *     of the resulting animation, which can be retrieved by calling the +defaultDuration on a transition class.
 *     The duration of each animation step might be scaled depending on the total duration which is desired when
 *     the animation is actually played (refer to -[HLSAnimation animationWithDuration:] documentation for more
 *     information)
 *
 * For example, here is the implementation of a push from right animation (the usual UINavigationController animation)
 * with an intrinsic duration of 0.4:
 *
 *   + (NSArray *)layerAnimationStepsWithAppearingView:(UIView *)appearingView
 *                                    disappearingView:(UIView *)disappearingView
 *                                             inFrame:(CGRect)frame
 *   {
 *       NSMutableArray *animationSteps = [NSMutableArray array];
 *
 *       // Setup step initially bringing the appearing view outside the frame
 *       HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
 *       HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
 *       [layerAnimation11 translateByVectorWithX:CGRectGetWidth(frame) y:0.f z:0.f];
 *       [animationStep1 addLayerAnimation:layerAnimation11 forView:appearingView];
 *       animationStep1.duration = 0.;
 *       [animationSteps addObject:animationStep1];
 *
 *       // The push itself, moving both views to the left
 *       HLSLayerAnimationStep *animationStep2 = [HLSLayerAnimationStep animationStep];
 *       HLSLayerAnimation *layerAnimation21 = [HLSLayerAnimation animation];
 *       [layerAnimation21 translateByVectorWithX:-CGRectGetWidth(frame) y:0.f z:0.f];
 *       [animationStep2 addLayerAnimation:layerAnimation21 forView:disappearingView];
 *       HLSLayerAnimation *layerAnimation22 = [HLSLayerAnimation animation];
 *       [layerAnimation22 translateByVectorWithX:-CGRectGetWidth(frame) y:0.f z:0.f];
 *       [animationStep2 addLayerAnimation:layerAnimation22 forView:appearingView];
 *       animationStep2.duration = 0.4;
 *       [animationSteps addObject:animationStep2];
 *
 *       // Make the disappearing view invisible
 *       HLSLayerAnimationStep *animationStep3 = [HLSLayerAnimationStep animationStep];
 *       HLSLayerAnimation *layerAnimation31 = [HLSLayerAnimation animation];
 *       layerAnimation31.opacityVariation = -1.f;
 *       [animationStep3 addLayerAnimation:layerAnimation31 forView:disappearingView];
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
                                          inFrame:(CGRect)frame;

/**
 * The method which subclasses can optionally override to define a custom reverse transition animation. The base
 * class implementation returns nil, in which case the reverse animation will be generated from the transition
 * animation using -[HLSAnimation reverseAnimation] (which is in general what you want)
 */
+ (NSArray *)reverseLayerAnimationStepsWithAppearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView
                                                 inFrame:(CGRect)frame;

/**
 * Return the intrinsic duration of a transition as given by its implementation
 */
+ (NSTimeInterval)defaultDuration;

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
