// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassB.h instead.

#import <CoreData/CoreData.h>
#import "AbstractClassA.h"

@class ConcreteClassD;






@interface ConcreteSubclassBID : NSManagedObjectID {}
@end

@interface _ConcreteSubclassB : AbstractClassA {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteSubclassBID*)objectID;




@property (nonatomic, retain) NSNumber *codeMandatoryNumberB;


@property short codeMandatoryNumberBValue;
- (short)codeMandatoryNumberBValue;
- (void)setCodeMandatoryNumberBValue:(short)value_;

//- (BOOL)validateCodeMandatoryNumberB:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *modelMandatoryBoundedNumberB;


@property short modelMandatoryBoundedNumberBValue;
- (short)modelMandatoryBoundedNumberBValue;
- (void)setModelMandatoryBoundedNumberBValue:(short)value_;

//- (BOOL)validateModelMandatoryBoundedNumberB:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *modelMandatoryCodeNotZeroNumberB;


@property short modelMandatoryCodeNotZeroNumberBValue;
- (short)modelMandatoryCodeNotZeroNumberBValue;
- (void)setModelMandatoryCodeNotZeroNumberBValue:(short)value_;

//- (BOOL)validateModelMandatoryCodeNotZeroNumberB:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *noValidationNumberB;


@property short noValidationNumberBValue;
- (short)noValidationNumberBValue;
- (void)setNoValidationNumberBValue:(short)value_;

//- (BOOL)validateNoValidationNumberB:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* codeMandatoryConcreteClassesD;

- (NSMutableSet*)codeMandatoryConcreteClassesDSet;




@end

@interface _ConcreteSubclassB (CoreDataGeneratedAccessors)

- (void)addCodeMandatoryConcreteClassesD:(NSSet*)value_;
- (void)removeCodeMandatoryConcreteClassesD:(NSSet*)value_;
- (void)addCodeMandatoryConcreteClassesDObject:(ConcreteClassD*)value_;
- (void)removeCodeMandatoryConcreteClassesDObject:(ConcreteClassD*)value_;

@end

@interface _ConcreteSubclassB (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCodeMandatoryNumberB;
- (void)setPrimitiveCodeMandatoryNumberB:(NSNumber*)value;

- (short)primitiveCodeMandatoryNumberBValue;
- (void)setPrimitiveCodeMandatoryNumberBValue:(short)value_;




- (NSNumber*)primitiveModelMandatoryBoundedNumberB;
- (void)setPrimitiveModelMandatoryBoundedNumberB:(NSNumber*)value;

- (short)primitiveModelMandatoryBoundedNumberBValue;
- (void)setPrimitiveModelMandatoryBoundedNumberBValue:(short)value_;




- (NSNumber*)primitiveModelMandatoryCodeNotZeroNumberB;
- (void)setPrimitiveModelMandatoryCodeNotZeroNumberB:(NSNumber*)value;

- (short)primitiveModelMandatoryCodeNotZeroNumberBValue;
- (void)setPrimitiveModelMandatoryCodeNotZeroNumberBValue:(short)value_;




- (NSNumber*)primitiveNoValidationNumberB;
- (void)setPrimitiveNoValidationNumberB:(NSNumber*)value;

- (short)primitiveNoValidationNumberBValue;
- (void)setPrimitiveNoValidationNumberBValue:(short)value_;





- (NSMutableSet*)primitiveCodeMandatoryConcreteClassesD;
- (void)setPrimitiveCodeMandatoryConcreteClassesD:(NSMutableSet*)value;


@end
