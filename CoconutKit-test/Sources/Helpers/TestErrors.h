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
    TestErrorIncorrectValueError,
};

/**
 * Validation errors
 */
extern NSString * const TestValidationErrorDomain;

typedef NS_ENUM(NSInteger, TestValidationError) {
    TestValidationMandatoryValueError,
    TestValidationIncorrectValueError,
    TestValidationInconsistencyError,
    TestValidationLockedObjectError
};
