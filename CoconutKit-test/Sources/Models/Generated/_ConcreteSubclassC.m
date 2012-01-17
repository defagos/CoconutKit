// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassC.m instead.

#import "_ConcreteSubclassC.h"

@implementation ConcreteSubclassCID
@end

@implementation _ConcreteSubclassC

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ConcreteSubclassC" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ConcreteSubclassC";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ConcreteSubclassC" inManagedObjectContext:moc_];
}

- (ConcreteSubclassCID*)objectID {
	return (ConcreteSubclassCID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"noValidationNumberCValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"noValidationNumberC"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic codeMandatoryStringC;






@dynamic modelMandatoryBoundedPatternStringC;






@dynamic noValidationNumberC;



- (short)noValidationNumberCValue {
	NSNumber *result = [self noValidationNumberC];
	return [result shortValue];
}

- (void)setNoValidationNumberCValue:(short)value_ {
	[self setNoValidationNumberC:[NSNumber numberWithShort:value_]];
}

- (short)primitiveNoValidationNumberCValue {
	NSNumber *result = [self primitiveNoValidationNumberC];
	return [result shortValue];
}

- (void)setPrimitiveNoValidationNumberCValue:(short)value_ {
	[self setPrimitiveNoValidationNumberC:[NSNumber numberWithShort:value_]];
}









@end
