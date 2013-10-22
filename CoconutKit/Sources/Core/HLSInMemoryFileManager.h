//
//  HLSInMemoryFileManager.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 18.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * A file manager implementation storing data in memory
 */
@interface HLSInMemoryFileManager : HLSFileManager <NSCacheDelegate>

/**
 * Size of the data cache above which the cache might be cleaned (refer to the corresponding NSCache method
 * documentation for more information). When data is added to the cache, its size is used as cost
 *
 * Default value is 0 (no limit)
 */
@property (nonatomic, assign) NSUInteger totalCostLimit;

@end
