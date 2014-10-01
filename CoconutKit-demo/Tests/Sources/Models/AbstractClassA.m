#import "AbstractClassA.h"

#import "TestErrors.h"

@implementation AbstractClassA

#pragma mark Individual validations

// noValidationStringA: No validation constraints, neither in the code, nor in the xcdatamodel

// codeMandatoryNotEmptyStringA: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNotEmptyStringA:(NSString *)codeMandatoryNotEmptyStringA error:(NSError **)pError
{
    if (! codeMandatoryNotEmptyStringA) {
        if (pError) {
            *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                           code:TestValidationMandatoryValueError];
        }
        return NO;
    }
    
    if (! [codeMandatoryNotEmptyStringA isFilled]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                           code:TestValidationIncorrectValueError];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark Consistency validation

- (BOOL)checkForConsistency:(NSError **)pError
{
    if ([self.noValidationStringA isFilled] && ! [self.noValidationStringA isEqualToString:@"Consistency check"]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                           code:TestValidationInconsistencyError];            
        }
        return NO;
    }
    
    return YES;
}

@end
