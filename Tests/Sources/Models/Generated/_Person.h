// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class BankAccount;
@class House;

@interface PersonID : NSManagedObjectID {}
@end

@interface _Person : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PersonID *objectID;

@property (nonatomic, strong) NSString* firstName;

@property (nonatomic, strong) NSString* lastName;

@property (nonatomic, strong, nullable) NSSet<BankAccount*> *accounts;
- (nullable NSMutableSet<BankAccount*>*)accountsSet;

@property (nonatomic, strong, nullable) NSSet<House*> *houses;
- (nullable NSMutableSet<House*>*)housesSet;

@end

@interface _Person (AccountsCoreDataGeneratedAccessors)
- (void)addAccounts:(NSSet<BankAccount*>*)value_;
- (void)removeAccounts:(NSSet<BankAccount*>*)value_;
- (void)addAccountsObject:(BankAccount*)value_;
- (void)removeAccountsObject:(BankAccount*)value_;

@end

@interface _Person (HousesCoreDataGeneratedAccessors)
- (void)addHouses:(NSSet<House*>*)value_;
- (void)removeHouses:(NSSet<House*>*)value_;
- (void)addHousesObject:(House*)value_;
- (void)removeHousesObject:(House*)value_;

@end

@interface _Person (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;

- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;

- (NSMutableSet<BankAccount*>*)primitiveAccounts;
- (void)setPrimitiveAccounts:(NSMutableSet<BankAccount*>*)value;

- (NSMutableSet<House*>*)primitiveHouses;
- (void)setPrimitiveHouses:(NSMutableSet<House*>*)value;

@end

@interface PersonAttributes: NSObject 
+ (NSString *)firstName;
+ (NSString *)lastName;
@end

@interface PersonRelationships: NSObject
+ (NSString *)accounts;
+ (NSString *)houses;
@end

NS_ASSUME_NONNULL_END
