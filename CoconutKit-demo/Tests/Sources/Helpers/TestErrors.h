//
//  TestErrors.h
//  CoconutKit-test
//
//  Created by Samuel Défago on 09.12.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

/**
 * Validation errors
 */
extern NSString * const TestValidationErrorDomain;

typedef NS_ENUM(NSInteger, TestValidation) {
    TestValidationEnumBegin = 100,
    TestValidationMandatoryValueError = TestValidationEnumBegin,
    TestValidationIncorrectValueError,
    TestValidationInconsistencyError,
    TestValidationLockedObjectError,
    TestValidationEnumEnd,
    TestValidationEnumSize = TestValidationEnumEnd - TestValidationEnumBegin
};

