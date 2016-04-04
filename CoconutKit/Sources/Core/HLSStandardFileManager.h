//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSFileManager.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A standard NSFileManager-based file manager, built upon +[NSFileManager defaultManager]
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
- (nullable instancetype)initWithRootFolderPath:(nullable NSString *)rootFolderPath NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
