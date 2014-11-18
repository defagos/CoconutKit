//
//  NSArray+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

@interface NSArray (HLSExtensions)

/**
 * Return the array obtained by removing the last object
 */
- (NSArray *)arrayByRemovingLastObject;

/**
 * Return the array obtained by rotating receiver elements left or right (elements disappearing at an end are moved to 
 * the other end)
 */
- (NSArray *)arrayByLeftRotatingNumberOfObjects:(NSUInteger)numberOfElements;
- (NSArray *)arrayByRightRotatingNumberOfObjects:(NSUInteger)numberOfElements;

/**
 * Sort an array using a single descriptor
 */
- (NSArray *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end
