//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSURLConnection.h"

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef void (^HLSConnectionArrayCompletionBlock)(HLSConnection *connection, NSArray<NSURL *> * __nullable fileURLs, NSError * __nullable error);

/**
 * A connection managing file URL requests only (the URLRequest must be a file URL request). It returns the NSArray of 
 * all corresponding file paths as responseObject:
 *   - If the URL is a directory, then the file paths of all files and folders within it are returned. If the directory
 *     is empty, an empty array is returned
 *   - If the URL is a file, then its path is returned
 *   - If the URL does not refer to a valid file, responseObject is nil
 * The duration of the connection is random between 0 and 1 second
 *
 * If the connection is cancelled, the completion block is called with the NSURLErrorCancelled error code in the
 * NSURLErrorDomain domain.
 *
 * Two environment variables can be set to simulate connection issues:
 *   - HLSFileURLConnectionLatency: A latency duration which gets added to each connection, in seconds
 *   - HLSFileURLConnectionFailureRate: A failure rate (between 0 and 1)
 */
@interface HLSFileURLConnection : HLSURLConnection

- (instancetype)initWithRequest:(NSURLRequest *)request completionBlock:(HLSConnectionArrayCompletionBlock)completionBlock NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
