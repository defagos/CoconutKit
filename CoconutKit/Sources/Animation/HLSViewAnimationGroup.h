//
//  HLSViewAnimationGroup.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimation.h"

/**
 * A view animation group (HLSViewAnimationGroup) is the combination of several view animations (HLSViewAnimation) applied
 * to a set of views, and represent the collective set of changes applied to them during some time interval. An animation
 * (HLSAnimation) is then simply a collection of animation groups, either view-based (HLSViewAnimationGroup) or layer-based 
 * (HLSLayerAnimationGroup).
 *
 * Designated initializer: init (create an animation group with default settings)
 */
@interface HLSViewAnimationGroup : NSObject <NSCopying> {
@private
    NSMutableArray *m_viewKeys;                             // track in which order views were added to the animation group
    NSMutableDictionary *m_viewToViewAnimationMap;          // map a UIView object to the view animation to be applied on it
    NSTimeInterval m_duration;
    UIViewAnimationCurve m_curve;
    NSString *m_tag;
}

/**
 * Convenience constructor for an animation group with default settings and no view to animate
 */
+ (HLSViewAnimationGroup *)viewAnimationGroup;

/**
 * Setting a view animation for a view. Only one view animation can be defined at most for a view within an
 * animation group. The view is not retained. The order in which view animations are added is important
 * if your animation changes their z-ordering (refer to the HLSAnimation bringToFront property documentation
 * for more information)
 */
- (void)addViewAnimation:(HLSViewAnimation *)viewAnimation forView:(UIView *)view;

/**
 * All views changed by the animation group, returned in the order they were added to it
 */
- (NSArray *)views;

/**
 * Return the view animation defined for a view, or nil if none is found
 */
- (HLSViewAnimation *)viewAnimationForView:(UIView *)view;

/**
 * Animation group settings. Unlike UIView animation blocks, the duration of an animation group is never reduced
 * to 0 if no view is altered by the animation group
 */
@property (nonatomic, assign) NSTimeInterval duration;                      // default: 0.2
@property (nonatomic, assign) UIViewAnimationCurve curve;                   // default: UIViewAnimationCurveEaseInOut

/**
 * Optional tag to help identifying animation groups
 */
@property (nonatomic, retain) NSString *tag;

/**
 * Return the total alpha variation applied to a given view within an animation group. If the view does not belong to 
 * the views involved in the animation group, the method returns 0.f
 */
- (CGFloat)alphaVariationForView:(UIView *)view;

/**
 * Return the inverse animation group. If a tag has been defined, the reverse animation group is automatically assigned
 * the same tag, but with an additional "reverse_" prefix (if a tag has not been filled, the reverse tag is nil)
 */
- (HLSViewAnimationGroup *)reverseViewAnimationGroup;

@end
