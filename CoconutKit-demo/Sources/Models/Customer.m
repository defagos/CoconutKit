#import "Customer.h"

@implementation Customer

+ (Customer *)customer
{
    return [self customerInManagedObjectContext:[HLSModelManager defaultModelContext]];
}

+ (Customer *)customerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSArray *customers = [self allObjectsInManagedObjectContext:managedObjectContext];
    
    if ([customers count] > 1) {
        HLSLoggerError(@"There must exist exactly 1 object");
    }
    
    return [customers firstObject];
}

#pragma mark Individudal validation methods

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
