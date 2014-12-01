//
//  NSBundle+HLSDynamicLocalizationTestCase.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
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
