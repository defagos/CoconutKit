//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (HLSExtensions)

/**
 * Return the array obtained by removing the last object
 */
- (NSArray<ObjectType> *)arrayByRemovingLastObject;

/**
 * Return the array obtained by rotating receiver elements left or right (elements disappearing at an end are moved to 
 * the other end)
 */
- (NSArray<ObjectType> *)arrayByLeftRotatingNumberOfObjects:(NSUInteger)numberOfElements;
- (NSArray<ObjectType> *)arrayByRightRotatingNumberOfObjects:(NSUInteger)numberOfElements;

/**
 * Sort an array using a single descriptor
 */
- (NSArray<ObjectType> *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end

NS_ASSUME_NONNULL_END
