//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "ConcreteSubclassB.h"

#import "TestErrors.h"

@implementation ConcreteSubclassB

#pragma mark Individual validations

// noValidationNumberB: No validation constraints, neither in the code, nor in the xcdatamodel
// modelMandatoryBoundedNumberB: Validation logic entirely in the xcdatamodel (mandatory and in [3;10])

// codeMandatoryNumberB: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNumberB:(NSNumber *)codeMandatoryNumberB error:(NSError *__autoreleasing *)pError
{
    if (! codeMandatoryNumberB) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationMandatoryValueError];
        }
        return NO;
    }
    
    return YES;
}

// modelMandatoryCodeNotZeroNumberB: Validation defined in the xcdatamodel (mandatory) and in the code (not zero)
- (BOOL)checkModelMandatoryCodeNotZeroNumberB:(NSNumber *)modelMandatoryCodeNotZeroNumberB error:(NSError *__autoreleasing *)pError
{
    if ([modelMandatoryCodeNotZeroNumberB intValue] == 0) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationIncorrectValueError];
        }
        return NO;
    }
    
    return YES;
}

// codeMandatoryConcreteClassesD
- (BOOL)checkCodeMandatoryConcreteClassesD:(NSSet *)codeMandatoryConcreteClassesD error:(NSError *__autoreleasing *)pError
{
    // To test to-many relationships, test the number of elements (there is always a set in this case, i.e.
    // we cannot simply test against nil)
    if ([codeMandatoryConcreteClassesD count] == 0) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationMandatoryValueError];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark Global validations

- (BOOL)checkForConsistency:(NSError *__autoreleasing *)pError
{
    if ([self.noValidationStringA isFilled] && ! self.noValidationNumberB) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationInconsistencyError];
        }
        return NO;
    }
    
    return YES;
}

@end
