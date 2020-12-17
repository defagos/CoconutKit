//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray<ObjectType> (HLSExtensions)

/**
 * Same as -addObject:, but does not attempt to insert nil objects
 */
- (void)safelyAddObject:(nullable ObjectType)object;

/**
 * Sort an array using a single descriptor
 */
- (void)sortUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end

NS_ASSUME_NONNULL_END
