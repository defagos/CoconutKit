// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Customer.m instead.

#import "_Customer.h"

@implementation CustomerID
@end

@implementation _Customer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Customer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Customer" inManagedObjectContext:moc_];
}

- (CustomerID*)objectID {
	return (CustomerID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic city;






@dynamic country;






@dynamic email;






@dynamic firstName;






@dynamic lastName;






@dynamic state;






@dynamic street;










@end
