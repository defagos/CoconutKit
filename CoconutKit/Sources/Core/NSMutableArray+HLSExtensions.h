//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

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
