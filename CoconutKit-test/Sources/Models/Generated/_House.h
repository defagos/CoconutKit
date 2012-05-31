// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to House.h instead.

#import <CoreData/CoreData.h>


extern const struct HouseAttributes {
	 NSString *name;
} HouseAttributes;

extern const struct HouseRelationships {
	 NSString *owners;
} HouseRelationships;

extern const struct HouseFetchedProperties {
} HouseFetchedProperties;

@class Person;



@interface HouseID : NSManagedObjectID {}
@end

@interface _House : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (HouseID*)objectID;




@property (nonatomic, retain) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* owners;

- (NSMutableSet*)ownersSet;





@end

@interface _House (CoreDataGeneratedAccessors)

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
