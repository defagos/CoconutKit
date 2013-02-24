//
//  HLSMockDiskConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/6/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSURLConnection.h"

/**
 * A connection managing file URL requests only (creation fails if the URLRequest is not a file URL request). It returns
 * the NSArray of all corresponding file paths as responseObject:
 *   - If the URL is a directory, then the file paths of all files and folders within it are returned
 *   - If the URL is a file, then its path is returned
 * The duration of the connection is random between 0 and 1 second
 *
 * Two environment variables can be set to simulate connection issues:
 *   - HLSMockDiskConnectionLatency: A latency duration which gets added to each connection, in seconds
 *   - HLSMockDiskConnectionFailureRate: A failure rate (between 0 and 1)
 */
@interface HLSMockDiskConnection : HLSURLConnection
@end
