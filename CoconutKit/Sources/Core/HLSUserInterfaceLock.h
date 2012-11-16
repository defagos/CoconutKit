//
//  HLSUserInterfaceLock.h
//  CoconutKit
//
//  Created by Samuel Défago on 11/15/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Singleton class for preventing / allowing user interface interaction
 *
 * Designated initializer: -init
 */
@interface HLSUserInterfaceLock : NSObject {
@private
    NSUInteger m_useCount;
}

+ (HLSUserInterfaceLock *)sharedUserInterfaceLock;

/**
 * Locking and unlocking the UI. Each lock increments an internal counter, each unlock decrements it. When
 * the counter is different from zero, the user interface is locked.
 */
- (void)lock;
- (void)unlock;

@end
