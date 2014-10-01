// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to House.h instead.

#import <CoreData/CoreData.h>

extern const struct HouseAttributes {
	__unsafe_unretained NSString *name;
} HouseAttributes;

extern const struct HouseRelationships {
	__unsafe_unretained NSString *owners;
} HouseRelationships;

@class Person;

@interface HouseID : NSManagedObjectID {}
@end

@interface _House : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HouseID* objectID;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *owners;

- (NSMutableSet*)ownersSet;

@end

@interface _House (OwnersCoreDataGeneratedAccessors)
- (void)addOwners:(NSSet*)value_;
- (void)removeOwners:(NSSet*)value_;
- (void)addOwnersObject:(Person*)value_;
- (void)removeOwnersObject:(Person*)value_;

@end

@interface _House (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSMutableSet*)primitiveOwners;
- (void)setPrimitiveOwners:(NSMutableSet*)value;

@end
