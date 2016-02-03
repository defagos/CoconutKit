//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
    
/**
 * Return the application Library directory
 */
OBJC_EXPORT NSString *HLSApplicationLibraryDirectoryPath(void);
OBJC_EXPORT NSURL *HLSApplicationLibraryDirectoryURL(void);

/**
 * Return the Caches directory
 */
OBJC_EXPORT NSString *HLSApplicationCachesDirectoryPath(void);
OBJC_EXPORT NSURL *HLSApplicationCachesDirectoryURL(void);

/**
 * Return the application Documents directory
 */
OBJC_EXPORT NSString *HLSApplicationDocumentDirectoryPath(void);
OBJC_EXPORT NSURL *HLSApplicationDocumentDirectoryURL(void);

/**
 * Return the application temporary directory
 */
OBJC_EXPORT NSString *HLSApplicationTemporaryDirectoryPath(void);
OBJC_EXPORT NSURL *HLSApplicationTemporaryDirectoryURL(void);

/**
 * Return the application inbox directory (location where files using Open in... are saved)
 */
OBJC_EXPORT NSString *HLSApplicationInboxDirectoryPath(void);
OBJC_EXPORT NSURL *HLSApplicationInboxDirectoryURL(void);
