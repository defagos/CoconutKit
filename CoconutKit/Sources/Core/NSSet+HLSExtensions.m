//
//  NSSet+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 30.05.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "NSSet+HLSExtensions.h"

@implementation NSSet (HLSExtensions)

- (NSArray *)sortedArrayUsingDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSArray *sortDescriptors = sortDescriptor ? @[sortDescriptor] : nil;
    return [self sortedArrayUsingDescriptors:sortDescriptors];
}

@end
