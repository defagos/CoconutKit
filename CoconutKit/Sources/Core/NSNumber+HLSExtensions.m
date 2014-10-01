//
//  NSNumber+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 17.06.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "NSNumber+HLSExtensions.h"

@implementation NSNumber (HLSExtensions)

#pragma mark Convenience methods

- (NSNumber *)minimumNumber:(NSNumber *)anotherNumber
{
    return [self isLessThanOrEqualToNumber:anotherNumber] ? self : anotherNumber;
}

- (NSNumber *)maximumNumber:(NSNumber *)anotherNumber
{
    return [self isGreaterThanOrEqualToNumber:anotherNumber] ? self : anotherNumber;
}

- (BOOL)isLessThanNumber:(NSNumber *)number
{
    return [self compare:number] == NSOrderedAscending;
}

- (BOOL)isLessThanOrEqualToNumber:(NSNumber *)number
{
    return [self compare:number] != NSOrderedDescending;
}

- (BOOL)isGreaterThanNumber:(NSNumber *)number
{
    return [self compare:number] == NSOrderedDescending;
}

- (BOOL)isGreaterThanOrEqualToNumber:(NSNumber *)number
{
    return [self compare:number] != NSOrderedAscending;
}

@end
