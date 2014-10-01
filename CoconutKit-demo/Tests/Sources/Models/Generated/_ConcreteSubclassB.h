// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassB.h instead.

#import <CoreData/CoreData.h>
#import "AbstractClassA.h"

extern const struct ConcreteSubclassBAttributes {
	__unsafe_unretained NSString *codeMandatoryNumberB;
	__unsafe_unretained NSString *modelMandatoryBoundedNumberB;
	__unsafe_unretained NSString *modelMandatoryCodeNotZeroNumberB;
	__unsafe_unretained NSString *noValidationNumberB;
} ConcreteSubclassBAttributes;

extern const struct ConcreteSubclassBRelationships {
	__unsafe_unretained NSString *codeMandatoryConcreteClassesD;
} ConcreteSubclassBRelationships;

@class ConcreteClassD;

@interface ConcreteSubclassBID : AbstractClassAID {}
@end

@interface _ConcreteSubclassB : AbstractClassA {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConcreteSubclassBID* objectID;

@property (nonatomic, strong) NSNumber* codeMandatoryNumberB;

@property (atomic) int16_t codeMandatoryNumberBValue;
- (int16_t)codeMandatoryNumberBValue;
- (void)setCodeMandatoryNumberBValue:(int16_t)value_;

//- (BOOL)validateCodeMandatoryNumberB:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* modelMandatoryBoundedNumberB;

@property (atomic) int16_t modelMandatoryBoundedNumberBValue;
- (int16_t)modelMandatoryBoundedNumberBValue;
- (void)setModelMandatoryBoundedNumberBValue:(int16_t)value_;

//- (BOOL)validateModelMandatoryBoundedNumberB:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* modelMandatoryCodeNotZeroNumberB;

@property (atomic) int16_t modelMandatoryCodeNotZeroNumberBValue;
- (int16_t)modelMandatoryCodeNotZeroNumberBValue;
- (void)setModelMandatoryCodeNotZeroNumberBValue:(int16_t)value_;

//- (BOOL)validateModelMandatoryCodeNotZeroNumberB:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* noValidationNumberB;

@property (atomic) int16_t noValidationNumberBValue;
- (int16_t)noValidationNumberBValue;
- (void)setNoValidationNumberBValue:(int16_t)value_;

//- (BOOL)validateNoValidationNumberB:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *codeMandatoryConcreteClassesD;

- (NSMutableSet*)codeMandatoryConcreteClassesDSet;

@end

@interface _ConcreteSubclassB (CodeMandatoryConcreteClassesDCoreDataGeneratedAccessors)
- (void)addCodeMandatoryConcreteClassesD:(NSSet*)value_;
- (void)removeCodeMandatoryConcreteClassesD:(NSSet*)value_;
- (void)addCodeMandatoryConcreteClassesDObject:(ConcreteClassD*)value_;
- (void)removeCodeMandatoryConcreteClassesDObject:(ConcreteClassD*)value_;

@end

@interface _ConcreteSubclassB (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveCodeMandatoryNumberB;
- (void)setPrimitiveCodeMandatoryNumberB:(NSNumber*)value;

- (int16_t)primitiveCodeMandatoryNumberBValue;
- (void)setPrimitiveCodeMandatoryNumberBValue:(int16_t)value_;

- (NSNumber*)primitiveModelMandatoryBoundedNumberB;
- (void)setPrimitiveModelMandatoryBoundedNumberB:(NSNumber*)value;

- (int16_t)primitiveModelMandatoryBoundedNumberBValue;
- (void)setPrimitiveModelMandatoryBoundedNumberBValue:(int16_t)value_;

- (NSNumber*)primitiveModelMandatoryCodeNotZeroNumberB;
- (void)setPrimitiveModelMandatoryCodeNotZeroNumberB:(NSNumber*)value;

- (int16_t)primitiveModelMandatoryCodeNotZeroNumberBValue;
- (void)setPrimitiveModelMandatoryCodeNotZeroNumberBValue:(int16_t)value_;

- (NSNumber*)primitiveNoValidationNumberB;
- (void)setPrimitiveNoValidationNumberB:(NSNumber*)value;

- (int16_t)primitiveNoValidationNumberBValue;
- (void)setPrimitiveNoValidationNumberBValue:(int16_t)value_;

- (NSMutableSet*)primitiveCodeMandatoryConcreteClassesD;
- (void)setPrimitiveCodeMandatoryConcreteClassesD:(NSMutableSet*)value;

@end
