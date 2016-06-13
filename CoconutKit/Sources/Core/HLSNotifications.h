//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Manages application-wide notification mechanisms
 *
 * This class is not thread-safe
 */
@interface HLSNotificationManager : NSObject

/**
 * Get the shared object managing application-wide notifications
 */
+ (HLSNotificationManager *)sharedNotificationManager;

/**
 * Call this method to notify that a network task has started. This method can be called several times if several
 * tasks are running simultaneously (an activity indicator is displayed in the status bar when at least one task 
 * is running)
 */
- (void)notifyBeginNetworkActivity;

/**
 * Call this method to notify that a network task has ended. This method can be called several times if several
 * tasks are running simultaneously (an activity indicator is displayed in the status bar when at least one task 
 * is running)
 */
- (void)notifyEndNetworkActivity;

@end

/**
 * Extensions for writing less notification code in the most common cases
 */
@interface NSObject (HLSNotificationExtensions)

- (void)hls_postCoalescingNotificationWithName:(NSString *)name userInfo:(nullable NSDictionary *)userInfo;
- (void)hls_postCoalescingNotificationWithName:(NSString *)name;

@end

@interface NSNotificationCenter (HLSNotificationExtensions)

- (void)hls_addObserver:(id)observer selector:(SEL)selector name:(nullable NSString *)name objectsInCollection:(nullable id<NSFastEnumeration>)collection;
- (void)hls_removeObserver:(id)observer name:(nullable NSString *)name objectsInCollection:(nullable id<NSFastEnumeration>)collection;

@end

NS_ASSUME_NONNULL_END
