// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PersonInformation.h instead.

#import <CoreData/CoreData.h>

extern const struct PersonInformationAttributes {
	__unsafe_unretained NSString *birthdate;
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *numberOfChildren;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *street;
} PersonInformationAttributes;

@interface PersonInformationID : NSManagedObjectID {}
@end

@interface _PersonInformation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PersonInformationID* objectID;

@property (nonatomic, strong) NSDate* birthdate;

//- (BOOL)validateBirthdate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* firstName;

//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* lastName;

//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* numberOfChildren;

@property (atomic) int16_t numberOfChildrenValue;
- (int16_t)numberOfChildrenValue;
- (void)setNumberOfChildrenValue:(int16_t)value_;

//- (BOOL)validateNumberOfChildren:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* street;

//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;

@end

@interface _PersonInformation (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveBirthdate;
- (void)setPrimitiveBirthdate:(NSDate*)value;

- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;

- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;

- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;

- (NSNumber*)primitiveNumberOfChildren;
- (void)setPrimitiveNumberOfChildren:(NSNumber*)value;

- (int16_t)primitiveNumberOfChildrenValue;
- (void)setPrimitiveNumberOfChildrenValue:(int16_t)value_;

- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;

- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;

@end
