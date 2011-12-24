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

#if 0
// codeMandatoryConcreteClassesD
- (BOOL)checkCodeMandatoryConcreteClassesD:(NSSet *)codeMandatoryConcreteClassesD error:(NSError **)pError
{
    if (! codeMandatoryConcreteClassesD) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}
#endif

#pragma mark Consistency validations

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
