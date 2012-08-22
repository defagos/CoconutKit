//
//  HLSAnimationStep+Protected.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface HLSAnimationStep (Protected)

/**
 * Setting an animation for an object
 */
- (void)addObjectAnimation:(id<HLSObjectAnimation>)objectAnimation forObject:(id)object;

/**
 * Retrieving the animation for an object
 */
- (id<HLSObjectAnimation>)objectAnimationForObject:(id)object;

/**
 * All objects changed by the animation group, returned in the order they were added to it
 */
- (NSArray *)objects;

/**
 * Return a string describing the involved object animations
 */
- (NSString *)objectAnimationDescriptionString;

@property (nonatomic, assign) id<HLSAnimationStepDelegate> delegate;

@end
