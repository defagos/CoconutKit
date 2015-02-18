//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSMutableArray+HLSExtensions.h"

@implementation NSMutableArray (HLSExtensions)

- (void)safelyAddObject:(id)object
{
    if (! object) {
        return;
    }
    [self addObject:object];
}

- (void)sortUsingDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSArray *sortDescriptors = sortDescriptor ? @[sortDescriptor] : nil;
    return [self sortUsingDescriptors:sortDescriptors];
}

@end
