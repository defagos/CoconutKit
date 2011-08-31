//
//  NSString+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 23.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSString+HLSExtensionsTestCase.h"

@implementation NSString_HLSExtensionsTestCase

#pragma mark Tests

- (void)testTrim
{
    NSString *string = [NSString stringWithFormat:@" \t    Hello, World!    \t   "];
    GHAssertEqualStrings([string stringByTrimmingWhitespaces], @"Hello, World!", @"trim");
    
    GHAssertFalse([@"" isFilled], @"!filled");
    GHAssertFalse([@"     \t  " isFilled], @"!filled");
    GHAssertTrue([@"  abc  " isFilled], @"filled");
}

- (void)testHashMethods
{
    GHAssertEqualStrings([@"Hello, World!" md2hash], @"1c8f1e6a94aaa7145210bf90bb52871a", @"md2");
    GHAssertEqualStrings([@"Hello, World!" md4hash], @"94e3cb0fa9aa7a5ee3db74b79e915989", @"md4");
    GHAssertEqualStrings([@"Hello, World!" md5hash], @"65a8e27d8879283831b664bd8b7f0ad4", @"md5");
    GHAssertEqualStrings([@"Hello, World!" sha1hash], @"0a0a9f2a6772942557ab5355d76af442f8f65e01", @"sha1");
    GHAssertEqualStrings([@"Hello, World!" sha224hash], @"72a23dfa411ba6fde01dbfabf3b00a709c93ebf273dc29e2d8b261ff", @"sha224");
    GHAssertEqualStrings([@"Hello, World!" sha256hash], @"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f", @"sha256");
    GHAssertEqualStrings([@"Hello, World!" sha384hash], @"5485cc9b3365b4305dfb4e8337e0a598a574f8242bf17289e0dd6c20a3cd44a089de16ab4ab308f63e44b1170eb5f515", @"sha384");
    GHAssertEqualStrings([@"Hello, World!" sha512hash], @"374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387", @"sha512");
}

- (void)testFriendlyVersionNumber
{
    GHAssertEqualStrings([@"0.8" friendlyVersionNumber], @"0.8", @"version number");
    GHAssertEqualStrings([@"0.8+dev" friendlyVersionNumber], @"0.8+dev", @"version number");
    GHAssertEqualStrings([@"0.9+1.0b1" friendlyVersionNumber], @"1.0b1", @"version number");
    GHAssertEqualStrings([@"0.9+1.0b1+dev" friendlyVersionNumber], @"0.9+1.0b1+dev", @"version number");
    GHAssertEqualStrings([@"0.9.1+1.0rc2" friendlyVersionNumber], @"1.0rc2", @"version number");
    GHAssertEqualStrings([@"1.0" friendlyVersionNumber], @"1.0", @"version number");
    GHAssertEqualStrings([@"1.0+test" friendlyVersionNumber], @"1.0+test", @"version number");
}

@end
