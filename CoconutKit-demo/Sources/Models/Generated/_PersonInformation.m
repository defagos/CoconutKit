// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PersonInformation.m instead.

#import "_PersonInformation.h"

const struct PersonInformationAttributes PersonInformationAttributes = {
	.birthdate = @"birthdate",
	.city = @"city",
	.country = @"country",
	.email = @"email",
	.firstName = @"firstName",
	.lastName = @"lastName",
	.numberOfChildren = @"numberOfChildren",
	.state = @"state",
	.street = @"street",
};

@implementation PersonInformationID
@end

@implementation _PersonInformation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"PersonInformation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"PersonInformation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"PersonInformation" inManagedObjectContext:moc_];
}

- (PersonInformationID*)objectID {
	return (PersonInformationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"numberOfChildrenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numberOfChildren"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic birthdate;

@dynamic city;

@dynamic country;

@dynamic email;

@dynamic firstName;

@dynamic lastName;

@dynamic numberOfChildren;

- (int16_t)numberOfChildrenValue {
	NSNumber *result = [self numberOfChildren];
	return [result shortValue];
}

- (void)setNumberOfChildrenValue:(int16_t)value_ {
	[self setNumberOfChildren:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNumberOfChildrenValue {
	NSNumber *result = [self primitiveNumberOfChildren];
	return [result shortValue];
}

- (void)setPrimitiveNumberOfChildrenValue:(int16_t)value_ {
	[self setPrimitiveNumberOfChildren:[NSNumber numberWithShort:value_]];
}

@dynamic state;

@dynamic street;

@end

