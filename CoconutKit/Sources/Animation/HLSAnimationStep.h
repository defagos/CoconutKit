//
//  HLSAnimationStep.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSAnimationStepDelegate;

/**
 * Abstract base class for animation steps. Do not instantiate directly
 *
 * Designated initializer: -init
 */
@interface HLSAnimationStep : NSObject <NSCopying> {
@private
    NSMutableArray *m_objectKeys;
    NSMutableDictionary *m_objectToObjectAnimationMap;
    NSString *m_tag;
    NSDictionary *m_userInfo;
    NSTimeInterval m_duration;
    id<HLSAnimationStepDelegate> m_delegate;
    BOOL m_terminating;
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
 * Dictionary which can be freely used to convey additional information
 */
@property (nonatomic, retain) NSDictionary *userInfo;

/**
 * Animation duration. Unlike UIView animation blocks, the duration of an animation step is never reduced
 * to 0 if no view is altered by the animation step
 *
 * Default value is 0.2
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
