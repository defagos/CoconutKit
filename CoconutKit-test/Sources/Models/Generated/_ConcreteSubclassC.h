// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassC.h instead.

#import <CoreData/CoreData.h>
#import "ConcreteSubclassB.h"

@class ConcreteClassD;






@interface ConcreteSubclassCID : NSManagedObjectID {}
@end

@interface _ConcreteSubclassC : ConcreteSubclassB {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ConcreteSubclassCID*)objectID;




@property (nonatomic, retain) NSString *codeMandatoryStringC;


//- (BOOL)validateCodeMandatoryStringC:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *modelMandatoryCodeNotEmptyStringC;


//- (BOOL)validateModelMandatoryCodeNotEmptyStringC:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *modelMandatoryStringC;


//- (BOOL)validateModelMandatoryStringC:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *noValidationStringC;


//- (BOOL)validateNoValidationStringC:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* classDObjects;

- (NSMutableSet*)classDObjectsSet;




@end

@interface _ConcreteSubclassC (CoreDataGeneratedAccessors)

- (void)addClassDObjects:(NSSet*)value_;
- (void)removeClassDObjects:(NSSet*)value_;
- (void)addClassDObjectsObject:(ConcreteClassD*)value_;
- (void)removeClassDObjectsObject:(ConcreteClassD*)value_;

@end

@interface _ConcreteSubclassC (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCodeMandatoryStringC;
- (void)setPrimitiveCodeMandatoryStringC:(NSString*)value;




- (NSString*)primitiveModelMandatoryCodeNotEmptyStringC;
- (void)setPrimitiveModelMandatoryCodeNotEmptyStringC:(NSString*)value;




- (NSString*)primitiveModelMandatoryStringC;
- (void)setPrimitiveModelMandatoryStringC:(NSString*)value;




- (NSString*)primitiveNoValidationStringC;
- (void)setPrimitiveNoValidationStringC:(NSString*)value;





- (NSMutableSet*)primitiveClassDObjects;
- (void)setPrimitiveClassDObjects:(NSMutableSet*)value;


@end
