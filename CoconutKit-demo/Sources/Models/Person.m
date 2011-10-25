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

#pragma mark Global validation methods

- (BOOL)checkForConsistency:(NSError **)pError
{
    return YES;
}

@end
