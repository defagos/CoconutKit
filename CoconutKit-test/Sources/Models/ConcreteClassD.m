#import "ConcreteClassD.h"

#import "TestErrors.h"

@implementation ConcreteClassD

#pragma mark Individual validations

// noValidationNumberD and noValidationStringD: No validation constraints, neither in the code, nor in the xcdatamodel

#pragma mark Consistency validations

- (BOOL)checkForDelete:(NSError **)pError
{
    if ([self.noValidationStringD isEqualToString:@"LOCKED"]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:TestValidationErrorDomain
                                           code:TestValidationLockedObjectError];            
        }
        return NO;
    }
    
    return YES;
}

@end
