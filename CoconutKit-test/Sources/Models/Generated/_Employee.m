// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Employee.m instead.

#import "_Employee.h"

@implementation EmployeeID
@end

@implementation _Employee

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Employee";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc_];
}

- (EmployeeID*)objectID {
	return (EmployeeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic income;






@dynamic manager;

	





@end
