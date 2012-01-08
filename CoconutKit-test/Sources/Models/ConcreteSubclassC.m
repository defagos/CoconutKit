#import "ConcreteSubclassC.h"

#import "TestErrors.h"

@implementation ConcreteSubclassC

#pragma mark Individual validations

// noValidationNumberC: No validation constraints, neither in the code, nor in the xcdatamodel
// modelMandatoryBoundedPatternStringC: Validation logic entirely in the xcdatamodel (mandatory, max length and matching to a pattern)

// codeMandatoryStringC: Validation entirely defined in code
- (BOOL)checkCodeMandatoryStringC:(NSString *)codeMandatoryStringC error:(NSError **)pError
{
    if (! codeMandatoryStringC) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}

#pragma mark Global validations

- (BOOL)checkForConsistency:(NSError **)pError
{
    if ([self.noValidationStringA isFilled] && ! self.noValidationNumberC) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationInconsistencyError];
        return NO;
    }
    
    return YES;

}

@end
