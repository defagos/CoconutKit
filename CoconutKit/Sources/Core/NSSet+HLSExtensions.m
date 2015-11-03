//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSSet+HLSExtensions.h"

@implementation NSSet (HLSExtensions)

- (NSArray *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSParameterAssert(sortDescriptor);
    return [self sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
