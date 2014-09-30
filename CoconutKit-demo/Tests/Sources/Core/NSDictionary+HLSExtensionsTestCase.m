//
//  NSDictionary+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSDictionary+HLSExtensionsTestCase.h"

@implementation NSDictionary_HLSExtensionsTestCase

#pragma mark Tests

- (void)testReturnModified
{
    NSDictionary *dictionary1 = @{};
    dictionary1 = [dictionary1 dictionaryBySettingObject:@"obj1" forKey:@"key1"];
    GHAssertEqualStrings([dictionary1 objectForKey:@"key1"], @"obj1", nil);
    dictionary1 = [dictionary1 dictionaryByRemovingObjectForKey:@"key1"];
    GHAssertEquals([dictionary1 count], (NSUInteger)0, nil);
    
    NSDictionary *dictionary2 = @{ @"key1" : @"obj1", @"key2" : @"obj2" };
    dictionary2 = [dictionary2 dictionaryByRemovingObjectsForKeys:@[@"key1", @"key2"]];
    GHAssertEquals([dictionary2 count], (NSUInteger)0, nil);
}

- (void)testSafeInsert
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary safelySetObject:nil forKey:@"key"];
    [dictionary safelySetObject:@"obj" forKey:nil];
    GHAssertEquals([dictionary count], (NSUInteger)0, nil);
}

@end
