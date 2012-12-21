// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteClassD.h instead.

#import <CoreData/CoreData.h>


extern const struct ConcreteClassDAttributes {
	 NSString *noValidationNumberD;
	 NSString *noValidationStringD;
} ConcreteClassDAttributes;

extern const struct ConcreteClassDRelationships {
	 NSString *concreteSubclassB;
} ConcreteClassDRelationships;

extern const struct ConcreteClassDFetchedProperties {
} ConcreteClassDFetchedProperties;

@class ConcreteSubclassB;




@interface ConcreteClassDID : NSManagedObjectID {}
@end

@interface _ConcreteClassD : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteClassDID*)objectID;





@property (nonatomic, retain) NSNumber* noValidationNumberD;



@property int16_t noValidationNumberDValue;
- (int16_t)noValidationNumberDValue;
- (void)setNoValidationNumberDValue:(int16_t)value_;

//- (BOOL)validateNoValidationNumberD:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* noValidationStringD;



//- (BOOL)validateNoValidationStringD:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *concreteSubclassB;

- (NSMutableSet*)concreteSubclassBSet;





@end

@interface _ConcreteClassD (CoreDataGeneratedAccessors)

- (void)addConcreteSubclassB:(NSSet*)value_;
- (void)removeConcreteSubclassB:(NSSet*)value_;
- (void)addConcreteSubclassBObject:(ConcreteSubclassB*)value_;
- (void)removeConcreteSubclassBObject:(ConcreteSubclassB*)value_;

@end

@interface _ConcreteClassD (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveNoValidationNumberD;
- (void)setPrimitiveNoValidationNumberD:(NSNumber*)value;

- (int16_t)primitiveNoValidationNumberDValue;
- (void)setPrimitiveNoValidationNumberDValue:(int16_t)value_;




- (NSString*)primitiveNoValidationStringD;
- (void)setPrimitiveNoValidationStringD:(NSString*)value;





- (NSMutableSet*)primitiveConcreteSubclassB;
- (void)setPrimitiveConcreteSubclassB:(NSMutableSet*)value;


@end
