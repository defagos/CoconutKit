// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankAccount.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Person;

@interface BankAccountID : NSManagedObjectID {}
@end

@interface _BankAccount : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) BankAccountID *objectID;

@property (nonatomic, strong) NSNumber* balance;

@property (atomic) double balanceValue;
- (double)balanceValue;
- (void)setBalanceValue:(double)value_;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong, nullable) Person *owner;

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

@interface BankAccountAttributes: NSObject 
+ (NSString *)balance;
+ (NSString *)name;
@end

@interface BankAccountRelationships: NSObject
+ (NSString *)owner;
@end

NS_ASSUME_NONNULL_END
