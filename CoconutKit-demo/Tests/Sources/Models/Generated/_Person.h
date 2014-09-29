// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#import <CoreData/CoreData.h>

extern const struct PersonAttributes {
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *lastName;
} PersonAttributes;

extern const struct PersonRelationships {
	__unsafe_unretained NSString *accounts;
	__unsafe_unretained NSString *houses;
} PersonRelationships;

@class BankAccount;
@class House;

@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PersonID* objectID;

@property (nonatomic, strong) NSString* firstName;

//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lastName;

//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *accounts;

- (NSMutableSet*)accountsSet;

@property (nonatomic, strong) NSSet *houses;

- (NSMutableSet*)housesSet;

@end

@interface _Person (AccountsCoreDataGeneratedAccessors)
- (void)addAccounts:(NSSet*)value_;
- (void)removeAccounts:(NSSet*)value_;
- (void)addAccountsObject:(BankAccount*)value_;
- (void)removeAccountsObject:(BankAccount*)value_;

@end

@interface _Person (HousesCoreDataGeneratedAccessors)
- (void)addHouses:(NSSet*)value_;
- (void)removeHouses:(NSSet*)value_;
- (void)addHousesObject:(House*)value_;
- (void)removeHousesObject:(House*)value_;

@end

@interface _Person (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;

- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;

- (NSMutableSet*)primitiveAccounts;
- (void)setPrimitiveAccounts:(NSMutableSet*)value;

- (NSMutableSet*)primitiveHouses;
- (void)setPrimitiveHouses:(NSMutableSet*)value;

@end
