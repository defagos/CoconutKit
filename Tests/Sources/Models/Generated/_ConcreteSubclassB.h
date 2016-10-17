// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassB.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "AbstractClassA.h"

NS_ASSUME_NONNULL_BEGIN

@class ConcreteClassD;

@interface ConcreteSubclassBID : AbstractClassAID {}
@end

@interface _ConcreteSubclassB : AbstractClassA
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConcreteSubclassBID *objectID;

@property (nonatomic, strong, nullable) NSNumber* codeMandatoryNumberB;

@property (atomic) int16_t codeMandatoryNumberBValue;
- (int16_t)codeMandatoryNumberBValue;
- (void)setCodeMandatoryNumberBValue:(int16_t)value_;

@property (nonatomic, strong) NSNumber* modelMandatoryBoundedNumberB;

@property (atomic) int16_t modelMandatoryBoundedNumberBValue;
- (int16_t)modelMandatoryBoundedNumberBValue;
- (void)setModelMandatoryBoundedNumberBValue:(int16_t)value_;

@property (nonatomic, strong) NSNumber* modelMandatoryCodeNotZeroNumberB;

@property (atomic) int16_t modelMandatoryCodeNotZeroNumberBValue;
- (int16_t)modelMandatoryCodeNotZeroNumberBValue;
- (void)setModelMandatoryCodeNotZeroNumberBValue:(int16_t)value_;

@property (nonatomic, strong, nullable) NSNumber* noValidationNumberB;

@property (atomic) int16_t noValidationNumberBValue;
- (int16_t)noValidationNumberBValue;
- (void)setNoValidationNumberBValue:(int16_t)value_;

@property (nonatomic, strong, nullable) NSSet<ConcreteClassD*> *codeMandatoryConcreteClassesD;
- (nullable NSMutableSet<ConcreteClassD*>*)codeMandatoryConcreteClassesDSet;

@end

@interface _ConcreteSubclassB (CodeMandatoryConcreteClassesDCoreDataGeneratedAccessors)
- (void)addCodeMandatoryConcreteClassesD:(NSSet<ConcreteClassD*>*)value_;
- (void)removeCodeMandatoryConcreteClassesD:(NSSet<ConcreteClassD*>*)value_;
- (void)addCodeMandatoryConcreteClassesDObject:(ConcreteClassD*)value_;
- (void)removeCodeMandatoryConcreteClassesDObject:(ConcreteClassD*)value_;

@end

@interface _ConcreteSubclassB (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveCodeMandatoryNumberB;
- (void)setPrimitiveCodeMandatoryNumberB:(nullable NSNumber*)value;

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

- (nullable NSNumber*)primitiveNoValidationNumberB;
- (void)setPrimitiveNoValidationNumberB:(nullable NSNumber*)value;

- (int16_t)primitiveNoValidationNumberBValue;
- (void)setPrimitiveNoValidationNumberBValue:(int16_t)value_;

- (NSMutableSet<ConcreteClassD*>*)primitiveCodeMandatoryConcreteClassesD;
- (void)setPrimitiveCodeMandatoryConcreteClassesD:(NSMutableSet<ConcreteClassD*>*)value;

@end

@interface ConcreteSubclassBAttributes: NSObject 
+ (NSString *)codeMandatoryNumberB;
+ (NSString *)modelMandatoryBoundedNumberB;
+ (NSString *)modelMandatoryCodeNotZeroNumberB;
+ (NSString *)noValidationNumberB;
@end

@interface ConcreteSubclassBRelationships: NSObject
+ (NSString *)codeMandatoryConcreteClassesD;
@end

NS_ASSUME_NONNULL_END
