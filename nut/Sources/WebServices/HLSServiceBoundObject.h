//
//  HLSServiceBoundObject.h
//  nut
//
//  Created by Samuel Défago on 8/6/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSNotifications.h"
#import "HLSServiceBroker.h"
#import "HLSServiceRequest.h"

/**
 * Notifications
 */
DECLARE_NOTIFICATION(HLSServiceBoundObjectUpdatedNotification);

/**
 * A service object is a simple object wrapper kept in sync with the cache of objects managed by a web service broker.
 * Such an object can be bound to a specific request, i.e. when the request answer is received the object will
 * automatically be updated and notify its observers. Moreover, a cache object updated because of another query
 * will also trigger a notification. In both cases observers will receive a HLSServiceBoundObjectUpdatedNotification.
 *
 * You are responsible of binding a request which only returns one object. If several objects are returned no
 * update will occur (a trace is available in debug mode)
 *
 * Designated initializer: initWithBroker:
 */
@interface HLSServiceBoundObject : NSObject {
@private
    NSString *m_requestId;
    HLSServiceBroker *m_broker;
    id m_object;
}

- (id)initWithBroker:(HLSServiceBroker *)broker;

- (void)bindToRequest:(HLSServiceRequest *)request;

// TODO: Problem with retain cycles: If a HLSServiceBoundObject refers to another HLSServiceBoundObject which refers to the first, we have
//       a retain cycle. To avoid this, we should have a "weak" HLSServiceBoundObject which does not retain its object
//    -> Well, probably the best way is to never retain the object. The object is retained by the service cache, each object which needs
//       to refer to a cached object retains a HLSServiceBoundObject only weakly pointing at the object in cache. This way, since HLSServiceBoundObject
//       are simple objects which can never refer to themselves, no retain cycles will exist.
@property (nonatomic, readonly, retain) id object;

@end
