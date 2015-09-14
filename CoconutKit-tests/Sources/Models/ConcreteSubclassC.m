//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "ConcreteSubclassC.h"

#import "TestErrors.h"

@implementation ConcreteSubclassC

#pragma mark Individual validations

// noValidationNumberC: No validation constraints, neither in the code, nor in the xcdatamodel
// modelMandatoryBoundedPatternStringC: Validation logic entirely in the xcdatamodel (mandatory, max length and matching to a pattern)

// codeMandatoryStringC: Validation entirely defined in code
- (BOOL)checkCodeMandatoryStringC:(NSString *)codeMandatoryStringC error:(NSError *__autoreleasing *)pError
{
    if (! codeMandatoryStringC) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationMandatoryValueError];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark Global validations

- (BOOL)checkForConsistency:(NSError *__autoreleasing *)pError
{
    if ([self.noValidationStringA isFilled] && ! self.noValidationNumberC) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationInconsistencyError];            
        }
        return NO;
    }
    
    return YES;

}

@end
