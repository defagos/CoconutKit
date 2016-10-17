//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <CoconutKit/CoconutKit.h>
#import <XCTest/XCTest.h>

@interface NSString_HLSExtensionsTestCase : XCTestCase
@end

@implementation NSString_HLSExtensionsTestCase

#pragma mark Tests

- (void)testTrim
{
    NSString *string = [NSString stringWithFormat:@" \t    Hello, World!    \t   "];
    XCTAssertEqualObjects(string.stringByTrimmingWhitespaces, @"Hello, World!");
    
    XCTAssertFalse(@"".filled);
    XCTAssertFalse(@"     \t  ".filled);
    XCTAssertTrue(@"  abc  ".filled);
}

- (void)testHashMethods
{
    XCTAssertEqualObjects(@"Hello, World!".md2hash, @"1c8f1e6a94aaa7145210bf90bb52871a");
    XCTAssertEqualObjects(@"Hello, World!".md4hash, @"94e3cb0fa9aa7a5ee3db74b79e915989");
    XCTAssertEqualObjects(@"Hello, World!".md5hash, @"65a8e27d8879283831b664bd8b7f0ad4");
    XCTAssertEqualObjects(@"Hello, World!".sha1hash, @"0a0a9f2a6772942557ab5355d76af442f8f65e01");
    XCTAssertEqualObjects(@"Hello, World!".sha224hash, @"72a23dfa411ba6fde01dbfabf3b00a709c93ebf273dc29e2d8b261ff");
    XCTAssertEqualObjects(@"Hello, World!".sha256hash, @"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f");
    XCTAssertEqualObjects(@"Hello, World!".sha384hash, @"5485cc9b3365b4305dfb4e8337e0a598a574f8242bf17289e0dd6c20a3cd44a089de16ab4ab308f63e44b1170eb5f515");
    XCTAssertEqualObjects(@"Hello, World!".sha512hash, @"374d794a95cdcfd8b35993185fef9ba368f160d8daf432d08ba9f1ed1e5abe6cc69291e0fa2fe0006a52570ef18c19def4e617c33ce52ef0a6e5fbe318cb0387");
}

- (void)testFriendlyVersionNumber
{
    XCTAssertEqualObjects(@"0.8".friendlyVersionNumber, @"0.8");
    XCTAssertEqualObjects(@"0.8+dev".friendlyVersionNumber, @"0.8+dev");
    XCTAssertEqualObjects(@"0.9+1.0b1".friendlyVersionNumber, @"1.0b1");
    XCTAssertEqualObjects(@"0.9+1.0b1+dev".friendlyVersionNumber, @"0.9+1.0b1+dev");
    XCTAssertEqualObjects(@"0.9.1+1.0rc2".friendlyVersionNumber, @"1.0rc2");
    XCTAssertEqualObjects(@"1.0".friendlyVersionNumber, @"1.0");
    XCTAssertEqualObjects(@"1.0+test".friendlyVersionNumber, @"1.0+test");
}

- (void)testMIMEType
{
    XCTAssertEqualObjects(@"/path/to/file.png".MIMEType, @"image/png");
    XCTAssertEqualObjects(@"/path/to/file.PNG".MIMEType, @"image/png");
    XCTAssertEqualObjects(@"/path/to/file.jpg".MIMEType, @"image/jpeg");
    XCTAssertEqualObjects(@"/path/to/file.JPG".MIMEType, @"image/jpeg");
    XCTAssertEqualObjects(@"/path/to/file.txt".MIMEType, @"text/plain");
    XCTAssertEqualObjects(@"/path/to/file.TXT".MIMEType, @"text/plain");
    XCTAssertEqualObjects(@"/path/to/file.pdf".MIMEType, @"application/pdf");
    XCTAssertEqualObjects(@"/path/to/file.PDF".MIMEType, @"application/pdf");
}

@end
