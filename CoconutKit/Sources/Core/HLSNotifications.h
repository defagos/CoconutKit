//
//  HLSNotifications.h
//  CoconutKit
//
//  Created by Samuel DEFAGO on 03.06.10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Helper header file for defining new notifications.
 *
 * A module introducing new notifications should:
 *   1) import this header file in its own header file
 *   2) in its header file, declare the new notification name using the HLSDeclareNotification macro
 *   3) in its implementation file, define the new notification using the HLSDefineNotification macro
 * If two modules try to introduce the same notification name, a linker error will occur (since the symbol 
 * is in this case multiply defined in two separate translation units). This is good expected behavior, and 
 * this matches the approach applied in the Apple frameworks (see e.g. NSWindow on MacOS, or UIWindow on iOS)
 *
 * Note that notification names should end with "Notification"
 */
#define HLSDeclareNotification(name)      extern NSString * const name
#define HLSDefineNotification(name)       NSString * const name = @#name

/**
 * Manages application-wide notification mechanisms
 *
 * This class is not thread-safe
 *
 * Designated initializer: init
 */
@interface HLSNotificationManager : NSObject {
@private
    NSUInteger m_networkActivityCount;
}

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
 * To avoid breaking encapsulation, an object composed from (retained) objects emitting notifications should translate
 * those notifications into its own notifications, otherwise the object internals might be revealed. Writing
 * such conversion code can be tedious and error prone. The HLSNotificationConverter singleton provides a convenient
 * way to define conversions with very litte code.
 *
 * Designated initializer: init
 */
@interface HLSNotificationConverter : NSObject {
@private
    // To be able to add conversion rules for an (object, notification name), and to be able to remove all rules defined
    // for an object, we introduce two dictionary levels:
    //   - 1st dictionary: maps objects to a notification map
    //   - 2nd dictionary (notification map): maps notification name to the (object, notification name) pair to
    //                                        convert to
    NSMutableDictionary *m_objectToNotificationMap;
}

+ (HLSNotificationConverter *)sharedNotificationConverter;

/**
 * Add a conversion rule. The objectFrom and objectTo objects are NOT retained, as for NSNotificationManager. This is 
 * not needed (and not desirable) since:
 *  - objectFrom: When deallocated, an object must have unregistered itself from the HLSNotificationConverter
 *                by calling removeConversionsFromObject:
 *  - objectTo: HLSNotificationConverter is meant to be used for converting notifications in object compositions,
 *              where objectFrom is a member of objectTo and is retained by it. As long as the conversion rule
 *              exists (and provided objectFrom removes all associated rules when it gets deallocated) objectTo
 *              is guaranteed to be valid, since its lifetime is longer than the one of objectFrom
 */
- (void)convertNotificationWithName:(NSString *)notificationNameFrom
                       sentByObject:(id)objectFrom
           intoNotificationWithName:(NSString *)notificationNameTo
                       sentByObject:(id)objectTo;

/**
 * Add a conversion rule for all objects within an enumerable collection. Convenience function with same semantics
 * as convertNotificationWithName:sentByObject:intoNotificationWithName:sentByObject:
 */
- (void)convertNotificationWithName:(NSString *)notificationNameFrom
           sentByObjectInCollection:(id<NSFastEnumeration>)collectionFrom
           intoNotificationWithName:(NSString *)notificationNameTo
                       sentByObject:(id)objectTo;

/**
 * Remove all conversion rules related to an object
 */
- (void)removeConversionsFromObject:(id)objectFrom;

/**
 * Remove all conversion rules related to all objects of an enumerable collection
 */
- (void)removeConversionsFromObjectsInCollection:(id<NSFastEnumeration>)collectionFrom;

@end

/**
 * Extensions for writing less notification code in the most common cases
 */
@interface NSObject (HLSNotificationExtensions)

- (void)postCoalescingNotificationWithName:(NSString *)name userInfo:(NSDictionary *)userInfo;
- (void)postCoalescingNotificationWithName:(NSString *)name;

@end

@interface NSNotificationCenter (HLSNotificationExtensions)

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name objectsInCollection:(id<NSFastEnumeration>)collection;
- (void)removeObserver:(id)observer name:(NSString *)name objectsInCollection:(id<NSFastEnumeration>)collection;

@end
