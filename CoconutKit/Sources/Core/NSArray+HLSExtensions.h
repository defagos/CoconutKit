//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (HLSExtensions)

/**
 * Return the array obtained by removing the last object
 */
- (NSArray<ObjectType> *)hls_arrayByRemovingLastObject;

/**
 * Return the array obtained by rotating receiver elements left or right (elements disappearing at an end are moved to 
 * the other end)
 */
- (NSArray<ObjectType> *)hls_arrayByLeftRotatingNumberOfObjects:(NSUInteger)numberOfElements;
- (NSArray<ObjectType> *)hls_arrayByRightRotatingNumberOfObjects:(NSUInteger)numberOfElements;

/**
 * Sort an array using a single descriptor
 */
- (NSArray<ObjectType> *)hls_sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end

NS_ASSUME_NONNULL_END
