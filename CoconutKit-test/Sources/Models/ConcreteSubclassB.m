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
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}

// modelMandatoryCodeNotZeroNumberB: Validation defined in the xcdatamodel (mandatory) and in the code (not zero)
- (BOOL)checkModelMandatoryCodeNotZeroNumberB:(NSNumber *)modelMandatoryCodeNotZeroNumberB error:(NSError **)pError
{
    if ([modelMandatoryCodeNotZeroNumberB intValue] == 0) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

@end
