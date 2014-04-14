//
//  NSError+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 10.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "NSError+HLSExtensionsTestCase.h"

@interface NSError_HLSExtensionsTestCase ()

@property (nonatomic, retain) NSError *error1;
@property (nonatomic, retain) NSError *error2;
@property (nonatomic, retain) NSError *error3;
@property (nonatomic, retain) NSError *error4;
@property (nonatomic, retain) NSError *error5;

@end

@implementation NSError_HLSExtensionsTestCase

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

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    // Error 1
    self.error1 = [NSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                      code:1012];
    
    // Error 2
    self.error2 = [NSError errorWithDomain:@"ch.hortis.CoconutKit-test"
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
    self.error3 = [NSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                      code:1013];
    
    // Error 4
    self.error4 = [NSError errorWithDomain:@"com.domain.other" code:1013];
    
    // Error 5
    self.error5 = [NSError errorWithDomain:@"ch.hortis.CoconutKit-test" code:7];
}

#pragma mark Tests

- (void)testInformation
{
    GHAssertEqualStrings([self.error1 domain], @"ch.hortis.CoconutKit-test", nil);
    GHAssertEquals([self.error1 code], 1012, nil);
    
    GHAssertEqualStrings([self.error2 localizedDescription], @"Localized description", nil);
    GHAssertEqualStrings([self.error2 localizedFailureReason], @"Localized failure reason", nil);
    GHAssertEqualStrings([self.error2 localizedRecoverySuggestion], @"Localized recovery suggestion", nil);
    
    GHAssertEqualStrings([self.error2 helpAnchor], @"Help anchor", nil);
    GHAssertEquals([self.error2 underlyingError], self.error1, nil);
    GHAssertEqualStrings([self.error2 objectForKey:@"AdditionalInfo2"], @"Additional information 2", nil);
    GHAssertEquals([[self.error2 customUserInfo] count], 3U, nil);
}

- (void)testIdentity
{
    // All errors are seen as NSErrors, whether mutated or not (mutated ones are dynamically subclassed internally,
    // but must correctly lie about their true identity)
    GHAssertTrue([self.error1 isMemberOfClass:[NSError class]], nil);
    GHAssertTrue([self.error2 isMemberOfClass:[NSError class]], nil);
}

- (void)testAdding
{
    NSError *error = [NSError errorWithDomain:@"ch.hortis.CoconutKit-test" code:1012];
    [error addObject:@"A" forKey:@"TestKey"];
    GHAssertEqualStrings([error objectForKey:@"TestKey"], @"A", nil);
    NSArray *objects1 = [error objectsForKey:@"TestKey"];
    GHAssertEquals([objects1 count], 1U, nil);
    
    [error addObject:@"B" forKey:@"TestKey"];
    GHAssertTrue([[error objectForKey:@"TestKey"] isKindOfClass:[NSArray class]], nil);
    NSArray *objects2 = [error objectsForKey:@"TestKey"];
    GHAssertEquals([objects2 count], 2U, nil);
    
    [error addObjects:@[@"C", @"D"] forKey:@"TestKey"];
    GHAssertTrue([[error objectForKey:@"TestKey"] isKindOfClass:[NSArray class]], nil);
    NSArray *objects3 = [error objectsForKey:@"TestKey"];
    GHAssertEquals([objects3 count], 4U, nil);
}

- (void)testCopy
{
    NSError *error2Copy = [self.error2 copy];
    
    // The userInfo was deep-copied. Must check some of its information to assert the copy went well
    GHAssertEqualStrings([error2Copy localizedDescription], [self.error2 localizedDescription], nil);
    GHAssertEqualStrings([error2Copy localizedFailureReason], @"Localized failure reason", nil);
}

@end
