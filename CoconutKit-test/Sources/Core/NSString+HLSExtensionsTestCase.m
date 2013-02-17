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
    GHAssertEqualStrings([string stringByTrimmingWhitespaces], @"Hello, World!", nil);
    
    GHAssertFalse([@"" isFilled], nil);
    GHAssertFalse([@"     \t  " isFilled], nil);
    GHAssertTrue([@"  abc  " isFilled], nil);
}

- (void)testHashMethods
{
    GHAssertEqualStrings([@"Hello, World!" md2hash], @"1c8f1e6a94aaa7145210bf90bb52871a", nil);
    GHAssertEqualStrings([@"Hello, World!" md4hash], @"94e3cb0fa9aa7a5ee3db74b79e915989", nil);
    GHAssertEqualStrings([@"Hello, World!" md5hash], @"65a8e27d8879283831b664bd8b7f0ad4", nil);
    GHAssertEqualStrings([@"Hello, World!" sha1hash], @"0a0a9f2a6772942557ab5355d76af442f8f65e01", nil);
    GHAssertEqualStrings([@"Hello, World!" sha224hash], @"72a23dfa411ba6fde01dbfabf3b00a709c93ebf273dc29e2d8b261ff", nil);
    GHAssertEqualStrings([@"Hello, World!" sha256hash], @"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f", nil);
    GHAssertEqualStrings([@"Hello, World!" sha384hash], @"5485cc9b3365b4305dfb4e8337e0a598a574f8242bf17289e0dd6c20a3cd44a089de16ab4ab308f63e44b1170eb5f515", nil);
    GHAssertEqualStrings([@"Hello, World!" sha512hash], @"374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387", nil);
}

- (void)testFriendlyVersionNumber
{
    GHAssertEqualStrings([@"0.8" friendlyVersionNumber], @"0.8", nil);
    GHAssertEqualStrings([@"0.8+dev" friendlyVersionNumber], @"0.8+dev", nil);
    GHAssertEqualStrings([@"0.9+1.0b1" friendlyVersionNumber], @"1.0b1", nil);
    GHAssertEqualStrings([@"0.9+1.0b1+dev" friendlyVersionNumber], @"0.9+1.0b1+dev", nil);
    GHAssertEqualStrings([@"0.9.1+1.0rc2" friendlyVersionNumber], @"1.0rc2", nil);
    GHAssertEqualStrings([@"1.0" friendlyVersionNumber], @"1.0", nil);
    GHAssertEqualStrings([@"1.0+test" friendlyVersionNumber], @"1.0+test", nil);
}

- (void)testURLEncoding
{
    NSMutableString *string = [NSMutableString string];
    for (UniChar character = 0; character <= 255; character++) {
        [string appendFormat:@"%c", character];
    }
    NSString *encodedStringReference = @"%01%02%03%04%05%06%07%08%09%0A%0B%0C%0D%0E%0F%10%11%12%13%14%15%16%17%18%19%1A%1B%1C%1D%1E%1F%20%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F0123456789%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~%7F%C3%84%C3%85%C3%87%C3%89%C3%91%C3%96%C3%9C%C3%A1%C3%A0%C3%A2%C3%A4%C3%A3%C3%A5%C3%A7%C3%A9%C3%A8%C3%AA%C3%AB%C3%AD%C3%AC%C3%AE%C3%AF%C3%B1%C3%B3%C3%B2%C3%B4%C3%B6%C3%B5%C3%BA%C3%B9%C3%BB%C3%BC%E2%80%A0%C2%B0%C2%A2%C2%A3%C2%A7%E2%80%A2%C2%B6%C3%9F%C2%AE%C2%A9%E2%84%A2%C2%B4%C2%A8%E2%89%A0%C3%86%C3%98%E2%88%9E%C2%B1%E2%89%A4%E2%89%A5%C2%A5%C2%B5%E2%88%82%E2%88%91%E2%88%8F%CF%80%E2%88%AB%C2%AA%C2%BA%CE%A9%C3%A6%C3%B8%C2%BF%C2%A1%C2%AC%E2%88%9A%C6%92%E2%89%88%E2%88%86%C2%AB%C2%BB%E2%80%A6%C2%A0%C3%80%C3%83%C3%95%C5%92%C5%93%E2%80%93%E2%80%94%E2%80%9C%E2%80%9D%E2%80%98%E2%80%99%C3%B7%E2%97%8A%C3%BF%C5%B8%E2%81%84%E2%82%AC%E2%80%B9%E2%80%BA%EF%AC%81%EF%AC%82%E2%80%A1%C2%B7%E2%80%9A%E2%80%9E%E2%80%B0%C3%82%C3%8A%C3%81%C3%8B%C3%88%C3%8D%C3%8E%C3%8F%C3%8C%C3%93%C3%94%EF%A3%BF%C3%92%C3%9A%C3%9B%C3%99%C4%B1%CB%86%CB%9C%C2%AF%CB%98%CB%99%CB%9A%C2%B8%CB%9D%CB%9B%CB%87";
    GHAssertEqualStrings([string urlEncodedStringUsingEncoding:NSUTF8StringEncoding], encodedStringReference, nil);
}

@end
