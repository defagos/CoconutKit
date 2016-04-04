//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Singleton class for preventing / allowing user interface interaction
 *
 * Not meant to be instantiated. Use the singleton method instance
 */
@interface HLSUserInterfaceLock : NSObject<NSLocking> 

/**
 * Singleton instance
 */
+ (HLSUserInterfaceLock *)sharedUserInterfaceLock;

/**
 * Locking and unlocking the UI. Each lock increments an internal counter, each unlock decrements it. When
 * the counter is different from zero, the user interface is locked.
 */
- (void)lock;
- (void)unlock;

@end

NS_ASSUME_NONNULL_END
