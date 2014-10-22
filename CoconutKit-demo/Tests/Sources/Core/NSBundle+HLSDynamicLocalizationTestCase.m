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
    GHAssertEqualStrings(HLSLanguageForLocalization(@"de"), @"Deutsch", nil);
    GHAssertEqualStrings(HLSLanguageForLocalization(@"en"), @"English", nil);
}

- (void)testLocalizedStrings
{
    GHAssertEqualStrings(HLSLocalizedStringFromUIKit(@"Cancel"), @"Cancel", nil);
    GHAssertEqualStrings(HLSLocalizedStringFromUIKit(@"Unknown code, yeah yeah"), HLSMissingLocalization, nil);
    
    GHAssertEqualStrings(HLSLocalizedDescriptionForCFNetworkError(kCFURLErrorCannotConnectToHost), @"Could not connect to the server.", nil);
    GHAssertEqualStrings(HLSLocalizedDescriptionForCFNetworkError(123456), HLSMissingLocalization, nil);
}

@end
