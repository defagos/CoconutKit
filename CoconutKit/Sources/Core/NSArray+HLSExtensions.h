//
//  NSArray+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@protocol NSArray_HLSExtensions <NSObject>

@optional
/**
 * Returns the first object in the array, or nil if the array is empty
 *
 * Remark: This method has been made public with the iOS 7 SDK, and for iOS 4 and above (in fact, the method
 *         existed privately since iOS 4)
 */
- (id)firstObject;

@end

@interface NSArray (HLSExtensions) <NSArray_HLSExtensions>

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
