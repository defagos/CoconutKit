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
	

	return keyPaths;
}








@end
