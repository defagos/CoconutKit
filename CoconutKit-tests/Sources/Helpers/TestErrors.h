//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
