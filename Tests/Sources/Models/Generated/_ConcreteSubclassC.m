// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassC.m instead.

#import "_ConcreteSubclassC.h"

@implementation ConcreteSubclassCID
@end

@implementation _ConcreteSubclassC

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"noValidationNumberCValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"noValidationNumberC"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic codeMandatoryStringC;

@dynamic modelMandatoryBoundedPatternStringC;

@dynamic noValidationNumberC;

- (int16_t)noValidationNumberCValue {
	NSNumber *result = [self noValidationNumberC];
	return [result shortValue];
}

- (void)setNoValidationNumberCValue:(int16_t)value_ {
	[self setNoValidationNumberC:@(value_)];
}

- (int16_t)primitiveNoValidationNumberCValue {
	NSNumber *result = [self primitiveNoValidationNumberC];
	return [result shortValue];
}

- (void)setPrimitiveNoValidationNumberCValue:(int16_t)value_ {
	[self setPrimitiveNoValidationNumberC:@(value_)];
}

@end

@implementation ConcreteSubclassCAttributes 
+ (NSString *)codeMandatoryStringC {
	return @"codeMandatoryStringC";
}
+ (NSString *)modelMandatoryBoundedPatternStringC {
	return @"modelMandatoryBoundedPatternStringC";
}
+ (NSString *)noValidationNumberC {
	return @"noValidationNumberC";
}
@end

