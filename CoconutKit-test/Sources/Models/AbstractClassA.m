#import "AbstractClassA.h"

#import "TestErrors.h"

@implementation AbstractClassA

#pragma mark Individual validation methods

// codeMandatoryStringA: Validation entirely defined in code
- (BOOL)checkCodeMandatoryStringA:(NSString *)codeMandatoryStringA error:(NSError **)pError
{
    if (! codeMandatoryStringA) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationMandatoryValueError];
        return NO;
    }
    
    return YES;
}

// modelMandatoryCodeNotEmptyStringA: Validation defined in the xcdatamodel and in the code
- (BOOL)checkModelMandatoryCodeNotEmptyStringA:(NSString *)modelMandatoryCodeNotEmptyStringA error:(NSError **)pError
{
    if (! [modelMandatoryCodeNotEmptyStringA isFilled]) {
        *pError = [HLSError errorWithDomain:@"ch.hortis.CoconutKit-test"
                                       code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

// modelMandatoryStringA: Validation entierly in the xcdatamodel

// noValidationStringA: No validation constraints, neither in the code, nor in the xcdatamodel

@end
