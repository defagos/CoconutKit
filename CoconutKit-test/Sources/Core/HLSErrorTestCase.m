//
//  HLSErrorTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 10.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSErrorTestCase.h"

@interface HLSErrorTestCase ()

@property (nonatomic, retain) HLSError *error1;
@property (nonatomic, retain) HLSError *error2;
@property (nonatomic, retain) HLSError *error3;
@property (nonatomic, retain) HLSError *error4;
@property (nonatomic, retain) HLSError *error5;

@end

@implementation HLSErrorTestCase

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.error1 = nil;
    self.error2 = nil;
    self.error3 = nil;
    self.error4 = nil;
    self.error5 = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize error1 = m_error1;

@synthesize error2 = m_error2;

@synthesize error3 = m_error3;

@synthesize error4 = m_error4;

@synthesize error5 = m_error5;

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    // Error 1
    self.error1 = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test" 
                                       code:1012];
    
    // Error 2
    self.error2 = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:1013 
                       localizedDescription:@"Localized description"];
    [self.error2 setLocalizedFailureReason:@"Localized failure reason"];
    [self.error2 setLocalizedRecoverySuggestion:@"Localized recovery suggestion"];
    [self.error2 setLocalizedRecoveryOptions:[NSArray arrayWithObjects:@"LocalizedRecoveryOption1", 
                                        @"LocalizedRecoveryOption2", 
                                        @"LocalizedRecoveryOption3",
                                        nil]];
    [self.error2 setHelpAnchor:@"Help anchor"];
    [self.error2 setUnderlyingError:self.error1];
    [self.error2 setObject:@"Additional information 1" forKey:@"AdditionalInfo1"];
    [self.error2 setObject:@"Additional information 2" forKey:@"AdditionalInfo2"];
    [self.error2 setObject:@"Additional information 3" forKey:@"AdditionalInfo3"];
    
    // Error 3
    self.error3 = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:1013];
    
    // Error 4
    self.error4 = [HLSError errorWithDomain:@"com.domain.other" code:1013];
    
    // Error 5
    self.error5 = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test" code:7];
}

#pragma mark Tests

- (void)testInformation
{
    GHAssertEqualStrings([self.error1 domain], @"ch.hortis.CoconutKit-test", @"Incorrect domain");
    GHAssertEquals([self.error1 code], 1012, @"Incorrect code");
    
    GHAssertEqualStrings([self.error2 localizedDescription], @"Localized description", @"Incorrect description");
    GHAssertEqualStrings([self.error2 localizedFailureReason], @"Localized failure reason", @"Incorrect failure reason");
    GHAssertEqualStrings([self.error2 localizedRecoverySuggestion], @"Localized recovery suggestion", @"Incorrect recovery suggestion");
    
    GHAssertEqualStrings([self.error2 helpAnchor], @"Help anchor", @"Incorrect help anchor");
    GHAssertEquals([self.error2 underlyingError], self.error1, @"Incorrect underlying error");
    GHAssertEqualStrings([self.error2 objectForKey:@"AdditionalInfo2"], @"Additional information 2", @"Incorrect additional information");
    GHAssertEquals([[self.error2 customUserInfo] count], 3U, @"Incorrect custom user information");
}

- (void)testCopy
{
    NSError *error2Copy = [self.error2 copy];
    
    // The userInfo was deep-copied. Must check some of its information to assert the copy went well
    GHAssertEqualStrings([error2Copy localizedDescription], [self.error2 localizedDescription], @"Incorrect description");
    GHAssertEqualStrings([error2Copy localizedFailureReason], @"Localized failure reason", @"Incorrect failure reason");
}

@end
