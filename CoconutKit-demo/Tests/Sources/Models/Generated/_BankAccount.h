// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankAccount.h instead.

#import <CoreData/CoreData.h>

extern const struct BankAccountAttributes {
	__unsafe_unretained NSString *balance;
	__unsafe_unretained NSString *name;
} BankAccountAttributes;

extern const struct BankAccountRelationships {
	__unsafe_unretained NSString *owner;
} BankAccountRelationships;

@class Person;

@interface BankAccountID : NSManagedObjectID {}
@end

@interface _BankAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) BankAccountID* objectID;

@property (nonatomic, strong) NSNumber* balance;

@property (atomic) double balanceValue;
- (double)balanceValue;
- (void)setBalanceValue:(double)value_;

//- (BOOL)validateBalance:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Person *owner;

//- (BOOL)validateOwner:(id*)value_ error:(NSError**)error_;

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
