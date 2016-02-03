//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSDictionary+HLSExtensionsTestCase.h"

@implementation NSDictionary_HLSExtensionsTestCase

#pragma mark Tests

- (void)testReturnModified
{
    NSDictionary *dictionary1 = @{};
    dictionary1 = [dictionary1 dictionaryBySettingObject:@"obj1" forKey:@"key1"];
    XCTAssertEqualObjects([dictionary1 objectForKey:@"key1"], @"obj1");
    dictionary1 = [dictionary1 dictionaryByRemovingObjectForKey:@"key1"];
    XCTAssertEqual([dictionary1 count], (NSUInteger)0);
    
    NSDictionary *dictionary2 = @{ @"key1" : @"obj1", @"key2" : @"obj2" };
    dictionary2 = [dictionary2 dictionaryByRemovingObjectsForKeys:@[@"key1", @"key2"]];
    XCTAssertEqual([dictionary2 count], (NSUInteger)0);
}

- (void)testSafeInsert
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary safelySetObject:nil forKey:@"key"];
    [dictionary safelySetObject:@"obj" forKey:nil];
    XCTAssertEqual([dictionary count], (NSUInteger)0);
}

@end
