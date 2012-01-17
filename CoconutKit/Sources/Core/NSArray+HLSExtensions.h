//
//  NSArray+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSArray (HLSExtensions)

/**
 * Returns the first object in the array, or nil if the array is empty
 */
- (id)firstObject;

/**
 * Rotate array elements left or right (elements disappearing at an end are moved to the other end)
 */
- (NSArray *)arrayByLeftRotatingNumberOfObjects:(NSUInteger)numberOfElements;
- (NSArray *)arrayByRightRotatingNumberOfObjects:(NSUInteger)numberOfElements;

/**
 * Sort an array using a single descriptor
 */
- (NSArray *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end

@interface NSMutableArray (HLSExtensions)

/**
 * Same as addObject:, but does not attempt to insert nil objects
 */
- (void)safelyAddObject:(id)object;

@end
