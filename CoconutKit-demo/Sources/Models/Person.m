#import "Person.h"

@implementation Person

#pragma mark Individudal validation methods

- (BOOL)checkFirstName:(NSString *)firstName error:(NSError **)pError
{
    return [firstName length] != 0;
}

- (BOOL)checkLastName:(NSString *)lastName error:(NSError **)pError
{
    return [lastName length] != 0;
}

- (BOOL)checkNbrChildren:(NSInteger)nbrChildren error:(NSError **)pError
{
    return nbrChildren >= 0;
}

- (BOOL)checkEmail:(NSString *)email error:(NSError **)pError
{
    return [HLSValidators validateEmailAddress:email];
}

- (BOOL)checkStreet:(NSString *)street error:(NSError **)pError
{
    return YES;
}

- (BOOL)checkCity:(NSString *)city error:(NSError **)pError
{
    return [city length] != 0;
}

- (BOOL)checkState:(NSString *)state error:(NSError **)pError
{
    return YES;
}

- (BOOL)checkCountry:(NSString *)country error:(NSError **)pError
{
    return [country length] != 0;
}

#pragma mark Global validation methods

- (BOOL)checkForConsistency:(NSError **)pError
{
    return YES;
}

@end
