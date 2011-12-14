// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteClassD.h instead.

#import <CoreData/CoreData.h>


@class ConcreteSubclassC;






@interface ConcreteClassDID : NSManagedObjectID {}
@end

@interface _ConcreteClassD : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteClassDID*)objectID;




@property (nonatomic, retain) NSNumber *modelBoundedNumberD;


@property int modelBoundedNumberDValue;
- (int)modelBoundedNumberDValue;
- (void)setModelBoundedNumberDValue:(int)value_;

//- (BOOL)validateModelBoundedNumberD:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *modelMandatoryDeletableBoolD;


@property BOOL modelMandatoryDeletableBoolDValue;
- (BOOL)modelMandatoryDeletableBoolDValue;
- (void)setModelMandatoryDeletableBoolDValue:(BOOL)value_;

//- (BOOL)validateModelMandatoryDeletableBoolD:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *modelMandatoryEndDateD;


//- (BOOL)validateModelMandatoryEndDateD:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *modelMandatoryStartDateD;


//- (BOOL)validateModelMandatoryStartDateD:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) ConcreteSubclassC* subclassCOwner;

//- (BOOL)validateSubclassCOwner:(id*)value_ error:(NSError**)error_;




@end

@interface _ConcreteClassD (CoreDataGeneratedAccessors)

@end

@interface _ConcreteClassD (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveModelBoundedNumberD;
- (void)setPrimitiveModelBoundedNumberD:(NSNumber*)value;

- (int)primitiveModelBoundedNumberDValue;
- (void)setPrimitiveModelBoundedNumberDValue:(int)value_;




- (NSNumber*)primitiveModelMandatoryDeletableBoolD;
- (void)setPrimitiveModelMandatoryDeletableBoolD:(NSNumber*)value;

- (BOOL)primitiveModelMandatoryDeletableBoolDValue;
- (void)setPrimitiveModelMandatoryDeletableBoolDValue:(BOOL)value_;




- (NSDate*)primitiveModelMandatoryEndDateD;
- (void)setPrimitiveModelMandatoryEndDateD:(NSDate*)value;




- (NSDate*)primitiveModelMandatoryStartDateD;
- (void)setPrimitiveModelMandatoryStartDateD:(NSDate*)value;





- (ConcreteSubclassC*)primitiveSubclassCOwner;
- (void)setPrimitiveSubclassCOwner:(ConcreteSubclassC*)value;


@end
