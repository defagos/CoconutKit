#import "Person.h"

static NSString * const kPersonMandatoryFieldError = @"kPersonMandatoryFieldError";
static NSString * const kPersonNegativeValueError = @"kPersonNegativeValueError";
static NSString * const kPersonInvalidEmailError = @"kPersonInvalidEmailError";

@implementation Person

#pragma mark Class methods

+ (void)initialize
{
    if (self != [Person class]) {
        return;
    }
    
    [HLSError registerDefaultCode:NSValidationMissingMandatoryPropertyError 
                           domain:@"ch.hortis.CoconutKit-demo" 
          localizedDescriptionKey:@"This field is mandatory"
                    forIdentifier:kPersonMandatoryFieldError];
    [HLSError registerDefaultCode:NSManagedObjectValidationError 
                           domain:@"ch.hortis.CoconutKit-demo" 
          localizedDescriptionKey:@"This value must be greater or equal to zero"
                    forIdentifier:kPersonNegativeValueError];
    [HLSError registerDefaultCode:NSManagedObjectValidationError 
                           domain:@"ch.hortis.CoconutKit-demo" 
          localizedDescriptionKey:@"This email address is invalid"
                    forIdentifier:kPersonInvalidEmailError];
}

#pragma mark Individudal validation methods

- (BOOL)checkFirstName:(NSString *)firstName error:(NSError **)pError
{
    if (! [firstName isFilled]) {
        *pError = [HLSError errorFromIdentifier:kPersonMandatoryFieldError];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkLastName:(NSString *)lastName error:(NSError **)pError
{
    if (! [lastName isFilled]) {
        *pError = [HLSError errorFromIdentifier:kPersonMandatoryFieldError];
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
        *pError = [HLSError errorFromIdentifier:kPersonInvalidEmailError];
        return NO;        
    }
    
    return YES;
}

- (BOOL)checkNbrChildren:(NSNumber *)nbrChildren error:(NSError **)pError
{
    if ([nbrChildren integerValue] < 0) {
        *pError = [HLSError errorFromIdentifier:kPersonNegativeValueError];
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
        *pError = [HLSError errorFromIdentifier:kPersonMandatoryFieldError];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkState:(NSString *)state error:(NSError **)pError
{
    return YES;
}

- (BOOL)checkCountry:(NSString *)country error:(NSError **)pError
{
    if (! [country isFilled]) {
        *pError = [HLSError errorFromIdentifier:kPersonMandatoryFieldError];
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
