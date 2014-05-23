//
//  NSData+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 29.05.12.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSData+HLSExtensionsTestCase.h"

@implementation NSData_HLSExtensionsTestCase

#pragma mark Tests

- (void)testBase64Encoding
{
    NSData *testData = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];
    GHAssertEqualStrings([testData base64EncodedString], @"SGVsbG8sIFdvcmxkIQ==", nil);
    
    NSString *testString = [[NSString alloc] initWithData:[NSData dataWithBase64EncodedString:@"SGVsbG8sIFdvcmxkIQ=="] encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(testString, @"Hello, World!", nil);
}

- (void)testHashMethods
{
    NSData *testData = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];
    
    GHAssertEqualStrings([testData md2hash], @"1c8f1e6a94aaa7145210bf90bb52871a", nil);
    GHAssertEqualStrings([testData md4hash], @"94e3cb0fa9aa7a5ee3db74b79e915989", nil);
    GHAssertEqualStrings([testData md5hash], @"65a8e27d8879283831b664bd8b7f0ad4", nil);
    GHAssertEqualStrings([testData sha1hash], @"0a0a9f2a6772942557ab5355d76af442f8f65e01", nil);
    GHAssertEqualStrings([testData sha224hash], @"72a23dfa411ba6fde01dbfabf3b00a709c93ebf273dc29e2d8b261ff", nil);
    GHAssertEqualStrings([testData sha256hash], @"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f", nil);
    GHAssertEqualStrings([testData sha384hash], @"5485cc9b3365b4305dfb4e8337e0a598a574f8242bf17289e0dd6c20a3cd44a089de16ab4ab308f63e44b1170eb5f515", nil);
    GHAssertEqualStrings([testData sha512hash], @"374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387", nil);
}

@end
