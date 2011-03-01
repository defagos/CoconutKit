//
//  HLSRequester.m
//  nut
//
//  Created by Samuel DEFAGO on 04.06.10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSRequester.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

// Transitions between HLSRequesterStatus-es might correspond to changes of network activity (e.g. when a request
// goes from idle to retrieving, network activity starts). The following enum is mean to represent those
// possible network activity changes
typedef enum {
    HLSRequesterNetworkStatusNone = 0,         // No change in network activity
    HLSRequesterNetworkStatusStart,            // Network traffic starts
    HLSRequesterNetworkStatusStop              // Network traffic stops
} HLSRequesterNetworkStatus;

// Transitions are saved into a static decision table. The first index is the first HLSRequesterStatus, the second index is
// the second HLSRequesterStatus we transition into, and the element they point at represent the associated network status
// transition
static HLSRequesterNetworkStatus s_transitions[HLSRequesterStatusEnumSize][HLSRequesterStatusEnumSize] 
= {HLSRequesterNetworkStatusNone};

DEFINE_NOTIFICATION(HLSRequesterAllRetrievedNotification);
DEFINE_NOTIFICATION(HLSRequesterChunkRetrievedNotification);
DEFINE_NOTIFICATION(HLSRequesterFailureNotification);

@interface HLSRequester ()

- (void)reset;

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) HLSRequesterStatus status;

@end

@implementation HLSRequester

#pragma mark Class initializer

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [HLSRequester class]) {
        return;
    }
    
    // Initialise the network transition static decision table. Only transitions different from HLSRequesterNetworkStatusNone 
    // need to be set since the table is initially filled with this value
    s_transitions[HLSRequesterStatusIdle][HLSRequesterStatusRetrieving] = HLSRequesterNetworkStatusStart;
    s_transitions[HLSRequesterStatusRetrieving][HLSRequesterStatusIdle] = HLSRequesterNetworkStatusStop;
    s_transitions[HLSRequesterStatusRetrieving][HLSRequesterStatusDone] = HLSRequesterNetworkStatusStop;
    s_transitions[HLSRequesterStatusDone][HLSRequesterStatusRetrieving] = HLSRequesterNetworkStatusStart;
}

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super init])) {
        self.request = request;
        self.data = [[[NSMutableData alloc] init] autorelease];
        self.status = HLSRequesterStatusIdle;
        m_expectedContentLength = NSURLResponseUnknownLength;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.request = nil;
    self.tag = nil;
    self.connection = nil;
    self.data = nil;
    [super dealloc];
}

#pragma mark Starting the retrieving process

- (void)start
{
    // If the process is already started, then nothing to be done
    if (self.status == HLSRequesterStatusRetrieving) {
        return;
    }
    
    // Reset object
    [self reset];
    
    // Create a connection for sending the request asynchronously
    // WARNING: The connection object retains its delegate (here a HLSRequester instance). Retaining
    //          delegates (which in general outlive the objects they are the delegate from)
    //          is dangerous and, since retain must be transitive, if the delegate itself has
    //          a delegate, it will need to retain it as well (otherwise we might end up sending
    //          messages to an already released delegate object). This can propagate far away and
    //          can be dangerous for the overall design / maintenance.
    //          To solve this problem we break the delegate retain chain by turning delegation
    //          into notification: This class therefore only notifies observers through notification,
    //          not delegation. This way, an observer might be destroyed sooner than the HLSRequester 
    //          instance it watches (which itself lives longer because the NSURLConnection object has 
    //          not released it yet), nothing bad will happen. The notification will simply be heard
    //          by no one.
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self] autorelease];
    
    // The process could not start
    if (! self.connection) {
        logger_error(@"Unable to open connection for fetching data %@", self.tag);
    }
}

#pragma mark Fetching data

- (NSData *)fetchData
{
    if (self.status == HLSRequesterStatusDone) {
        return self.data;
    }
    else {
        return nil;
    }
}

- (NSData *)fetchPartialData
{
    if (self.status == HLSRequesterStatusDone
        || self.status == HLSRequesterStatusRetrieving) {
        return self.data;
    }
    else {
        return nil;
    }
}

#pragma mark Getting status

- (float)progress
{
    // Retrieved
    if (self.status == HLSRequesterStatusDone) {
        return 1.f;
    }
    // Not retrieving
    else if (self.status == HLSRequesterStatusIdle) {
        return 0.f;
    }
    // Retrieving
    else {
        // The content length could be retrieved
        if (m_expectedContentLength != NSURLResponseUnknownLength) {
            return (float)[self.data length] / m_expectedContentLength;
        }
        // If the content length was not retrieved, we return 0.1f to mean that the process
        // has started, but we cannot say more
        else {
            return 0.1f;
        }
    }
}

#pragma mark Accessors and mutators

@synthesize request = m_request;

@synthesize tag = m_tag;

@synthesize connection = m_connection;

- (void)setConnection:(NSURLConnection *)connection
{
    // Check-before-change idiom
    if (m_connection == connection) {
        return;
    }
    
    [m_connection release];
    m_connection = [connection retain];
    
    // If a new connection has been assigned
    if (m_connection) {
        self.status = HLSRequesterStatusRetrieving;
    }
    // The connection is being removed; if a request was being made, reset
    // to idle status. If a request has been completed, do not alter the status
    else if (self.status == HLSRequesterStatusRetrieving) {
        self.status = HLSRequesterStatusIdle;
    }
}

@synthesize data = m_data;

@synthesize status = m_status;

- (void)setStatus:(HLSRequesterStatus)status
{
    // If the value is not being changed, nothing to be done
    if (m_status == status) {
        return;
    }
    
    // Notify the network status manager depending on status transitions
    if (s_transitions[m_status][status] == HLSRequesterNetworkStatusStart) {
        [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    }
    else if (s_transitions[m_status][status] == HLSRequesterNetworkStatusStop) {
        [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    }
    
    m_status = status;
}

#pragma mark Object reinitialization

- (void)reset
{
    [self.data setLength:0];
    self.status = HLSRequesterStatusIdle;
    m_expectedContentLength = NSURLResponseUnknownLength;
}

#pragma mark NSURLConnection events

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Each time a response is received we must discard any previously accumulated data
    // (refer to NSURLConnection documentation for more information)
    [self.data setLength:0];
    
    m_expectedContentLength = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Adds the data increment just received
    [self.data appendData:data];
    
    // Announce that a new data chunk is available
    [self postCoalescingNotificationWithName:HLSRequesterChunkRetrievedNotification];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    logger_debug(@"Data request failed with error: %@", error);
    
    // Reset object
    [self reset];
    
    // Done with the connection
    self.connection = nil;
    
    // Announce failure
    [self postCoalescingNotificationWithName:HLSRequesterFailureNotification];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The whole data is now available
    self.status = HLSRequesterStatusDone;
    
    // Done with the connection
    self.connection = nil;
    
    // Announce that the data is available
    [self postCoalescingNotificationWithName:HLSRequesterAllRetrievedNotification];
}

@end
