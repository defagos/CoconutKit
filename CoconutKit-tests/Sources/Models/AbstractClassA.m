//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AbstractClassA.h"

#import "TestErrors.h"

@implementation AbstractClassA

#pragma mark Individual validations

// noValidationStringA: No validation constraints, neither in the code, nor in the xcdatamodel

// codeMandatoryNotEmptyStringA: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNotEmptyStringA:(NSString *)codeMandatoryNotEmptyStringA error:(NSError *__autoreleasing *)pError
{
    if (! codeMandatoryNotEmptyStringA) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationMandatoryValueError];
        }
        return NO;
    }
    
    if (! [codeMandatoryNotEmptyStringA isFilled]) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationIncorrectValueError];
        }
        return NO;
    }
    
    return YES;      
}

#pragma mark Consistency validation

- (BOOL)checkForConsistency:(NSError *__autoreleasing *)pError
{
    if ([self.noValidationStringA isFilled] && ! [self.noValidationStringA isEqualToString:@"Consistency check"]) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationInconsistencyError];
        }
        return NO;
    }
    
    return YES;
}

@end
