#import "ConcreteClassD.h"

#import "TestErrors.h"

@implementation ConcreteClassD

#pragma mark Individual validation methods

// All individual validation methods are defined in the xcdatamodel file

#pragma mark Global validation methods

- (BOOL)checkForConsistency:(NSError **)pError
{
    if ([self.modelMandatoryStartDateD isLaterThanDate:self.modelMandatoryEndDateD]) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain 
                                       code:TestValidationIncorrectValueError];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkForDelete:(NSError **)pError
{
    // Can only delete those entries marked as such (using the modelMandatoryDeleteableBoolD field)
    if (! self.modelMandatoryDeletableBoolDValue) {
        *pError = [HLSError errorWithDomain:TestValidationErrorDomain 
                                       code:TestValidationLockedObjectError];
        return NO;
    }
    
    return YES;
}

@end
