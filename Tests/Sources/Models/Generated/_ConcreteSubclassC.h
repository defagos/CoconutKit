// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteSubclassC.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

#import "ConcreteSubclassB.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConcreteSubclassCID : ConcreteSubclassBID {}
@end

@interface _ConcreteSubclassC : ConcreteSubclassB
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ConcreteSubclassCID *objectID;

@property (nonatomic, strong, nullable) NSString* codeMandatoryStringC;

@property (nonatomic, strong) NSString* modelMandatoryBoundedPatternStringC;

@property (nonatomic, strong, nullable) NSNumber* noValidationNumberC;

@property (atomic) int16_t noValidationNumberCValue;
- (int16_t)noValidationNumberCValue;
- (void)setNoValidationNumberCValue:(int16_t)value_;

@end

@interface _ConcreteSubclassC (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveCodeMandatoryStringC;
- (void)setPrimitiveCodeMandatoryStringC:(nullable NSString*)value;

- (NSString*)primitiveModelMandatoryBoundedPatternStringC;
- (void)setPrimitiveModelMandatoryBoundedPatternStringC:(NSString*)value;

- (nullable NSNumber*)primitiveNoValidationNumberC;
- (void)setPrimitiveNoValidationNumberC:(nullable NSNumber*)value;

- (int16_t)primitiveNoValidationNumberCValue;
- (void)setPrimitiveNoValidationNumberCValue:(int16_t)value_;

@end

@interface ConcreteSubclassCAttributes: NSObject 
+ (NSString *)codeMandatoryStringC;
+ (NSString *)modelMandatoryBoundedPatternStringC;
+ (NSString *)noValidationNumberC;
@end

NS_ASSUME_NONNULL_END
