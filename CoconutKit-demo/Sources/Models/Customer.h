#import "_Customer.h"

@interface Customer : _Customer {
@private
    
}

+ (Customer *)customer;               // uses the default model manager
+ (Customer *)customerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
