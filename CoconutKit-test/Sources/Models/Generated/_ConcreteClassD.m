// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteClassD.m instead.

#import "_ConcreteClassD.h"

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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"modelBoundedNumberDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modelBoundedNumberD"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modelMandatoryDeletableBoolDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modelMandatoryDeletableBoolD"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic modelBoundedNumberD;



- (int)modelBoundedNumberDValue {
	NSNumber *result = [self modelBoundedNumberD];
	return [result intValue];
}

- (void)setModelBoundedNumberDValue:(int)value_ {
	[self setModelBoundedNumberD:[NSNumber numberWithInt:value_]];
}

- (int)primitiveModelBoundedNumberDValue {
	NSNumber *result = [self primitiveModelBoundedNumberD];
	return [result intValue];
}

- (void)setPrimitiveModelBoundedNumberDValue:(int)value_ {
	[self setPrimitiveModelBoundedNumberD:[NSNumber numberWithInt:value_]];
}





@dynamic modelMandatoryDeletableBoolD;



- (BOOL)modelMandatoryDeletableBoolDValue {
	NSNumber *result = [self modelMandatoryDeletableBoolD];
	return [result boolValue];
}

- (void)setModelMandatoryDeletableBoolDValue:(BOOL)value_ {
	[self setModelMandatoryDeletableBoolD:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveModelMandatoryDeletableBoolDValue {
	NSNumber *result = [self primitiveModelMandatoryDeletableBoolD];
	return [result boolValue];
}

- (void)setPrimitiveModelMandatoryDeletableBoolDValue:(BOOL)value_ {
	[self setPrimitiveModelMandatoryDeletableBoolD:[NSNumber numberWithBool:value_]];
}





@dynamic modelMandatoryEndDateD;






@dynamic modelMandatoryStartDateD;






@dynamic subclassCOwner;

	





@end
