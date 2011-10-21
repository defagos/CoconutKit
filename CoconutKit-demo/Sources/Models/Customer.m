#import "Customer.h"

#import "NSArray+HLSExtensions.h"

@implementation Customer

+ (id)insert
{
    // TODO: In general, mogenerator might not be used. Check if this method exists
    return [self insertInManagedObjectContext:[HLSModelManager defaultModelContext]];
}

+ (NSEntityDescription *)entity
{
    // TODO: In general, mogenerator might not be used. Check if this method exists
    return [self entityInManagedObjectContext:[HLSModelManager defaultModelContext]];
}

+ (Customer *)customer
{
    return [self customerInManagedObjectContext:[HLSModelManager defaultModelContext]];
}

+ (Customer *)customerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *customers = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        HLSLoggerError(@"Could not retrieve objects; reason: %@", error);
        return nil;
    }
    
    if ([customers count] > 1) {
        HLSLoggerError(@"There must exist exactly 1 object");
    }
    
    return [customers firstObject];
}

@end
