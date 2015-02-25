//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
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

typedef NS_ENUM(NSInteger, TestValidation) {
    TestValidationEnumBegin = 100,
    TestValidationMandatoryValueError = TestValidationEnumBegin,
    TestValidationIncorrectValueError,
    TestValidationInconsistencyError,
    TestValidationLockedObjectError,
    TestValidationEnumEnd,
    TestValidationEnumSize = TestValidationEnumEnd - TestValidationEnumBegin
};
