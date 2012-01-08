// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassB.m instead.

#import "_ConcreteSubclassB.h"

@implementation ConcreteSubclassBID
@end

@implementation _ConcreteSubclassB

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ConcreteSubclassB" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ConcreteSubclassB";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ConcreteSubclassB" inManagedObjectContext:moc_];
}

- (ConcreteSubclassBID*)objectID {
	return (ConcreteSubclassBID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"codeMandatoryNumberBValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"codeMandatoryNumberB"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modelMandatoryBoundedNumberBValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modelMandatoryBoundedNumberB"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modelMandatoryCodeNotZeroNumberBValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modelMandatoryCodeNotZeroNumberB"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"noValidationNumberBValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"noValidationNumberB"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic codeMandatoryNumberB;



- (short)codeMandatoryNumberBValue {
	NSNumber *result = [self codeMandatoryNumberB];
	return [result shortValue];
}

- (void)setCodeMandatoryNumberBValue:(short)value_ {
	[self setCodeMandatoryNumberB:[NSNumber numberWithShort:value_]];
}

- (short)primitiveCodeMandatoryNumberBValue {
	NSNumber *result = [self primitiveCodeMandatoryNumberB];
	return [result shortValue];
}

- (void)setPrimitiveCodeMandatoryNumberBValue:(short)value_ {
	[self setPrimitiveCodeMandatoryNumberB:[NSNumber numberWithShort:value_]];
}





@dynamic modelMandatoryBoundedNumberB;



- (short)modelMandatoryBoundedNumberBValue {
	NSNumber *result = [self modelMandatoryBoundedNumberB];
	return [result shortValue];
}

- (void)setModelMandatoryBoundedNumberBValue:(short)value_ {
	[self setModelMandatoryBoundedNumberB:[NSNumber numberWithShort:value_]];
}

- (short)primitiveModelMandatoryBoundedNumberBValue {
	NSNumber *result = [self primitiveModelMandatoryBoundedNumberB];
	return [result shortValue];
}

- (void)setPrimitiveModelMandatoryBoundedNumberBValue:(short)value_ {
	[self setPrimitiveModelMandatoryBoundedNumberB:[NSNumber numberWithShort:value_]];
}





@dynamic modelMandatoryCodeNotZeroNumberB;



- (short)modelMandatoryCodeNotZeroNumberBValue {
	NSNumber *result = [self modelMandatoryCodeNotZeroNumberB];
	return [result shortValue];
}

- (void)setModelMandatoryCodeNotZeroNumberBValue:(short)value_ {
	[self setModelMandatoryCodeNotZeroNumberB:[NSNumber numberWithShort:value_]];
}

- (short)primitiveModelMandatoryCodeNotZeroNumberBValue {
	NSNumber *result = [self primitiveModelMandatoryCodeNotZeroNumberB];
	return [result shortValue];
}

- (void)setPrimitiveModelMandatoryCodeNotZeroNumberBValue:(short)value_ {
	[self setPrimitiveModelMandatoryCodeNotZeroNumberB:[NSNumber numberWithShort:value_]];
}





@dynamic noValidationNumberB;



- (short)noValidationNumberBValue {
	NSNumber *result = [self noValidationNumberB];
	return [result shortValue];
}

- (void)setNoValidationNumberBValue:(short)value_ {
	[self setNoValidationNumberB:[NSNumber numberWithShort:value_]];
}

- (short)primitiveNoValidationNumberBValue {
	NSNumber *result = [self primitiveNoValidationNumberB];
	return [result shortValue];
}

- (void)setPrimitiveNoValidationNumberBValue:(short)value_ {
	[self setPrimitiveNoValidationNumberB:[NSNumber numberWithShort:value_]];
}





@dynamic codeMandatoryConcreteClassesD;

	
- (NSMutableSet*)codeMandatoryConcreteClassesDSet {
	[self willAccessValueForKey:@"codeMandatoryConcreteClassesD"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"codeMandatoryConcreteClassesD"];
	[self didAccessValueForKey:@"codeMandatoryConcreteClassesD"];
	return result;
}
	





@end
