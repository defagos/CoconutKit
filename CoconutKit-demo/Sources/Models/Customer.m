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

@end
