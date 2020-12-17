//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSSet<__covariant ObjectType> (HLSExtensions)

/**
 * Sort an array using a single descriptor
 */
- (NSArray<ObjectType> *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end

NS_ASSUME_NONNULL_END
