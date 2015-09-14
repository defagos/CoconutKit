//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSURLConnection.h"

#import <Foundation/Foundation.h>

/**
 * A connection managing file URL requests only (creation fails if the URLRequest is not a file URL request). It returns
 * the NSArray of all corresponding file paths as responseObject:
 *   - If the URL is a directory, then the file paths of all files and folders within it are returned. If the directory
 *     is empty, an empty array is returned
 *   - If the URL is a file, then its path is returned
 *   - If the URL does not refer to a valid file, responseObject is nil
 * The duration of the connection is random between 0 and 1 second
 *
 * Two environment variables can be set to simulate connection issues:
 *   - HLSFileURLConnectionLatency: A latency duration which gets added to each connection, in seconds
 *   - HLSFileURLConnectionFailureRate: A failure rate (between 0 and 1)
 */
@interface HLSFileURLConnection : HLSURLConnection
@end
