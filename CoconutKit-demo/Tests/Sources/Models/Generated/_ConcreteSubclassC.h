// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassC.h instead.

#import <CoreData/CoreData.h>
#import "ConcreteSubclassB.h"

extern const struct ConcreteSubclassCAttributes {
	__unsafe_unretained NSString *codeMandatoryStringC;
	__unsafe_unretained NSString *modelMandatoryBoundedPatternStringC;
	__unsafe_unretained NSString *noValidationNumberC;
} ConcreteSubclassCAttributes;

@interface ConcreteSubclassCID : ConcreteSubclassBID {}
@end

@interface _ConcreteSubclassC : ConcreteSubclassB {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConcreteSubclassCID* objectID;

@property (nonatomic, strong) NSString* codeMandatoryStringC;

//- (BOOL)validateCodeMandatoryStringC:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* modelMandatoryBoundedPatternStringC;

//- (BOOL)validateModelMandatoryBoundedPatternStringC:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* noValidationNumberC;

@property (atomic) int16_t noValidationNumberCValue;
- (int16_t)noValidationNumberCValue;
- (void)setNoValidationNumberCValue:(int16_t)value_;

//- (BOOL)validateNoValidationNumberC:(id*)value_ error:(NSError**)error_;

@end

@interface _ConcreteSubclassC (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCodeMandatoryStringC;
- (void)setPrimitiveCodeMandatoryStringC:(NSString*)value;

- (NSString*)primitiveModelMandatoryBoundedPatternStringC;
- (void)setPrimitiveModelMandatoryBoundedPatternStringC:(NSString*)value;

- (NSNumber*)primitiveNoValidationNumberC;
- (void)setPrimitiveNoValidationNumberC:(NSNumber*)value;

- (int16_t)primitiveNoValidationNumberCValue;
- (void)setPrimitiveNoValidationNumberCValue:(int16_t)value_;

@end
