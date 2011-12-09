#import "Person.h"

#import "DemoErrors.h"

@implementation Person

#pragma mark Individudal validation methods

- (BOOL)checkFirstName:(NSString *)firstName error:(NSError **)pError
{
    if (! [firstName isFilled]) {
        *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                       code:DemoValidationMandatoryError
                       localizedDescription:NSLocalizedString(@"Missing first name", @"Missing first name")];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkLastName:(NSString *)lastName error:(NSError **)pError
{
    if (! [lastName isFilled]) {
        *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                       code:DemoValidationMandatoryError
                       localizedDescription:NSLocalizedString(@"Missing last name", @"Missing last name")];
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
        *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                       code:DemoValidationIncorrectError
                       localizedDescription:NSLocalizedString(@"Invalid email address", @"Invalid email address")];
        return NO;        
    }
    
    return YES;
}

- (BOOL)checkNbrChildren:(NSNumber *)nbrChildren error:(NSError **)pError
{
    if ([nbrChildren integerValue] < 0) {
        *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                       code:DemoValidationIncorrectError
                       localizedDescription:NSLocalizedString(@"This value cannot be negative", @"This value cannot be negative")];
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
        *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                       code:DemoValidationMandatoryError 
                       localizedDescription:NSLocalizedString(@"Missing city", @"Missing city")];
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
        *pError = [HLSError errorWithDomain:DemoValidationErrorDomain 
                                       code:DemoValidationMandatoryError 
                       localizedDescription:NSLocalizedString(@"Missing country", @"Missing country")];
        return NO;
    }
    
    return YES;
}

#pragma mark Global validation methods

- (BOOL)checkForConsistency:(NSError **)pError
{
    return YES;
}

@end
