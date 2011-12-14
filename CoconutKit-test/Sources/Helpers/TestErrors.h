//
//  TestErrors.h
//  CoconutKit-test
//
//  Created by Samuel Défago on 09.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Validation errors
 */
extern NSString * const TestValidationErrorDomain;

typedef enum {
    TestValidationEnumBegin = 0,
    TestValidationMandatoryValueError = TestValidationEnumBegin,
    TestValidationIncorrectValueError,
    TestValidationLockedObjectError,
    TestValidationEnumEnd,
    TestValidationEnumSize = TestValidationEnumEnd - TestValidationEnumBegin
} TestValidation;

