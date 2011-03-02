//
//  HLSDownloader.h
//  nut
//
//  Created by Samuel DEFAGO on 04.06.10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSNotifications.h"

// Forward declarations
@class HLSRequester;

// Notifications
HLSDeclareNotification(HLSDownloaderAllRetrievedNotification);
HLSDeclareNotification(HLSDownloaderChunkRetrievedNotification);
HLSDeclareNotification(HLSDownloaderFailureNotification);

/**
 * Class for managing a download process. Thin wrapper around an HLSRequester object (please refer to the
 * documentation of this class for more information)
 *
 * Designated initializer: initWithURL:
 */
@interface HLSDownloader : NSObject {
@private
    HLSRequester *m_requester;
}

- (id)initWithURL:(NSURL *)url;

/**
 * Start the download process
 */
- (void)start;

/**
 * Return the data only when it has been fully fetched, nil otherwise
 */
- (NSData *)fetchData;

/**
 * Return the data as currently fetched (if the data has been completely downloaded, the result is the same
 * as calling fetchData)
 */
- (NSData *)fetchPartialData;

/**
 * Return the estimated completion rate (float between 0 and 1). If the total download size is not available, then the
 * completion will stay at 0.1 until the download is done.
 */
- (float)progress;

/**
 * Optional tag for identifying downloads
 */
@property (nonatomic, retain) NSString *tag;

@end
