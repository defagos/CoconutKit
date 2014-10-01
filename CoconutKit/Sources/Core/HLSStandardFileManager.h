//
//  HLSStandardFileManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSFileManager.h"

/**
 * A standard NSFileManager-based file manager, built upon +[NSFileManager defaultManager]
 */
@interface HLSStandardFileManager : HLSFileManager

/**
 * Return the default instance (with root folder /)
 */
+ (instancetype)defaultManager;

/**
 * Create a file manager, using the specified root folder path (relative to the system file hierarchy) as root.
 * If rootFolderPath is nil, uses / as root (this is equivalent to calling -init). The folder will be automatically
 * created if it does not exist
 */
- (instancetype)initWithRootFolderPath:(NSString *)rootFolderPath NS_DESIGNATED_INITIALIZER;

@end
