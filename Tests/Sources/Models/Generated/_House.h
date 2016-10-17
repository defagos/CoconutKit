// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to House.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Person;

@interface HouseID : NSManagedObjectID {}
@end

@interface _House : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HouseID *objectID;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong, nullable) NSSet<Person*> *owners;
- (nullable NSMutableSet<Person*>*)ownersSet;

@end

@interface _House (OwnersCoreDataGeneratedAccessors)
- (void)addOwners:(NSSet<Person*>*)value_;
- (void)removeOwners:(NSSet<Person*>*)value_;
- (void)addOwnersObject:(Person*)value_;
- (void)removeOwnersObject:(Person*)value_;

@end

@interface _House (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSMutableSet<Person*>*)primitiveOwners;
- (void)setPrimitiveOwners:(NSMutableSet<Person*>*)value;

@end

@interface HouseAttributes: NSObject 
+ (NSString *)name;
@end

@interface HouseRelationships: NSObject
+ (NSString *)owners;
@end

NS_ASSUME_NONNULL_END
