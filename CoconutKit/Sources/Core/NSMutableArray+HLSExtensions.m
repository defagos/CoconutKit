//
//  NSMutableArray+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.05.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
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
