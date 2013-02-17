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
    GHAssertTrue([HLSValidators validateEmailAddress:@"name.lastname@domain.com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@".@"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"a@b"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"@bar.com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"@@bar.com"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@bar.com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa.com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@.com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@.123"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.123]"], nil);                                      // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.123]a"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.333]"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"a@bar.com."], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"a@bar"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"a-b@bar.com"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"+@b.c"], nil);                                                       // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"+@b.com"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@-b.com"], nil);                                                    // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@b-.com"], nil);                                                    // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"-@..com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"-@a..com"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"a@b.co-foo.uk"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"hello my name is\"@stutter.com"], nil);                           // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Test \\\"Fail\\\" Ing\"@example.com"], nil);                      // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"valid@special.museum"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"invalid@special.museum-"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"shaitan@my-domain.thisisminekthx"], nil);                            // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"test@...........com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"foobar@192.168.0.1"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Abc\\@def\"@example.com"], nil);                                  // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Fred Bloggs\"@example.com"], nil);                                // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Joe\\Blow\"@example.com"], nil);                                  // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"\"Abc@def\"@example.com"], nil);                                    // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"customer/department=shipping@example.com"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"$A12345@example.com"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"!def!xyz%abc@example.com"], nil);
    GHAssertTrue([HLSValidators validateEmailAddress:@"_somename@example.com"], nil);
    GHAssertFalse([HLSValidators validateEmailAddress:@"Test \\ Folding \\ Whitespace@example.com"], nil);                  // inconsistency
    GHAssertFalse([HLSValidators validateEmailAddress:@"HM2Kinsists@(that comments are allowed)this.is.ok"], nil);          // inconsistency
    GHAssertTrue([HLSValidators validateEmailAddress:@"user%%uucp!path@somehost.edu"], nil);
}

@end
