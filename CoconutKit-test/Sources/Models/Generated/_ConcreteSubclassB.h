// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassB.h instead.

#import <CoreData/CoreData.h>
#import "AbstractClassA.h"







@interface ConcreteSubclassBID : NSManagedObjectID {}
@end

@interface _ConcreteSubclassB : AbstractClassA {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteSubclassBID*)objectID;




@property (nonatomic, retain) NSString *codeMandatoryStringB;


//- (BOOL)validateCodeMandatoryStringB:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *modelMandatoryCodeNotEmptyStringB;


//- (BOOL)validateModelMandatoryCodeNotEmptyStringB:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *modelMandatoryStringB;


//- (BOOL)validateModelMandatoryStringB:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *noValidationStringB;


//- (BOOL)validateNoValidationStringB:(id*)value_ error:(NSError**)error_;





@end

@interface _ConcreteSubclassB (CoreDataGeneratedAccessors)

@end

@interface _ConcreteSubclassB (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCodeMandatoryStringB;
- (void)setPrimitiveCodeMandatoryStringB:(NSString*)value;




- (NSString*)primitiveModelMandatoryCodeNotEmptyStringB;
- (void)setPrimitiveModelMandatoryCodeNotEmptyStringB:(NSString*)value;




- (NSString*)primitiveModelMandatoryStringB;
- (void)setPrimitiveModelMandatoryStringB:(NSString*)value;




- (NSString*)primitiveNoValidationStringB;
- (void)setPrimitiveNoValidationStringB:(NSString*)value;




@end
