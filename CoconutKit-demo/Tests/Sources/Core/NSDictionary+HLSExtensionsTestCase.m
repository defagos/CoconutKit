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
    NSDictionary *dictionary1 = [NSDictionary dictionary];
    dictionary1 = [dictionary1 dictionaryBySettingObject:@"obj1" forKey:@"key1"];
    GHAssertEqualStrings([dictionary1 objectForKey:@"key1"], @"obj1", nil);
    dictionary1 = [dictionary1 dictionaryByRemovingObjectForKey:@"key1"];
    GHAssertEquals([dictionary1 count], (NSUInteger)0, nil);
    
    NSDictionary *dictionary2 = [NSDictionary dictionaryWithObjectsAndKeys:@"obj1", @"key1", @"obj2", @"key2", nil];
    dictionary2 = [dictionary2 dictionaryByRemovingObjectsForKeys:[NSArray arrayWithObjects:@"key1", @"key2", nil]];
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
