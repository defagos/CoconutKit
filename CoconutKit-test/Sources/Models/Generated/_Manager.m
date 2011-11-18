// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Manager.m instead.

#import "_Manager.h"

@implementation ManagerID
@end

@implementation _Manager

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Manager" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Manager";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Manager" inManagedObjectContext:moc_];
}

- (ManagerID*)objectID {
	return (ManagerID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic department;






@dynamic employees;

	
- (NSMutableSet*)employeesSet {
	[self willAccessValueForKey:@"employees"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"employees"];
	[self didAccessValueForKey:@"employees"];
	return result;
}
	





@end
