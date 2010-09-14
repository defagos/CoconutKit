//
//  HLSAnimationFrame.h
//  nut
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Designated initializer: init
 */
@interface HLSAnimationFrame : NSObject {
@private
    CGAffineTransform m_transform;
    CGFloat m_alpha;
}

/**
 * Default frame (no transformation)
 */
+ (HLSAnimationFrame *)animationFrame;

/**
 * Factory methods for most common frames
 */
// Animation frame corresponding to a view's position
+ (HLSAnimationFrame *)animationFrameForView:(UIView *)view;
// Frame must be given relatively to the views's parent coordinate system
+ (HLSAnimationFrame *)animationFrameMovingView:(UIView *)view toFrame:(CGRect)frame;

@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGFloat alpha;

@end
