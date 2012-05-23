// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct BankAccountAttributes {
	 NSString *balance;
	 NSString *name;
} BankAccountAttributes;

extern const struct BankAccountRelationships {
	 NSString *owner;
} BankAccountRelationships;

extern const struct BankAccountFetchedProperties {
} BankAccountFetchedProperties;

@class Person;




@interface BankAccountID : NSManagedObjectID {}
@end

@interface _BankAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BankAccountID*)objectID;




@property (nonatomic, retain) NSNumber* balance;


@property double balanceValue;
- (double)balanceValue;
- (void)setBalanceValue:(double)value_;

//- (BOOL)validateBalance:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) Person* owner;

//- (BOOL)validateOwner:(id*)value_ error:(NSError**)error_;





@end

@interface _BankAccount (CoreDataGeneratedAccessors)

@end

@interface _BankAccount (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBalance;
- (void)setPrimitiveBalance:(NSNumber*)value;

- (double)primitiveBalanceValue;
- (void)setPrimitiveBalanceValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (Person*)primitiveOwner;
- (void)setPrimitiveOwner:(Person*)value;


@end
