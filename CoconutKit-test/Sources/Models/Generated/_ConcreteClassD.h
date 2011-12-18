// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteClassD.h instead.

#import <CoreData/CoreData.h>


@class ConcreteSubclassB;




@interface ConcreteClassDID : NSManagedObjectID {}
@end

@interface _ConcreteClassD : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteClassDID*)objectID;




@property (nonatomic, retain) NSNumber *noValidationNumberD;


@property short noValidationNumberDValue;
- (short)noValidationNumberDValue;
- (void)setNoValidationNumberDValue:(short)value_;

//- (BOOL)validateNoValidationNumberD:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *noValidationStringD;


//- (BOOL)validateNoValidationStringD:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) ConcreteSubclassB* concreteSubclassB;

//- (BOOL)validateConcreteSubclassB:(id*)value_ error:(NSError**)error_;




@end

@interface _ConcreteClassD (CoreDataGeneratedAccessors)

@end

@interface _ConcreteClassD (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveNoValidationNumberD;
- (void)setPrimitiveNoValidationNumberD:(NSNumber*)value;

- (short)primitiveNoValidationNumberDValue;
- (void)setPrimitiveNoValidationNumberDValue:(short)value_;




- (NSString*)primitiveNoValidationStringD;
- (void)setPrimitiveNoValidationStringD:(NSString*)value;





- (ConcreteSubclassB*)primitiveConcreteSubclassB;
- (void)setPrimitiveConcreteSubclassB:(ConcreteSubclassB*)value;


@end
