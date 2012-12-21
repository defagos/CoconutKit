// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankAccount.m instead.

#import "_BankAccount.h"

const struct BankAccountAttributes BankAccountAttributes = {
	.balance = @"balance",
	.name = @"name",
};

const struct BankAccountRelationships BankAccountRelationships = {
	.owner = @"owner",
};

const struct BankAccountFetchedProperties BankAccountFetchedProperties = {
};

@implementation BankAccountID
@end

@implementation _BankAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BankAccount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BankAccount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BankAccount" inManagedObjectContext:moc_];
}

- (BankAccountID*)objectID {
	return (BankAccountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"balanceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"balance"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic balance;



- (double)balanceValue {
	NSNumber *result = [self balance];
	return [result doubleValue];
}

- (void)setBalanceValue:(double)value_ {
	[self setBalance:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveBalanceValue {
	NSNumber *result = [self primitiveBalance];
	return [result doubleValue];
}

- (void)setPrimitiveBalanceValue:(double)value_ {
	[self setPrimitiveBalance:[NSNumber numberWithDouble:value_]];
}





@dynamic name;






@dynamic owner;

	






@end
