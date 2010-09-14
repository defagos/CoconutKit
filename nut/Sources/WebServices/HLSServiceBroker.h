//
//  HLSServiceBroker.h
//  nut
//
//  Created by Samuel Défago on 7/29/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSNotifications.h"
#import "HLSServiceRequest.h"
#import "HLSServiceRequester.h"
#import "HLSServiceSettings.h"

// Forward declarations
@class HLSServiceAggregator;
@class HLSServiceCache;
@class HLSServiceDecoder;

// TODO: Add debugging tools (number of requests, number of bytes transferred,
//       answer time, number of failures, etc.)

/**
 * Notifications
 */
// User info: "requestId" for the request id, "updatedObjects" for the NSArray of all updated objects
DECLARE_NOTIFICATION(HLSServiceBrokerAnswerReceivedNotification);

// TODO: Should carry along information about the error
DECLARE_NOTIFICATION(HLSServiceBrokerFailureNotification);

/**
 * Provides complete management of queries for retrieving information from a web service. An application
 * usually communicates with a single web service. In such cases you should probably consider creating a
 * singleton object managing the service creation and retrieval.
 *
 * Unlike other service-related classes, this class is not meant to be subclassed. It implements the service
 * architecture barebone and workflow and is not intended to be customized.
 *
 * Designated initializer: initWithSettings:
 */
@interface HLSServiceBroker : NSObject <HLSServiceRequesterDelegate> {
@private
    HLSServiceSettings *m_settings;
    HLSServiceAggregator *m_aggregator;
    NSMutableDictionary *m_requesters;              // maps NSString ids to HLSServiceRequester objects
    HLSServiceDecoder *m_decoder;
    HLSServiceCache *m_cache;
}

- (id)initWithSettings:(HLSServiceSettings *)settings;

- (void)submitRequest:(HLSServiceRequest *)request;
- (void)submitRequests:(NSArray *)requests;             // NSArray of HLSServiceRequest objects

// TODO: Cancel requests

// TODO: A lazy fetching mechanism should be implemented, but an elegant way has to be found
//       in order to be able to retrieve an object if it is not available from cache (idea: add
//       a requestById method to the HLSServiceObject protocol, which can then be implemented so that
//       the object can be retrieved. Should also have a similar method for retrieving several
//       objects in a single batch)

// TODO: Unclean. Required for convenience by the nut project, but breaks encapsulation. Should be removed
//       of this interface when promoted to a library. For this reason, this file does not include HLSServiceCache.h
//       (this way, we force callers which want to use this method to include it)
@property (nonatomic, readonly, retain) HLSServiceCache *cache;

@end
