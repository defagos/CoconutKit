// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PersonInformation.h instead.

#import <CoreData/CoreData.h>

extern const struct PersonInformationAttributes {
	 NSString *birthdate;
	 NSString *city;
	 NSString *country;
	 NSString *email;
	 NSString *firstName;
	 NSString *lastName;
	 NSString *nbrChildren;
	 NSString *state;
	 NSString *street;
} PersonInformationAttributes;

@interface PersonInformationID : NSManagedObjectID {}
@end

@interface _PersonInformation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PersonInformationID* objectID;

@property (nonatomic, retain) NSDate* birthdate;

//- (BOOL)validateBirthdate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* firstName;

//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* lastName;

//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSNumber* nbrChildren;

@property (atomic) int16_t nbrChildrenValue;
- (int16_t)nbrChildrenValue;
- (void)setNbrChildrenValue:(int16_t)value_;

//- (BOOL)validateNbrChildren:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;

@property (nonatomic, retain) NSString* street;

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

- (NSNumber*)primitiveNbrChildren;
- (void)setPrimitiveNbrChildren:(NSNumber*)value;

- (int16_t)primitiveNbrChildrenValue;
- (void)setPrimitiveNbrChildrenValue:(int16_t)value_;

- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;

- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;

@end
