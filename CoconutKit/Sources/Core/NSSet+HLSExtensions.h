//
//  NSSet+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.05.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

@interface NSSet (HLSExtensions)

/**
 * Sort an array using a single descriptor
 */
- (NSArray *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor;

@end
