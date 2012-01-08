// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#import <CoreData/CoreData.h>


@class BankAccount;
@class House;




@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PersonID*)objectID;




@property (nonatomic, retain) NSString *firstName;


//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *lastName;


//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* accounts;

- (NSMutableSet*)accountsSet;




@property (nonatomic, retain) NSSet* houses;

- (NSMutableSet*)housesSet;




@end

@interface _Person (CoreDataGeneratedAccessors)

- (void)addAccounts:(NSSet*)value_;
- (void)removeAccounts:(NSSet*)value_;
- (void)addAccountsObject:(BankAccount*)value_;
- (void)removeAccountsObject:(BankAccount*)value_;

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
