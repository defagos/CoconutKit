// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteClassD.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ConcreteSubclassB;

@interface ConcreteClassDID : NSManagedObjectID {}
@end

@interface _ConcreteClassD : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConcreteClassDID *objectID;

@property (nonatomic, strong, nullable) NSNumber* noValidationNumberD;

@property (atomic) int16_t noValidationNumberDValue;
- (int16_t)noValidationNumberDValue;
- (void)setNoValidationNumberDValue:(int16_t)value_;

@property (nonatomic, strong, nullable) NSString* noValidationStringD;

@property (nonatomic, strong, nullable) NSSet<ConcreteSubclassB*> *concreteSubclassB;
- (nullable NSMutableSet<ConcreteSubclassB*>*)concreteSubclassBSet;

@end

@interface _ConcreteClassD (ConcreteSubclassBCoreDataGeneratedAccessors)
- (void)addConcreteSubclassB:(NSSet<ConcreteSubclassB*>*)value_;
- (void)removeConcreteSubclassB:(NSSet<ConcreteSubclassB*>*)value_;
- (void)addConcreteSubclassBObject:(ConcreteSubclassB*)value_;
- (void)removeConcreteSubclassBObject:(ConcreteSubclassB*)value_;

@end

@interface _ConcreteClassD (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveNoValidationNumberD;
- (void)setPrimitiveNoValidationNumberD:(nullable NSNumber*)value;

- (int16_t)primitiveNoValidationNumberDValue;
- (void)setPrimitiveNoValidationNumberDValue:(int16_t)value_;

- (nullable NSString*)primitiveNoValidationStringD;
- (void)setPrimitiveNoValidationStringD:(nullable NSString*)value;

- (NSMutableSet<ConcreteSubclassB*>*)primitiveConcreteSubclassB;
- (void)setPrimitiveConcreteSubclassB:(NSMutableSet<ConcreteSubclassB*>*)value;

@end

@interface ConcreteClassDAttributes: NSObject 
+ (NSString *)noValidationNumberD;
+ (NSString *)noValidationStringD;
@end

@interface ConcreteClassDRelationships: NSObject
+ (NSString *)concreteSubclassB;
@end

NS_ASSUME_NONNULL_END
