//
//  HLSApplicationInformation.h
//  CoconutKit
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Return the application Library directory
 */
NSString *HLSApplicationLibraryDirectoryPath(void);
NSURL *HLSApplicationLibraryDirectoryURL(void);

/**
 * Return the application Documents directory
 */
NSString *HLSApplicationDocumentDirectoryPath(void);
NSURL *HLSApplicationDocumentDirectoryURL(void);

/**
 * Return the application temporary directory
 */
NSString *HLSApplicationTemporaryDirectoryPath(void);
NSURL *HLSApplicationTemporaryDirectoryURL(void);

/**
 * Return the application inbox directory (location where files using Open in... are saved)
 */
NSString *HLSApplicationInboxDirectoryPath(void);
NSURL *HLSApplicationInboxDirectoryURL(void);
