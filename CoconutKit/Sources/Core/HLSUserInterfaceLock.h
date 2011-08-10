//
//  HLSUserInterfaceLock.h
//  CoconutKit
//
//  Created by Samuel Défago on 11/15/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Singleton class for preventing / allowing user interface interaction. To maximize locking abilities, the
 * UIWindow makeKeyAndVisible method used to install the main window should be called first in the
 * application:didFinishLaunchingWithOptions: method of your application delegate. This is required since
 * locking is achieved by installing a transparent view on top of the main window. The sooner it is available,
 * the better.
 *
 * Designated initializer: init
 */
@interface HLSUserInterfaceLock : NSObject {
@private
    UIView *m_modalView;
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
