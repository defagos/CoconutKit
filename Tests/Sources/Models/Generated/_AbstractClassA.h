// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AbstractClassA.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AbstractClassAID : NSManagedObjectID {}
@end

@interface _AbstractClassA : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) AbstractClassAID *objectID;

@property (nonatomic, strong, nullable) NSString* codeMandatoryNotEmptyStringA;

@property (nonatomic, strong, nullable) NSString* noValidationStringA;

@end

@interface _AbstractClassA (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveCodeMandatoryNotEmptyStringA;
- (void)setPrimitiveCodeMandatoryNotEmptyStringA:(nullable NSString*)value;

- (nullable NSString*)primitiveNoValidationStringA;
- (void)setPrimitiveNoValidationStringA:(nullable NSString*)value;

@end

@interface AbstractClassAAttributes: NSObject 
+ (NSString *)codeMandatoryNotEmptyStringA;
+ (NSString *)noValidationStringA;
@end

NS_ASSUME_NONNULL_END
