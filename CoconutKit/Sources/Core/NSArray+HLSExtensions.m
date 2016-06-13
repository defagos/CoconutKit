//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSArray+HLSExtensions.h"

@implementation NSArray (HLSExtensions)

- (NSArray *)hls_arrayByRemovingLastObject
{
    NSMutableArray *array = [self mutableCopy];
    [array removeLastObject];
    return [array copy];
}

- (NSArray *)hls_arrayByLeftRotatingNumberOfObjects:(NSUInteger)numberOfObjects
{
    if (numberOfObjects == 0) {
        return self;
    }
    
    NSUInteger shift = numberOfObjects % self.count;
    return [self hls_arrayByShiftingNumberOfObjects:shift];
}

- (NSArray *)hls_arrayByRightRotatingNumberOfObjects:(NSUInteger)numberOfObjects
{
    if (numberOfObjects == 0) {
        return self;
    }
    
    NSUInteger shift = numberOfObjects % self.count;
    return [self hls_arrayByShiftingNumberOfObjects:self.count - shift];
}

- (NSArray *)hls_arrayByShiftingNumberOfObjects:(NSUInteger)numberOfObjects
{
    return [[self subarrayWithRange:NSMakeRange(numberOfObjects, self.count - numberOfObjects)]
            arrayByAddingObjectsFromArray:[self subarrayWithRange:NSMakeRange(0, numberOfObjects)]];
}

- (NSArray *)hls_sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSArray *sortDescriptors = sortDescriptor ? @[sortDescriptor] : nil;
    return [self sortedArrayUsingDescriptors:sortDescriptors];
}

@end
