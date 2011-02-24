//
//  HLSServiceBroker.m
//  nut
//
//  Created by Samuel Défago on 7/29/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceBroker.h"

#import "HLSLogger.h"
#import "HLSServiceAggregator.h"
#import "HLSServiceCache.h"
#import "HLSServiceDecoder.h"
#import "HLSServiceObjectDescription.h"

DEFINE_NOTIFICATION(HLSServiceBrokerAnswerReceivedNotification);
DEFINE_NOTIFICATION(HLSServiceBrokerNetworkFailureNotification);
DEFINE_NOTIFICATION(HLSServiceBrokerDataErrorNotification);

@interface HLSServiceBroker ()

@property (nonatomic, retain) HLSServiceSettings *settings;
@property (nonatomic, retain) HLSServiceAggregator *aggregator;
@property (nonatomic, retain) NSMutableDictionary *requesters;
@property (nonatomic, retain) HLSServiceDecoder *decoder;
@property (nonatomic, retain) HLSServiceCache *cache;

@end

@implementation HLSServiceBroker

#pragma mark Object creation and destruction

- (id)initWithSettings:(HLSServiceSettings *)settings
{
    if (self = [super init]) {
        self.settings = settings;
        // TODO: Test against nil when instantiating using class name (nil if the class name is invalid)
        self.aggregator = [[[NSClassFromString(self.settings.aggregatorClassName) alloc] init] autorelease];
        self.requesters = [NSMutableDictionary dictionary];
        self.decoder = [[[NSClassFromString(self.settings.decoderClassName) alloc] init] autorelease];
        self.cache = [[[HLSServiceCache alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.settings = nil;
    self.aggregator = nil;
    self.requesters = nil;
    self.decoder = nil;
    self.cache = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize settings = m_settings;

@synthesize aggregator = m_aggregator;

@synthesize requesters = m_requesters;

@synthesize decoder = m_decoder;

@synthesize cache = m_cache;

#pragma mark Sending requests

- (void)submitRequest:(HLSServiceRequest *)request
{
    [self submitRequests:[NSArray arrayWithObject:request]];
}

- (void)submitRequests:(NSArray *)requests
{
    // If the array is empty, nothing to send
    if ([requests count] == 0) {
        return;
    }
    
    // Aggregate the sub-requests into a single request
    HLSServiceRequest *fullRequest = [self.aggregator aggregateRequests:requests];
    if (! fullRequest) {
        logger_error(@"Could not send requests");
        return;
    }
    
    // Create the requester object for submitting the single request to the web service
    HLSServiceRequester *requester = [[[NSClassFromString(self.settings.requesterClassName) alloc] initWithRequest:fullRequest
                                                                                                       settings:self.settings]
                                   autorelease];
    requester.delegate = self;
    
    // Retain the requester during the time the request is processed
    [self.requesters setObject:requester forKey:fullRequest.id];
    [requester start];
}

#pragma mark HLSServiceRequesterDelegate protocol implementation

- (void)serviceRequester:(HLSServiceRequester *)requester didReceiveAnswer:(HLSServiceAnswer *)aggregatedAnswer 
            forRequestId:(NSString *)requestId
{    
    // We are done with the request
    [self.requesters removeObjectForKey:requestId];
    
    // Separate into sub-answers; notify on failure
    NSError *disaggregationError = nil;
    NSArray *answers = [self.aggregator disaggregateAnswer:aggregatedAnswer didFailWithError:&disaggregationError];
    if (disaggregationError) {
        // Technical failure for programmer's eyes only; no need to propagate through notification
        logger_debug(@"Disaggregation error: %@", [disaggregationError localizedDescription]);
        return;
    }
    
    // Process each answer
    for (HLSServiceAnswer *answer in answers) {
        // We collect all objects we are updating or creating because of this answer
        NSMutableArray *updatedObjects = [NSMutableArray array];
        
        // Extract the descriptions of each object within the answer
        NSError *decodingError = nil;
        NSArray *objectDescriptions = [self.decoder decodeAnswer:answer didFailWithError:&decodingError];
        if (decodingError) {
            // Forward the error information
            NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:answer.requestId, @"requestId",
                                           decodingError, @"error", nil];
            [self postCoalescingNotificationWithName:HLSServiceBrokerDataErrorNotification
                                            userInfo:errorUserInfo];
            
            // Process the next answer, decoding failure for one answer does not mean that all are incorrect
            continue;
        }
        
        // Create corresponding objects in the cache (if not existing) and fill their information
        for (HLSServiceObjectDescription *objectDescription in objectDescriptions) {
            // If the object already exist in cache, get it, otherwise create it
            NSObject<HLSServiceObject> *object = [self.cache objectWithClassName:objectDescription.className id:objectDescription.id];
            if (! object) {
                object = [[[NSClassFromString(objectDescription.className) alloc] initWithId:objectDescription.id] autorelease];
                [self.cache setObject:object forClassName:objectDescription.className andId:objectDescription.id];
            }
            
            // Add this object to the list of updated object
            [updatedObjects addObject:object];
            
            // Fill the object with KVC
            [object setValuesForKeysWithDictionary:objectDescription.fields];
        }
        
        // Broadcast the updated object list for the request id (same as answer id)
        NSDictionary *answerUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:answer.requestId, @"requestId", 
                                        updatedObjects, @"updatedObjects", nil];
        [self postCoalescingNotificationWithName:HLSServiceBrokerAnswerReceivedNotification 
                                        userInfo:answerUserInfo];
    }
}

- (void)serviceRequester:(HLSServiceRequester *)requester failedForRequestId:(NSString *)requestId
{    
    // Forward failure to all aggregated requests
    NSArray *subRequestIds = [self.aggregator requestIdsForAggregatedRequestId:requestId];
    for (NSString *subRequestId in subRequestIds) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:subRequestId, @"requestId", nil];
        [self postCoalescingNotificationWithName:HLSServiceBrokerNetworkFailureNotification
                                        userInfo:userInfo];
    }
    
    [self.requesters removeObjectForKey:requestId];
}

@end
