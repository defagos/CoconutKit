//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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
    NSParameterAssert(number);
    return [self compare:number] == NSOrderedAscending;
}

- (BOOL)isLessThanOrEqualToNumber:(NSNumber *)number
{
    NSParameterAssert(number);
    return [self compare:number] != NSOrderedDescending;
}

- (BOOL)isGreaterThanNumber:(NSNumber *)number
{
    NSParameterAssert(number);
    return [self compare:number] == NSOrderedDescending;
}

- (BOOL)isGreaterThanOrEqualToNumber:(NSNumber *)number
{
    NSParameterAssert(number);
    return [self compare:number] != NSOrderedAscending;
}

@end
