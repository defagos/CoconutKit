//
//  HLSAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSObjectAnimation.h"

@interface HLSAnimationStep : NSObject <NSCopying> {
@private
    NSMutableArray *m_objectKeys;
    NSMutableDictionary *m_objectToObjectAnimationMap;
    NSString *m_tag;
    NSTimeInterval m_duration;
}

/**
 * Convenience constructor for an animation step with default settings and nothing to animate
 */
+ (id)animationStep;

/**
 * Optional tag to help identifying animation steps
 */
@property (nonatomic, retain) NSString *tag;

/**
 * Animation duration. Unlike UIView animation blocks, the duration of an animation step is never reduced
 * to 0 if no view is altered by the animation step
 *
 * Default value is 0.2
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * Playing the animation
 */
- (void)playAnimated:(BOOL)animated;

/**
 * Cancel the animation associated with the step (if running)
 */
- (void)cancelAnimations;

/**
 * The reverse animation
 */
- (id)reverseAnimationStep;

@end
