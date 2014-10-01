//
//  HLSObjectAnimation.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * Common abstract class for animations
 */
@interface HLSObjectAnimation : NSObject <NSCopying>

/**
 * Identity animation
 */
+ (instancetype)animation;

@end
