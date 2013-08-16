//
//  HLSApplicationLock.h
//  CoconutKit
//
//  Created by Samuel Défago on 11/15/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Singleton class for application-wide locks. This class is meant to better cope with methods which should
 * inherently be reference-counted, but which are not, by providing a simple reference-counted wrapper around
 * them. This is not a perfect solution, though, since other code and manual calls to the underlying methods
 * can interfer with the state maintained by HLSApplicationLock
 *
 * Designated initializer: -init
 */
@interface HLSApplicationLock : NSObject

+ (HLSApplicationLock *)sharedApplicationLock;

/**
 * Locking and unlocking UI interactions. Each lock increments an internal counter, each unlock decrements it. When
 * the counter is different from zero, the user interface is blocked.
 */
- (void)lockUserInteractions;
- (void)unlockUserInteractions;

/**
 * Locking and unlocking animations. Each lock increments an internal counter, each unlock decrements it. When
 * the counter is different from zero, animations are blocked.
 */
- (void)lockAnimations;
- (void)unlockAnimations;

@end
