//
//  HLSServiceRequester.h
//  nut
//
//  Created by Samuel Défago on 7/30/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceAnswer.h"
#import "HLSServiceRequest.h"
#import "HLSServiceSettings.h"

// Forward declarations
@protocol HLSServiceRequesterDelegate;

/**
 * "Pure virtual" methods
 */
@protocol HLSServiceRequesterAbstract <NSObject>

@optional
- (void)start;

@end

/**
 * Subclass this class to implement your custom logic. When your requester succeeds or fails be sure to
 * notify the delegate using the dedicated protocol below
 *
 * You do not instantiate a service requester yourself. This step is performed by the service broker
 * which uses it. The broker calls the initWithRequest:settings: method, that is why you must not define another
 * initializer in subclasses (it would never be called).
 *
 * Designated initializer: initWithRequest:settings:
 */
@interface HLSServiceRequester : NSObject <HLSServiceRequesterAbstract> {
@private
    NSString *m_requestId;
    id<HLSServiceRequesterDelegate> m_delegate;
}

- (id)initWithRequest:(HLSServiceRequest *)request settings:(HLSServiceSettings *)settings;

@property (nonatomic, assign) id<HLSServiceRequesterDelegate> delegate;
@property (nonatomic, readonly, retain) NSString *requestId;

@end

@protocol HLSServiceRequesterDelegate <NSObject>

- (void)serviceRequester:(HLSServiceRequester *)requester didReceiveAnswer:(HLSServiceAnswer *)aggregatedAnswer 
            forRequestId:(NSString *)requestId;
- (void)serviceRequester:(HLSServiceRequester *)requester failedForRequestId:(NSString *)requestId;

@end
