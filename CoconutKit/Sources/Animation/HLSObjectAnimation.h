//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
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
