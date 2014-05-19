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
	.nbrChildren = @"nbrChildren",
	.state = @"state",
	.street = @"street",
};

const struct PersonInformationRelationships PersonInformationRelationships = {
};

const struct PersonInformationFetchedProperties PersonInformationFetchedProperties = {
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
	
	if ([key isEqualToString:@"nbrChildrenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"nbrChildren"];
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
