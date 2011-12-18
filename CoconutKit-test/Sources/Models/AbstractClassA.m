#import "AbstractClassA.h"

#import "TestErrors.h"

@implementation AbstractClassA

// codeMandatoryNotEmptyStringA: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNotEmptyStringA:(NSString *)codeMandatoryNotEmptyStringA error:(NSError **)pError
{
    if (! codeMandatoryNotEmptyStringA) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    if (! [codeMandatoryNotEmptyStringA isFilled]) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                       code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

@end
