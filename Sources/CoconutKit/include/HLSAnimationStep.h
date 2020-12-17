//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Block signatures
typedef void (^HLSAnimationStepCompletionBlock)(BOOL animated);

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
@property (nonatomic, copy, nullable) NSString *tag;

/**
 * Dictionary which can be freely used to convey additional information
 */
@property (nonatomic, nullable) NSDictionary *userInfo;

/**
 * Animation duration. Unlike UIView animation blocks, the duration of an animation step is never reduced
 * to 0 if no view is altered by the animation step
 *
 * Default value is 0.2
 */
@property (nonatomic) NSTimeInterval duration;

/**
 * Called when a step has been executed
 */
@property (nonatomic, copy, nullable) HLSAnimationStepCompletionBlock completionBlock;

@end

NS_ASSUME_NONNULL_END
