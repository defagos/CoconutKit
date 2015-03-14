//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSNullability.h"

#import <Foundation/Foundation.h>

/**
 * Common abstract class for animations
 */

NS_ASSUME_NONNULL_BEGIN
@interface HLSObjectAnimation : NSObject <NSCopying>

/**
 * Identity animation
 */
+ (instancetype)animation;

@end
NS_ASSUME_NONNULL_END
