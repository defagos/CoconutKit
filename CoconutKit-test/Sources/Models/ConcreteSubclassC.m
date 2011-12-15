#import "ConcreteSubclassC.h"

#import "TestErrors.h"

@implementation ConcreteSubclassC

// codeMandatoryStringC: Validation entirely defined in code
- (BOOL)checkCodeMandatoryStringC:(NSString *)codeMandatoryStringC error:(NSError **)pError
{
    if (! codeMandatoryStringC) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}

// modelMandatoryCodeNotEmptyStringC: Validation defined in the xcdatamodel and in the code
- (BOOL)checkModelMandatoryCodeNotEmptyStringC:(NSString *)modelMandatoryCodeNotEmptyStringC error:(NSError **)pError
{
    if (! [modelMandatoryCodeNotEmptyStringC isFilled]) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

// modelMandatoryStringC: Validation entierly in the xcdatamodel

// noValidationStringC: No validation constraints, neither in the code, nor in the xcdatamodel

@end
