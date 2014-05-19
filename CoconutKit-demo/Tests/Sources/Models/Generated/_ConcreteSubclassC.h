// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassC.h instead.

#import <CoreData/CoreData.h>
#import "ConcreteSubclassB.h"

extern const struct ConcreteSubclassCAttributes {
	 NSString *codeMandatoryStringC;
	 NSString *modelMandatoryBoundedPatternStringC;
	 NSString *noValidationNumberC;
} ConcreteSubclassCAttributes;

extern const struct ConcreteSubclassCRelationships {
} ConcreteSubclassCRelationships;

extern const struct ConcreteSubclassCFetchedProperties {
} ConcreteSubclassCFetchedProperties;






@interface ConcreteSubclassCID : NSManagedObjectID {}
@end

@interface _ConcreteSubclassC : ConcreteSubclassB {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteSubclassCID*)objectID;





@property (nonatomic, retain) NSString* codeMandatoryStringC;



//- (BOOL)validateCodeMandatoryStringC:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* modelMandatoryBoundedPatternStringC;



//- (BOOL)validateModelMandatoryBoundedPatternStringC:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* noValidationNumberC;



@property int16_t noValidationNumberCValue;
- (int16_t)noValidationNumberCValue;
- (void)setNoValidationNumberCValue:(int16_t)value_;

//- (BOOL)validateNoValidationNumberC:(id*)value_ error:(NSError**)error_;






@end

@interface _ConcreteSubclassC (CoreDataGeneratedAccessors)

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
