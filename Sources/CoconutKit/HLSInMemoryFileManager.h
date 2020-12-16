//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSFileManager.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A file manager implementation storing data in memory. If the application receives a memory warning, this data
 * cache is automatically cleared
 */
@interface HLSInMemoryFileManager : HLSFileManager <NSCacheDelegate>

/**
 * Size of the data cache, in bytes, above which the cache might be cleaned (refer to the -[NSCache setTotalCostLimit:] 
 * method documentation for more information). When data is added to the cache, its size in bytes is used as cost
 *
 * Default value is 0 (no limit)
 */
@property (nonatomic) NSUInteger byteCostLimit;

@end

NS_ASSUME_NONNULL_END
