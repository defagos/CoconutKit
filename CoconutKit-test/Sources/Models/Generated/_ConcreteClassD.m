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
	

	return keyPaths;
}








@end
