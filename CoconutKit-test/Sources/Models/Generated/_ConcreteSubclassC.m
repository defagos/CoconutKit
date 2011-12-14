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
	

	return keyPaths;
}




@dynamic codeMandatoryStringC;






@dynamic modelMandatoryCodeNotEmptyStringC;






@dynamic modelMandatoryStringC;






@dynamic noValidationStringC;






@dynamic classDObjects;

	
- (NSMutableSet*)classDObjectsSet {
	[self willAccessValueForKey:@"classDObjects"];
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"classDObjects"];
	[self didAccessValueForKey:@"classDObjects"];
	return result;
}
	





@end
