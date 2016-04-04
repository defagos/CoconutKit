//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Common abstract class for animations
 */
@interface HLSObjectAnimation : NSObject <NSCopying>

/**
 * Identity animation
 */
+ (instancetype)animation;

@end

NS_ASSUME_NONNULL_END
