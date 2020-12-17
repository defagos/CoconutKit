//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 * NSManagedObject does not implement the NSCopying protocol. Instead, you can have your managed objects
 * implement the HLSManagedObjectCopying protocol. Objects implementing this protocol can be copied
 * (within a single context) using the HLSModelManager -copyObject: method. Refer to the documentation
 * of this method for the copy behavior which is applied
 */
@protocol HLSManagedObjectCopying <NSObject>

@optional

/**
 * If some keys need to be excluded during copy, simply implement this method to return the corresponding
 * name strings
 */
@property (nonatomic, readonly, nullable) NSSet *keysToExclude;

@end

NS_ASSUME_NONNULL_END
