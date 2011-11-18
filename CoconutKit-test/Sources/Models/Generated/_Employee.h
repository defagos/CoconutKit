// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Employee.h instead.

#import <CoreData/CoreData.h>
#import "Person.h"

@class Manager;



@interface EmployeeID : NSManagedObjectID {}
@end

@interface _Employee : Person {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EmployeeID*)objectID;




@property (nonatomic, retain) NSDecimalNumber *income;


//- (BOOL)validateIncome:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) Manager* manager;

//- (BOOL)validateManager:(id*)value_ error:(NSError**)error_;




@end

@interface _Employee (CoreDataGeneratedAccessors)

@end

@interface _Employee (CoreDataGeneratedPrimitiveAccessors)


- (NSDecimalNumber*)primitiveIncome;
- (void)setPrimitiveIncome:(NSDecimalNumber*)value;





- (Manager*)primitiveManager;
- (void)setPrimitiveManager:(Manager*)value;


@end
