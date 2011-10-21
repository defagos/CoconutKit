// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Customer.h instead.

#import <CoreData/CoreData.h>











@interface CustomerID : NSManagedObjectID {}
@end

@interface _Customer : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CustomerID*)objectID;




@property (nonatomic, retain) NSString *city;


//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *country;


//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *email;


//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *firstName;


//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *lastName;


//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *state;


//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *street;


//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;





@end

@interface _Customer (CoreDataGeneratedAccessors)

@end

@interface _Customer (CoreDataGeneratedPrimitiveAccessors)


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




- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;




- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;




@end
