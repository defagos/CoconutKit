//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import CFNetwork;
@import CoconutKit;
@import XCTest;

@interface NSBundle_HLSDynamicLocalizationTestCase : XCTestCase
@end

@implementation NSBundle_HLSDynamicLocalizationTestCase

- (void)testLanguageForLocalization
{
    XCTAssertEqualObjects(HLSLanguageForLocalization(@"de"), @"Deutsch");
    XCTAssertEqualObjects(HLSLanguageForLocalization(@"en"), @"English");
}

- (void)testLocalizedStrings
{
    XCTAssertEqualObjects(HLSLocalizedDescriptionForCFNetworkError(kCFURLErrorCannotConnectToHost), @"Could not connect to the server.");
    XCTAssertEqualObjects(HLSLocalizedDescriptionForCFNetworkError(123456), HLSMissingLocalization);
}

@end
