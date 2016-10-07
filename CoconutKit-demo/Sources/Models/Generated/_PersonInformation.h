// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PersonInformation.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PersonInformationID : NSManagedObjectID {}
@end

@interface _PersonInformation : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PersonInformationID *objectID;

@property (nonatomic, strong, nullable) NSDate* birthdate;

@property (nonatomic, strong, nullable) NSString* city;

@property (nonatomic, strong, nullable) NSString* country;

@property (nonatomic, strong, nullable) NSString* email;

@property (nonatomic, strong, nullable) NSString* firstName;

@property (nonatomic, strong, nullable) NSString* lastName;

@property (nonatomic, strong, nullable) NSNumber* numberOfChildren;

@property (atomic) int16_t numberOfChildrenValue;
- (int16_t)numberOfChildrenValue;
- (void)setNumberOfChildrenValue:(int16_t)value_;

@property (nonatomic, strong, nullable) NSString* state;

@property (nonatomic, strong, nullable) NSString* street;

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

@interface PersonInformationAttributes: NSObject 
+ (NSString *)birthdate;
+ (NSString *)city;
+ (NSString *)country;
+ (NSString *)email;
+ (NSString *)firstName;
+ (NSString *)lastName;
+ (NSString *)numberOfChildren;
+ (NSString *)state;
+ (NSString *)street;
@end

NS_ASSUME_NONNULL_END
