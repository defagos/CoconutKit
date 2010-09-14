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
DECLARE_NOTIFICATION(HLSDownloaderAllRetrievedNotification);
DECLARE_NOTIFICATION(HLSDownloaderChunkRetrievedNotification);
DECLARE_NOTIFICATION(HLSDownloaderFailureNotification);

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
 * Return the estimated completion rate (float between 0 and 1). Might not be reliable, in which case only 0
 * (not completely downloaded) or 1 (downloaded) are returned
 */
- (NSNumber *)progress;        // float

/**
 * Optional tag for identifying downloads
 */
@property (nonatomic, copy) NSString *tag;

@end
