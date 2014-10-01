//
//  HLSAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * Abstract base class for animation steps. Do not instantiate directly
 */
@interface HLSAnimationStep : NSObject <NSCopying>

/**
 * Convenience constructor for an animation step with default settings and nothing to animate
 */
+ (instancetype)animationStep;

/**
 * Create an animation step with default settings
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * Optional tag to help identifying animation steps
 */
@property (nonatomic, strong) NSString *tag;

/**
 * Dictionary which can be freely used to convey additional information
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 * Animation duration. Unlike UIView animation blocks, the duration of an animation step is never reduced
 * to 0 if no view is altered by the animation step
 *
 * Default value is 0.2
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
