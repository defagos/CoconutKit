// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteClassD.m instead.

#import "_ConcreteClassD.h"

const struct ConcreteClassDAttributes ConcreteClassDAttributes = {
	.noValidationNumberD = @"noValidationNumberD",
	.noValidationStringD = @"noValidationStringD",
};

const struct ConcreteClassDRelationships ConcreteClassDRelationships = {
	.concreteSubclassB = @"concreteSubclassB",
};

@implementation ConcreteClassDID
@end

@implementation _ConcreteClassD

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ConcreteClassD" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ConcreteClassD";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ConcreteClassD" inManagedObjectContext:moc_];
}

- (ConcreteClassDID*)objectID {
	return (ConcreteClassDID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"noValidationNumberDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"noValidationNumberD"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic noValidationNumberD;

- (int16_t)noValidationNumberDValue {
	NSNumber *result = [self noValidationNumberD];
	return [result shortValue];
}

- (void)setNoValidationNumberDValue:(int16_t)value_ {
	[self setNoValidationNumberD:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNoValidationNumberDValue {
	NSNumber *result = [self primitiveNoValidationNumberD];
	return [result shortValue];
}

- (void)setPrimitiveNoValidationNumberDValue:(int16_t)value_ {
	[self setPrimitiveNoValidationNumberD:[NSNumber numberWithShort:value_]];
}

@dynamic noValidationStringD;

@dynamic concreteSubclassB;

- (NSMutableSet*)concreteSubclassBSet {
	[self willAccessValueForKey:@"concreteSubclassB"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"concreteSubclassB"];

	[self didAccessValueForKey:@"concreteSubclassB"];
	return result;
}

@end

