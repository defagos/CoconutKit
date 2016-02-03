//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSValidatorsTestCase.h"

@implementation HLSValidatorsTestCase

#pragma mark Tests

- (void)testEmailAddressValidation
{
    // Test cases borrowed from http://pgregg.com/projects/php/code/showvalidemail.php
    // The regex exhibits 13 mismatches with the reference results on this page. Those have not been discarded below
    // to keep the test set large. Inconsistent entries are marked as such
    XCTAssertTrue([HLSValidators validateEmailAddress:@"name.lastname@domain.com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@".@"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"a@b"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"@bar.com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"@@bar.com"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"a@bar.com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"aaa.com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"aaa@.com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"aaa@.123"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.123]"]);                                      // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.123]a"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"aaa@[123.123.123.333]"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"a@bar.com."]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"a@bar"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"a-b@bar.com"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"+@b.c"]);                                                       // inconsistency
    XCTAssertTrue([HLSValidators validateEmailAddress:@"+@b.com"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"a@-b.com"]);                                                    // inconsistency
    XCTAssertTrue([HLSValidators validateEmailAddress:@"a@b-.com"]);                                                    // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"-@..com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"-@a..com"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"a@b.co-foo.uk"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"\"hello my name is\"@stutter.com"]);                           // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"\"Test \\\"Fail\\\" Ing\"@example.com"]);                      // inconsistency
    XCTAssertTrue([HLSValidators validateEmailAddress:@"valid@special.museum"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"invalid@special.museum-"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"shaitan@my-domain.thisisminekthx"]);                            // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"test@...........com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"foobar@192.168.0.1"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"\"Abc\\@def\"@example.com"]);                                  // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"\"Fred Bloggs\"@example.com"]);                                // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"\"Joe\\Blow\"@example.com"]);                                  // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"\"Abc@def\"@example.com"]);                                    // inconsistency
    XCTAssertTrue([HLSValidators validateEmailAddress:@"customer/department=shipping@example.com"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"$A12345@example.com"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"!def!xyz%abc@example.com"]);
    XCTAssertTrue([HLSValidators validateEmailAddress:@"_somename@example.com"]);
    XCTAssertFalse([HLSValidators validateEmailAddress:@"Test \\ Folding \\ Whitespace@example.com"]);                  // inconsistency
    XCTAssertFalse([HLSValidators validateEmailAddress:@"HM2Kinsists@(that comments are allowed)this.is.ok"]);          // inconsistency
    XCTAssertTrue([HLSValidators validateEmailAddress:@"user%%uucp!path@somehost.edu"]);
}

@end
