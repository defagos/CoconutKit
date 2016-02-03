//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSBundle+HLSDynamicLocalizationTestCase.h"

// Just needed for an error constant
#import <CFNetwork/CFNetwork.h>

@implementation NSBundle_HLSDynamicLocalizationTestCase

- (void)testLanguageForLocalization
{
    XCTAssertEqualObjects(HLSLanguageForLocalization(@"de"), @"Deutsch");
    XCTAssertEqualObjects(HLSLanguageForLocalization(@"en"), @"English");
}

- (void)testLocalizedStrings
{
    XCTAssertEqualObjects(HLSLocalizedStringFromUIKit(@"Cancel"), @"Cancel");
    XCTAssertEqualObjects(HLSLocalizedStringFromUIKit(@"Unknown code, yeah yeah"), HLSMissingLocalization);
    
    XCTAssertEqualObjects(HLSLocalizedDescriptionForCFNetworkError(kCFURLErrorCannotConnectToHost), @"Could not connect to the server.");
    XCTAssertEqualObjects(HLSLocalizedDescriptionForCFNetworkError(123456), HLSMissingLocalization);
}

@end
