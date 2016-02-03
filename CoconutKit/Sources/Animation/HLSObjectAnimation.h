//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

/**
 * Common abstract class for animations
 */
@interface HLSObjectAnimation : NSObject <NSCopying>

/**
 * Identity animation
 */
+ (instancetype)animation;

@end
