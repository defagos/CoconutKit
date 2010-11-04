//
//  HLSServiceBoundArray.m
//  nut
//
//  Created by Samuel Défago on 7/30/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceBoundArray.h"

#import "HLSRuntimeChecks.h"

DEFINE_NOTIFICATION(HLSServiceBoundArrayUpdatedNotification);
DEFINE_NOTIFICATION(HLSServiceBoundArrayNetworkFailureNotification);
DEFINE_NOTIFICATION(HLSServiceBoundArrayErrorNotification);

@interface HLSServiceBoundArray ()

@property (nonatomic, retain) NSString *requestId;
// Since the broker notifies service arrays (which only interact with it in such occasions), it is safe to assign.
// Retain would not have been desirable (requests must not keep the corresponding broker alive!)
@property (nonatomic, assign) HLSServiceBroker *broker;
@property (nonatomic, retain) NSArray *objects;

- (void)serviceBrokerAnswerReceived:(NSNotification *)notification;
- (void)serviceBrokerNetworkFailure:(NSNotification *)notification;
- (void)serviceBrokerDataError:(NSNotification *)notification;

@end

@implementation HLSServiceBoundArray

#pragma mark Class methods

+ (HLSServiceBoundArray *)serviceBoundArrayWithServiceBoundArray:(HLSServiceBoundArray *)serviceBoundArray
                                              sortDescriptors:(NSArray *)sortDescriptors
                                                    predicate:(NSPredicate *)predicate
{
    HLSServiceBoundArray *serviceBoundArrayCopy = [[[HLSServiceBoundArray alloc] initWithBroker:serviceBoundArray.broker] autorelease];
    
    serviceBoundArrayCopy.requestId = serviceBoundArray.requestId;
    serviceBoundArrayCopy.broker = serviceBoundArray.broker;
    
    // The following is safe. We do not create dependencies between original and retain since we are
    // working with immutable arrays
    NSArray *objects = serviceBoundArray.objects;
    
    // Filtering first
    if (predicate) {
        serviceBoundArrayCopy.predicate = predicate;
        objects = [objects filteredArrayUsingPredicate:predicate];
    }
    else {
        serviceBoundArrayCopy.predicate = serviceBoundArray.predicate;
    }

    // Then sorting
    if (sortDescriptors) {
        serviceBoundArrayCopy.sortDescriptors = sortDescriptors;
        objects = [objects sortedArrayUsingDescriptors:sortDescriptors];
    }
    else {
        serviceBoundArrayCopy.sortDescriptors = sortDescriptors;
    }

    
    serviceBoundArrayCopy.objects = objects;
    
    return serviceBoundArrayCopy;
}

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
    self.objects = nil;
    self.sortDescriptors = nil;
    self.predicate = nil;
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

@synthesize objects = m_objects;

- (void)setObjects:(NSArray *)objects
{
    // Check for self-assignment
    if (m_objects == objects) {
        return;
    }
    
    // Release old value
    [m_objects release];
    
    // Important: Only the pointer is copied here! We want to filter / sort results below, but we are not
    // retaining the result until we are done since we are not interested in intermediate steps
    m_objects = objects;
    
    // If a filter has been defined, filter first
    if (self.predicate) {
        m_objects = [m_objects filteredArrayUsingPredicate:self.predicate];
    }
    
    // Then sort if sort criteria have been defined
    // If a sort descriptor has been defined, sort the objects
    if (self.sortDescriptors) {
        m_objects = [m_objects sortedArrayUsingDescriptors:self.sortDescriptors];
    }
    
    // Now we can retain the object
    [m_objects retain];
    
    // Notify a global data update
    // TODO: This property is called to set to nil in two cases:
    //        1) When we want to get rid of the objects, but with the array still alive
    //        2) In dealloc
    // The problem: In dealloc, this sends a notification for an object which is destroyed, and this crashes the
    // app ("message sent to deallocated instance"). Strange since I thought this call was blocking until all
    // observers have processed the notification... Until I find the answer, this will fix the bug (but the
    // behavior is now incorrect since we do want to notify in the case 1)!).
    // Depending on the reasons behind this bug, some other accessors in this project might be affected and might
    // need to be fixed as well
    if (m_objects) {
        [self postCoalescingNotificationWithName:HLSServiceBoundArrayUpdatedNotification];
    }
}

@synthesize sortDescriptors = m_sortDescriptors;

@synthesize predicate = m_predicate;

#pragma mark Requesting data

- (void)bindToRequest:(HLSServiceRequest *)request
{
    // Clear previous results
    self.objects = nil;
    
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
    
    // If the answer is received for the request attached to this HLSServiceBoundArray, this means the query was submitted
    // again. We need to refresh the data completely since results have probably completely changed
    if ([self.requestId isEqual:requestId]) {
        self.objects = updatedObjects;
    }
    // Else another query was run. Maybe some objects referenced by this array have been updated (in cache)
    else {
        // Find which objects have been updated; it is cheaper to use set intersections, we therefore convert
        // our arrays to sets first
        // TODO: Maybe an issue here: if objects have overloaded isEqual, we do not compare pointers anymore
        //       and this could be an issue (since we really want to check object identity via pointer identity)
        NSSet *updatedObjectsSet = [NSSet setWithArray:updatedObjects];
        NSMutableSet *objectsSet = [NSMutableSet setWithArray:self.objects];
        
        // Find common objects
        [objectsSet intersectSet:updatedObjectsSet];
        
        // If objects have been updated
        if ([objectsSet count] != 0) {
            // We return the list of indexes corresponding to updated objects
            NSMutableArray *updatedIndexes = [NSMutableArray array];
            
            for (id object in objectsSet) {
                // We need to wrap up the index into an object to add it
                NSNumber *index = [NSNumber numberWithUnsignedInteger:[self.objects indexOfObject:object]];
                [updatedIndexes addObject:index];
            }
            
            // Notify the partial change
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:updatedIndexes, @"updatedIndexes", nil];
            [self postCoalescingNotificationWithName:HLSServiceBoundArrayUpdatedNotification userInfo:userInfo];
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
    [self postCoalescingNotificationWithName:HLSServiceBoundArrayNetworkFailureNotification];
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
    [self postCoalescingNotificationWithName:HLSServiceBoundArrayErrorNotification userInfo:errorUserInfo];
}

@end
