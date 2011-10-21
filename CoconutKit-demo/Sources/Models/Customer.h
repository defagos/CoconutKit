#import "_Customer.h"

@interface Customer : _Customer {
@private
    
}

+ (id)insert;
+ (NSEntityDescription *)entity;

+ (Customer *)customer;               // uses the default model manager
+ (Customer *)customerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
