//
//  NSNumber+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 17.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "NSNumber+HLSExtensionsTestCase.h"

@implementation NSNumber_HLSExtensionsTestCase

- (void)testNumberComparisons
{
    GHAssertTrue([[@1 minimumNumber:@2] isEqualToNumber:@1], nil);
    GHAssertTrue([[@1 maximumNumber:@2] isEqualToNumber:@2], nil);
    
    GHAssertTrue([@1 isLessThanNumber:@2], nil);
    
    GHAssertTrue([@1 isLessThanOrEqualToNumber:@2], nil);
    GHAssertTrue([@1 isLessThanOrEqualToNumber:@1], nil);
    
    GHAssertTrue([@2 isGreaterThanNumber:@1], nil);
    
    GHAssertTrue([@2 isGreaterThanOrEqualToNumber:@1], nil);
    GHAssertTrue([@2 isGreaterThanOrEqualToNumber:@1], nil);
}

@end
