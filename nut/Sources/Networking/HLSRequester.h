//
//  HLSRequester.h
//  nut
//
//  Created by Samuel DEFAGO on 04.06.10.
//  Copyright 2010 Hortis. All rights reserved.
// 

#import "HLSNotifications.h"

// Download status
typedef enum {
    HLSRequesterStatusEnumBegin = 0,                                   // (BEGIN)
    HLSRequesterStatusIdle = HLSRequesterStatusEnumBegin,              // Not downloading
    HLSRequesterStatusRetrieving,                                      // Currently downloading file
    HLSRequesterStatusDone,                                            // The whole file has been downloaded
    HLSRequesterStatusEnumEnd,                                         // (END)
    HLSRequesterStatusEnumSize = HLSRequesterStatusEnumEnd - HLSRequesterStatusEnumBegin
} HLSRequesterStatus;

// HLSNotifications
HLSDeclareNotification(HLSRequesterAllRetrievedNotification);
HLSDeclareNotification(HLSRequesterChunkRetrievedNotification);
HLSDeclareNotification(HLSRequesterFailureNotification);

/**
 * Class for managing a request process. A request is initialized by specifying a URL request. The request
 * process itself must then be manually started. Notifications are sent when a data chunk is retrieved, 
 * and of course when the request has fully been processed. At any time the current progress status and
 * the current data (even if only partial) can be queried.
 *
 * Having an NSURLRequest as base object processed by a requester allows us to implement many different kinds
 * of requests (e.g. downloading a file, or communicating with a web service) easily since the logic behind is
 * the same.
 *
 * To let callers identify their requests more easily, an optional tag property is provided.
 *
 * This class is currently not thread-safe, and no MT support is planned: HLSRequester should be
 * used by a thread running its run loop, and the notifications will be consumed as run loop events.
 *
 * Designated initializer: initWithURLRequest:
 */
// TODO: Must provide a way to access the encoding of the answer (e.g. gzip, plain, etc.). Extracted from NSURLResponse,
//       but see how this information can best be made available
// TODO: Add a method to cancel a request (add it to HLSDownloader as well)
@interface HLSRequester : NSObject {
@private
    NSURLRequest *m_request;
    NSString *m_tag;
    NSURLConnection *m_connection;
    NSMutableData *m_data;
    HLSRequesterStatus m_status;
    long long m_expectedContentLength;
}

- (id)initWithRequest:(NSURLRequest *)request;

/**
 * Start the request process
 */
- (void)start;

/**
 * Return the data only when it has been fully fetched, nil otherwise
 */
- (NSData *)fetchData;

/**
 * Return the data as currently fetched (if the data has been completely retrieved, the result is the same
 * as calling fetchData)
 */
- (NSData *)fetchPartialData;

/**
 * Return the estimated completion rate (float between 0 and 1). If the total download size is not available, then the
 * completion will stay at 0.1 until the download is done.
 */
- (float)progress;

/**
 * Optional tag for identifying requests
 */
@property (nonatomic, retain) NSString *tag;

@end
