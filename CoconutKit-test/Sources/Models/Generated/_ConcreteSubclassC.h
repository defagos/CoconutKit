// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassC.h instead.

#import <CoreData/CoreData.h>
#import "ConcreteSubclassB.h"






@interface ConcreteSubclassCID : NSManagedObjectID {}
@end

@interface _ConcreteSubclassC : ConcreteSubclassB {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteSubclassCID*)objectID;




@property (nonatomic, retain) NSString *codeMandatoryStringC;


//- (BOOL)validateCodeMandatoryStringC:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *modelMandatoryBoundedPatternStringC;


//- (BOOL)validateModelMandatoryBoundedPatternStringC:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *noValidationNumberC;


//- (BOOL)validateNoValidationNumberC:(id*)value_ error:(NSError**)error_;





@end

@interface _ConcreteSubclassC (CoreDataGeneratedAccessors)

@end

@interface _ConcreteSubclassC (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCodeMandatoryStringC;
- (void)setPrimitiveCodeMandatoryStringC:(NSString*)value;




- (NSString*)primitiveModelMandatoryBoundedPatternStringC;
- (void)setPrimitiveModelMandatoryBoundedPatternStringC:(NSString*)value;




- (NSString*)primitiveNoValidationNumberC;
- (void)setPrimitiveNoValidationNumberC:(NSString*)value;




@end
