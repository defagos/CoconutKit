//
//  HLSLayerAnimationGroup.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLayerAnimation.h"

/**
 * A layer animation group (HLSLayerAnimationGroup) is the combination of several layer animations (HLSLayerAnimation) applied
 * to a set of layers, and represent the collective set of changes applied to them during some time interval. An animation
 * (HLSAnimation) is then simply a collection of animation groups, either view-based (HLSViewAnimationGroup) or layer-based
 * (HLSLayerAnimationGroup).
 *
 * Designated initializer: init (create an animation group with default settings)
 */
@interface HLSLayerAnimationGroup : NSObject <NSCopying> {
@private
    NSMutableArray *m_layerKeys;                            // track in which order layers were added to the animation group
    NSMutableDictionary *m_layerToLayerAnimationMap;        // map a CALayer object to the layer animation to be applied on it
    CFTimeInterval m_duration;
    CAMediaTimingFunction *m_timingFunction;
    NSString *m_tag;
}

/**
 * Convenience constructor for an animation group with default settings and no layer to animate
 */
+ (HLSLayerAnimationGroup *)layerAnimationGroup;

/**
 * Setting a layer animation for a layer. Only one layer animation can be defined at most for a layer within an
 * animation group. The layer is not retained
 */
- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forLayer:(CALayer *)layer;

/**
 * Convenience method to add a layer animation for a view layer
 */
- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forView:(UIView *)view;

/**
 * All layers changed by the animation group, returned in the order they were added to it
 */
- (NSArray *)layers;

/**
 * Return the layer animation defined for a layer, or nil if none is found
 */
- (HLSLayerAnimation *)layerAnimationForLayer:(CALayer *)layer;

/**
 * Animation group settings. Unlike UIView animation blocks, the duration of an animation group is never reduced
 * to 0 if no layer is altered by the animation group
 */
// TODO: See if the same holds for CALayer and update the documentation accordingly
@property (nonatomic, assign) CFTimeInterval duration;                      // default: 0.2
@property (nonatomic, retain) CAMediaTimingFunction *timingFunction;        // default: kCAMediaTimingFunctionEaseInEaseOut

/**
 * Optional tag to help identifying animation groups
 */
@property (nonatomic, retain) NSString *tag;

/**
 * Return the total opacity variation applied to a given layer within an animation group. If the layer does not belong to
 * the layers involved in the animation group, the method returns 0.f
 */
- (CGFloat)opacityVariationForLayer:(CALayer *)layer;

/**
 * Return the inverse animation group. If a tag has been defined, the reverse animation group is automatically assigned
 * the same tag, but with an additional "reverse_" prefix (if a tag has not been filled, the reverse tag is nil)
 */
- (HLSLayerAnimationGroup *)reverseLayerAnimationGroup;

@end
