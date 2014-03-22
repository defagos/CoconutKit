//
//  TestErrors.h
//  CoconutKit-test
//
//  Created by Samuel Défago on 09.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Common errors
 */
extern NSString * const TestErrorDomain;

typedef NS_ENUM(NSInteger, TestError) {
    TestErrorEnumBegin = 0,
    TestErrorIncorrectValueError = TestErrorEnumBegin,
    TestErrorEnumEnd,
    TestErrorEnumSize = TestErrorEnumEnd - TestErrorEnumBegin
};

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
