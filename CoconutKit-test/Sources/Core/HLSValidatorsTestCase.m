//
//  HLSValidatorsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSValidatorsTestCase.h"

@implementation HLSValidatorsTestCase

#pragma mark Tests

- (void)testEmailAddressValidation
{
    // Test cases borrowed from http://pgregg.com/projects/php/code/showvalidemail.php
    // The regex exhibits 13 mismatches with the reference results on this page. Those have not been discarded below
    // to keep the test set large. Inconsistent entries are marked as such
    GHAssertTrue([HLSValidators validateEmailAddress:@"name.lastname@domain.com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@".@"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"a@b"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"@bar.com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"@@bar.com"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@bar.com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa.com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@.com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@.123"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.123]"], @"E-mail");                                // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.123]a"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.333]"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"a@bar.com."], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"a@bar"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"a-b@bar.com"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"+@b.c"], @"E-mail");                                                 // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"+@b.com"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@-b.com"], @"E-mail");                                              // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@b-.com"], @"E-mail");                                              // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"-@..com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"-@a..com"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@b.co-foo.uk"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"hello my name is\"@stutter.com"], @"E-mail");                     // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Test \\\"Fail\\\" Ing\"@example.com"], @"E-mail");                // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"valid@special.museum"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"invalid@special.museum-"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"shaitan@my-domain.thisisminekthx"], @"E-mail");                      // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"test@...........com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"foobar@192.168.0.1"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Abc\\@def\"@example.com"], @"E-mail");                            // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Fred Bloggs\"@example.com"], @"E-mail");                          // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Joe\\Blow\"@example.com"], @"E-mail");                            // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Abc@def\"@example.com"], @"E-mail");                              // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"customer/department=shipping@example.com"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"$A12345@example.com"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"!def!xyz%abc@example.com"], @"E-mail");
    GHAssertTrue([HLSValidators validateEmailAddress:@"_somename@example.com"], @"E-mail");
    GHAssertFalse([HLSValidators validateEmailAddress:@"Test \\ Folding \\ Whitespace@example.com"], @"E-mail");            // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"HM2Kinsists@(that comments are allowed)this.is.ok"], @"E-mail");    // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"user%%uucp!path@somehost.edu"], @"E-mail");
}

@end
