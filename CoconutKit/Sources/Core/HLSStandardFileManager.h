//
//  HLSStandardFileManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSFileManager.h"

/**
 * A standard NSFileManager-based file manager, built upon +[NSFileManager defaultManager]
 *
 * Designated initializer: -initWithRootFolderPath:
 */
@interface HLSStandardFileManager : HLSFileManager

/**
 * Return the default instance (with root folder /)
 */
+ (HLSStandardFileManager *)defaultManager;

/**
 * Create a file manager, using the specified root folder path (relative to the system file hierarchy) as root.
 * If rootFolderPath is nil, uses / as root (this is equivalent to calling -init). The folder will be automatically
 * created if it does not exist
 */
- (id)initWithRootFolderPath:(NSString *)rootFolderPath;

@end
