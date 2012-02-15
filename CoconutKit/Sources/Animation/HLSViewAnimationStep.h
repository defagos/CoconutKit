//
//  HLSViewAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view animation step describes the changes applied to a view during an animation step (HLSAnimationStep). An 
 * animation step is the combination of several view animation steps (HLSViewAnimationStep) applied to a set of views, and 
 * represent the collective set of changes applied to these views during some time interval. An animation (HLSAnimation) 
 * is then simply a collection of animation steps.
 *
 * Designated initializer: init (create a view animation step with default settings)
 */
@interface HLSViewAnimationStep : NSObject {
@private
    CATransform3D m_transform;
    CGFloat m_alphaVariation;
}

/**
 * Identity view animation step
 */
+ (HLSViewAnimationStep *)viewAnimationStep;

/**
 * The transform corresponding to the animation step. Use the convenience methods available from
 * CATransform3D.h to create translation, rotation, scaling transformations, etc. You can even combine
 * them using transformation composition (beware of the order since composing transforms is not a commutative
 * operation)
 */
@property (nonatomic, assign) CATransform3D transform;

/**
 * Alpha increment or decrement to be applied during the view animation step. Any value between 1.f and -1.f can be provided, 
 * though you should ensure that alphas never add to a value outside [0, 1] during an animation.
 * Default value is 0.f
 */
@property (nonatomic, assign) CGFloat alphaVariation;

/**
 * Return the inverse animation step
 */
- (HLSViewAnimationStep *)reverseViewAnimationStep;

@end
