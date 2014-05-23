//
//  NSMutableArray+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.05.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

@interface NSMutableArray (HLSExtensions)

/**
 * Same as -addObject:, but does not attempt to insert nil objects
 */
- (void)safelyAddObject:(id)object;

/**
 * Sort an array using a single descriptor
 */
- (void)sortUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end
