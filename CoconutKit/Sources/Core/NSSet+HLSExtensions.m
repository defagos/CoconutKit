//
//  NSSet+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.05.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "NSSet+HLSExtensions.h"

@implementation NSSet (HLSExtensions)

- (NSArray *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSArray *sortDescriptors = sortDescriptor ? [NSArray arrayWithObject:sortDescriptor] : nil;
    return [self sortedArrayUsingDescriptors:sortDescriptors];
}

@end
