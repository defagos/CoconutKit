// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to House.m instead.

#import "_House.h"

@implementation HouseID
@end

@implementation _House

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"House" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"House";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"House" inManagedObjectContext:moc_];
}

- (HouseID*)objectID {
	return (HouseID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic name;

@dynamic owners;

- (NSMutableSet<Person*>*)ownersSet {
	[self willAccessValueForKey:@"owners"];

	NSMutableSet<Person*> *result = (NSMutableSet<Person*>*)[self mutableSetValueForKey:@"owners"];

	[self didAccessValueForKey:@"owners"];
	return result;
}

@end

@implementation HouseAttributes 
+ (NSString *)name {
	return @"name";
}
@end

@implementation HouseRelationships 
+ (NSString *)owners {
	return @"owners";
}
@end

