#import "PersonInformation.h"

#import "DemoErrors.h"

@implementation PersonInformation

#pragma mark Individudal validation methods

- (BOOL)checkFirstName:(NSString *)firstName error:(NSError **)pError
{
    if (! [firstName isFilled]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                           code:DemoValidationMandatoryError
                           localizedDescription:NSLocalizedString(@"Missing first name", nil)];
        }
        return NO;
    }

    return YES;
}

- (BOOL)checkLastName:(NSString *)lastName error:(NSError **)pError
{
    if (! [lastName isFilled]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                           code:DemoValidationMandatoryError
                           localizedDescription:NSLocalizedString(@"Missing last name", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkEmail:(NSString *)email error:(NSError **)pError
{
    // Optional
    if (! [email isFilled]) {
        return YES;
    }
    
    if (! [HLSValidators validateEmailAddress:email]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                           code:DemoValidationIncorrectError
                           localizedDescription:NSLocalizedString(@"Invalid email address", nil)];
        }
        return NO;        
    }
    
    return YES;
}

- (BOOL)checkNbrChildren:(NSNumber *)nbrChildren error:(NSError **)pError
{
    if ([nbrChildren integerValue] < 0) {
        if (pError) {
            *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                           code:DemoValidationIncorrectError
                           localizedDescription:NSLocalizedString(@"This value cannot be negative", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkStreet:(NSString *)street error:(NSError **)pError
{
    // Optional
    return YES;
}

- (BOOL)checkCity:(NSString *)city error:(NSError **)pError
{
    if (! [city isFilled]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                           code:DemoValidationMandatoryError 
                           localizedDescription:NSLocalizedString(@"Missing city", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkState:(NSString *)state error:(NSError **)pError
{
    // Optional
    return YES;
}

- (BOOL)checkCountry:(NSString *)country error:(NSError **)pError
{
    if (! [country isFilled]) {
        if (pError) {
            *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                           code:DemoValidationMandatoryError 
                           localizedDescription:NSLocalizedString(@"Missing country", nil)];
        }
        return NO;
    }
    
    return YES;
}

@end
