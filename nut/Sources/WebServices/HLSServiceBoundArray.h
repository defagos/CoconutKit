//
//  HLSServiceBoundArray.h
//  nut
//
//  Created by Samuel Défago on 7/30/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSNotifications.h"
#import "HLSServiceBroker.h"
#import "HLSServiceRequest.h"

// TODO: See HLSServiceBoundObject: Objects should not be retained, only weak pointers must be stored by HLSServiceBoundArray.
//       But this requires us to write an array which does not send a retain message to objects put within it first!

/**
 * Notifications
 */
// If an "updatedIndexes" NSArray is available from userInfo, then a partial update of the objects located
// at those indexes occurred (the caller can just update those entries). Otherwise a global updated occurred
// (the caller must perform a global refresh)
DECLARE_NOTIFICATION(HLSServiceBoundArrayUpdatedNotification);

/**
 * Service arrays are arrays of objects kept in sync with the cache of objects managed by a web service broker.
 * These arrays can be bound to a specific request, i.e. when the request answer is received the object will
 * automatically be updated and notify its observers. Moreover, cache objects updated because of another query
 * will also trigger a notification. In both cases observers will receive a HLSServiceBoundArrayUpdatedNotification.
 *
 * Sort descriptors can also optionally be associated with this array, otherwise the objects will be stored
 * as the web service returns them.
 *
 * Since web services always do not provide a way to get requests filtered against some criteria or sorted
 * against other ones, HLSServiceBoundArray provides a way to attach filters and sorters. When the data is
 * received, objects are filtered and sorted before being stored.
 *
 * Designated initializer: initWithBroker:
 */
@interface HLSServiceBoundArray : NSObject {
@private
    NSString *m_requestId;
    HLSServiceBroker *m_broker;
    NSArray *m_objects;
    NSArray *m_sortDescriptors;             // contains NSSortDescriptor objects
    NSPredicate *m_predicate;               // predicate which to filter results 
}

/**
 * Create a clone of the service bound array, registered with the same broker and for the same request id,
 * and initialized with the original array data, optionally filtered and / or sorted (use nil if filtering /
 * sorting is not different from the original array, in which case the same settings will be applied)
 */
+ (HLSServiceBoundArray *)serviceBoundArrayWithServiceBoundArray:(HLSServiceBoundArray *)serviceBoundArray
                                              sortDescriptors:(NSArray *)sortDescriptors
                                                    predicate:(NSPredicate *)predicate;

- (id)initWithBroker:(HLSServiceBroker *)broker;

- (void)bindToRequest:(HLSServiceRequest *)request;

@property (nonatomic, readonly, retain) NSArray *objects;

/**
 * Note that these descriptors and predicates are not applied when you set them. They will be applied the next
 * time the service broker notifies about the availability of the answer matching the associated request id. There
 * is one reason for this behavior: Applying descriptors and predicates to existing data does not mean it is 
 * up-to-date (the request must be resent to be sure it is).
 * If you know that your data is up-to-date, or if you don't care, you can create a filtered copy of an existing array
 * and data by using the convenience method
 *    filteredServiceBoundArrayWithServiceBoundArray:sortDescriptors:predicate:
 */
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSPredicate *predicate;

@end
