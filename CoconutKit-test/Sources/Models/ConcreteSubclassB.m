#import "ConcreteSubclassB.h"

#import "TestErrors.h"

@implementation ConcreteSubclassB

#pragma mark Individual validations

// noValidationNumberB: No validation constraints, neither in the code, nor in the xcdatamodel
// modelMandatoryBoundedNumberB: Validation logic entirely in the xcdatamodel (mandatory and in [3;10])

// codeMandatoryNumberB: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNumberB:(NSNumber *)codeMandatoryNumberB error:(NSError **)pError
{
    if (! codeMandatoryNumberB) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}

// modelMandatoryCodeNotZeroNumberB: Validation defined in the xcdatamodel (mandatory) and in the code (not zero)
- (BOOL)checkModelMandatoryCodeNotZeroNumberB:(NSNumber *)modelMandatoryCodeNotZeroNumberB error:(NSError **)pError
{
    if ([modelMandatoryCodeNotZeroNumberB intValue] == 0) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

// codeMandatoryConcreteClassesD
- (BOOL)checkCodeMandatoryConcreteClassesD:(NSSet *)codeMandatoryConcreteClassesD error:(NSError **)pError
{
    // To test to-many relationships, test the number of elements (there is always a set in this case, i.e.
    // we cannot simply test against nil)
    if ([codeMandatoryConcreteClassesD count] == 0) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}

#pragma mark Global validations

- (BOOL)checkForConsistency:(NSError **)pError
{
    if ([self.noValidationStringA isFilled] && ! self.noValidationNumberB) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationInconsistencyError];
        return NO;
    }
    
    return YES;
}

@end
