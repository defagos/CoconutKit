#import "ConcreteSubclassB.h"

#import "TestErrors.h"

@implementation ConcreteSubclassB

// noValidationNumberB: No validation constraints, neither in the code, nor in the xcdatamodel
// modelMandatoryBoundedNumberB: Validation logic entirely in the xcdatamodel (mandatory and in [3;10])

// codeMandatoryStringB: Validation entirely defined in code
- (BOOL)checkCodeMandatoryNumberB:(NSNumber *)codeMandatoryNumberB error:(NSError **)pError
{
    if (! codeMandatoryNumberB) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}

@end
