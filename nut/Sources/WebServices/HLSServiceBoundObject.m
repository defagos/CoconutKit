//
//  HLSServiceBoundObject.m
//  nut
//
//  Created by Samuel Défago on 8/6/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceBoundObject.h"

#import "HLSLogger.h"
#import "HLSRuntimeChecks.h"

DEFINE_NOTIFICATION(HLSServiceBoundObjectUpdatedNotification);
DEFINE_NOTIFICATION(HLSServiceBoundObjectNetworkFailureNotification);
DEFINE_NOTIFICATION(HLSServiceBoundObjectErrorNotification);

@interface HLSServiceBoundObject ()

@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, assign) HLSServiceBroker *broker;
@property (nonatomic, retain) id object;

- (void)serviceBrokerAnswerReceived:(NSNotification *)notification;
- (void)serviceBrokerNetworkFailure:(NSNotification *)notification;
- (void)serviceBrokerDataError:(NSNotification *)notification;

@end

@implementation HLSServiceBoundObject

#pragma mark Object creation and destruction

- (id)initWithBroker:(HLSServiceBroker *)broker
{
    if (self = [super init]) {
        self.broker = broker;
    }
    return self;
}

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    self.requestId = nil;    
    self.broker = nil;
    self.object = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize requestId = m_requestId;

@synthesize broker = m_broker;

- (void)setBroker:(HLSServiceBroker *)broker
{
    // Check for self-assignment
    if (m_broker == broker) {
        return;
    }
    
    // Stop listening to notifications for the old object
    if (m_broker) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:HLSServiceBrokerAnswerReceivedNotification
                                                      object:m_broker];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:HLSServiceBrokerNetworkFailureNotification
                                                      object:m_broker];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:HLSServiceBrokerDataErrorNotification
                                                      object:m_broker];
    }
    
    // Update the value
    m_broker = broker;
    
    // Register to notifications for the new object
    if (m_broker) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(serviceBrokerAnswerReceived:) 
                                                     name:HLSServiceBrokerAnswerReceivedNotification 
                                                   object:m_broker];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(serviceBrokerNetworkFailure:) 
                                                     name:HLSServiceBrokerNetworkFailureNotification
                                                   object:m_broker];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(serviceBrokerDataError:) 
                                                     name:HLSServiceBrokerDataErrorNotification 
                                                   object:m_broker];  
    }
}

@synthesize object = m_object;

- (void)setObject:(id)object
{
    // Check for self-assignment
    if (m_object == object) {
        return;
    }
    
    // Update the value
    [m_object release];
    m_object = [object retain];
    
    // Notify a data update
    // TODO: This property is called to set to nil in two cases:
    //        1) When we want to get rid of the objects, but with the array still alive
    //        2) In dealloc
    // The problem: In dealloc, this sends a notification for an object which is destroyed, and this crashes the
    // app ("message sent to deallocated instance"). Strange since I thought this call was blocking until all
    // observers have processed the notification... Until I find the answer, this will fix the bug (but the
    // behavior is now incorrect since we do want to notify in the case 1)!).
    // Depending on the reasons behind this bug, some other accessors in this project might be affected and might
    // need to be fixed as well
    if (m_object) {
        [self postCoalescingNotificationWithName:HLSServiceBoundObjectUpdatedNotification];
    }
}

#pragma mark Requesting data

- (void)bindToRequest:(HLSServiceRequest *)request
{
    // Clear previous results
    self.object = nil;
    
    // Remember the request id
    self.requestId = request.id;
}

#pragma mark Notification callbacks

- (void)serviceBrokerAnswerReceived:(NSNotification *)notification
{
    // Extract the user information
    NSDictionary *userInfo = [notification userInfo];
    NSString *requestId = [userInfo objectForKey:@"requestId"];
    NSArray *updatedObjects = [userInfo objectForKey:@"updatedObjects"];
    
    // If the answer is received for the request attached to this HLSServiceBoundObject, this means the query was submitted
    // again. We need to refresh the data completely since the result has probably completely changed
    if ([self.requestId isEqual:requestId]) {
        if ([updatedObjects count] != 1) {
            logger_warn(@"Query returning %d object(s), 1 object expected", [updatedObjects count]);
            return;
        }
        self.object = [updatedObjects objectAtIndex:0];
    }
    // Else another query was run. Maybe the object has been updated (in cache)
    else {
        // Find if the wrapped object belongs to the updated objects
        // TODO: Maybe an issue here: if objects have overloaded isEqual, we do not compare pointers anymore
        //       and this could be an issue (since we really want to check object identity via pointer identity)
        if ([updatedObjects containsObject:self.object]) {
            [self postCoalescingNotificationWithName:HLSServiceBoundObjectUpdatedNotification];
        }
    }
}

- (void)serviceBrokerNetworkFailure:(NSNotification *)notification
{
    // Extract the user information
    NSDictionary *userInfo = [notification userInfo];
    NSString *requestId = [userInfo objectForKey:@"requestId"];
    
    // Only interested in errors related to the attached request
    if (! [self.requestId isEqual:requestId]) {
        return;
    }
    
    // Forward the error
    [self postCoalescingNotificationWithName:HLSServiceBoundObjectNetworkFailureNotification]; 
}

- (void)serviceBrokerDataError:(NSNotification *)notification
{
    // Extract the user information
    NSDictionary *userInfo = [notification userInfo];
    NSString *requestId = [userInfo objectForKey:@"requestId"];
    NSError *error = [userInfo objectForKey:@"error"];
    
    // Only interested in errors related to the attached request
    if (! [self.requestId isEqual:requestId]) {
        return;
    }
    
    // Forward the error
    NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
    [self postCoalescingNotificationWithName:HLSServiceBoundObjectErrorNotification userInfo:errorUserInfo];    
}

@end
