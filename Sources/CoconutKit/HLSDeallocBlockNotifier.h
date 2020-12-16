//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  An object which calls the provided block when deallocated.
 */
@interface HLSDeallocBlockNotifier : NSObject

/**
 *  Create an instance with the provided block.
 */
- (instancetype)initWithBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
