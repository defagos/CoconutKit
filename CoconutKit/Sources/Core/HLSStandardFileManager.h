//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSFileManager.h"
#import "HLSNullability.h"

#import <Foundation/Foundation.h>

/**
 * A standard NSFileManager-based file manager, built upon +[NSFileManager defaultManager]
 */
NS_ASSUME_NONNULL_BEGIN
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
- (nullable instancetype)initWithRootFolderPath:(nullable NSString *)rootFolderPath NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
