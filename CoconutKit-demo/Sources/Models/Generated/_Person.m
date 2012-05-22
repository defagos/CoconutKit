// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.m instead.

#import "_Person.h"

const struct PersonAttributes PersonAttributes = {
	.birthdate = @"birthdate",
	.city = @"city",
	.country = @"country",
	.email = @"email",
	.firstName = @"firstName",
	.lastName = @"lastName",
	.nbrChildren = @"nbrChildren",
	.state = @"state",
	.street = @"street",
};

const struct PersonRelationships PersonRelationships = {
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
	
	if ([key isEqualToString:@"nbrChildrenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"nbrChildren"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic birthdate;






@dynamic city;






@dynamic country;






@dynamic email;






@dynamic firstName;






@dynamic lastName;






@dynamic nbrChildren;



- (int16_t)nbrChildrenValue {
	NSNumber *result = [self nbrChildren];
	return [result shortValue];
}

- (void)setNbrChildrenValue:(int16_t)value_ {
	[self setNbrChildren:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNbrChildrenValue {
	NSNumber *result = [self primitiveNbrChildren];
	return [result shortValue];
}

- (void)setPrimitiveNbrChildrenValue:(int16_t)value_ {
	[self setPrimitiveNbrChildren:[NSNumber numberWithShort:value_]];
}





@dynamic state;






@dynamic street;











@end
