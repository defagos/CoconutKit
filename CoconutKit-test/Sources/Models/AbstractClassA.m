#import "AbstractClassA.h"

#import "TestErrors.h"

@implementation AbstractClassA

// codeMandatoryNotEmptyStringA: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNotEmptyStringA:(NSString *)codeMandatoryNotEmptyStringA error:(NSError **)pError
{
    if (! codeMandatoryNotEmptyStringA) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    if (! [codeMandatoryNotEmptyStringA isFilled]) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

@end
