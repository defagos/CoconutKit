//
//  DemoErrors.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 09.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Validation errors
 */
extern NSString * const DemoValidationErrorDomain;

typedef enum {
    DemoValidationEnumBegin = 0,
    DemoValidationMandatoryError = DemoValidationEnumBegin,
    DemoValidationIncorrectError,
    DemoValidationEnumEnd,
    DemoValidationEnumSize = DemoValidationEnumEnd - DemoValidationEnumBegin
} DemoValidation;

