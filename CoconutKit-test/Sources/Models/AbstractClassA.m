#import "AbstractClassA.h"

#import "TestErrors.h"

@implementation AbstractClassA

#pragma mark Individual validations

// noValidationStringA: No validation constraints, neither in the code, nor in the xcdatamodel

// codeMandatoryNotEmptyStringA: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNotEmptyStringA:(NSString *)codeMandatoryNotEmptyStringA error:(NSError **)pError
{
    if (! codeMandatoryNotEmptyStringA) {
        *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                      code:TestValidationMandatoryValueError];
        return NO;
    }
    
    if (! [codeMandatoryNotEmptyStringA isFilled]) {
        *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                      code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

#pragma Consistency validationa

- (BOOL)checkForConsistency:(NSError **)pError
{
    if ([self.noValidationStringA isFilled] && ! [self.noValidationStringA isEqualToString:@"Consistency check"]) {
        *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                      code:TestValidationInconsistencyError];
        return NO;
    }
    
    return YES;
}

@end
