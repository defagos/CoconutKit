// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.m instead.

#import "_Person.h"

const struct PersonAttributes PersonAttributes = {
	.firstName = @"firstName",
	.lastName = @"lastName",
};

const struct PersonRelationships PersonRelationships = {
	.accounts = @"accounts",
	.houses = @"houses",
};

const struct PersonFetchedProperties PersonFetchedProperties = {
};

@implementation PersonID
@end

@implementation _Person

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Person";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc_];
}

- (PersonID*)objectID {
	return (PersonID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic firstName;






@dynamic lastName;






@dynamic accounts;

	
- (NSMutableSet*)accountsSet {
	[self willAccessValueForKey:@"accounts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"accounts"];
  
	[self didAccessValueForKey:@"accounts"];
	return result;
}
	

@dynamic houses;

	
- (NSMutableSet*)housesSet {
	[self willAccessValueForKey:@"houses"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"houses"];
  
	[self didAccessValueForKey:@"houses"];
	return result;
}
	






@end
