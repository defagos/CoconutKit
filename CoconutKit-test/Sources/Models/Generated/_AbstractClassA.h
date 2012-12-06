// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AbstractClassA.h instead.

#import <CoreData/CoreData.h>


extern const struct AbstractClassAAttributes {
	 NSString *codeMandatoryNotEmptyStringA;
	 NSString *noValidationStringA;
} AbstractClassAAttributes;

extern const struct AbstractClassARelationships {
} AbstractClassARelationships;

extern const struct AbstractClassAFetchedProperties {
} AbstractClassAFetchedProperties;





@interface AbstractClassAID : NSManagedObjectID {}
@end

@interface _AbstractClassA : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AbstractClassAID*)objectID;





@property (nonatomic, retain) NSString* codeMandatoryNotEmptyStringA;



//- (BOOL)validateCodeMandatoryNotEmptyStringA:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* noValidationStringA;



//- (BOOL)validateNoValidationStringA:(id*)value_ error:(NSError**)error_;






@end

@interface _AbstractClassA (CoreDataGeneratedAccessors)

@end

@interface _AbstractClassA (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCodeMandatoryNotEmptyStringA;
- (void)setPrimitiveCodeMandatoryNotEmptyStringA:(NSString*)value;




- (NSString*)primitiveNoValidationStringA;
- (void)setPrimitiveNoValidationStringA:(NSString*)value;




@end
