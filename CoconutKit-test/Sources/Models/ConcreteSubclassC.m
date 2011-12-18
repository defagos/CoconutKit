#import "ConcreteSubclassC.h"

#import "TestErrors.h"

@implementation ConcreteSubclassC

#pragma mark Individual validations

// noValidationNumberC: No validation constraints, neither in the code, nor in the xcdatamodel

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


@end
