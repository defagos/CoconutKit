// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Manager.h instead.

#import <CoreData/CoreData.h>
#import "Person.h"

@class Employee;



@interface ManagerID : NSManagedObjectID {}
@end

@interface _Manager : Person {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ManagerID*)objectID;




@property (nonatomic, retain) NSString *department;


//- (BOOL)validateDepartment:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* employees;

- (NSMutableSet*)employeesSet;




@end

@interface _Manager (CoreDataGeneratedAccessors)

- (void)addEmployees:(NSSet*)value_;
- (void)removeEmployees:(NSSet*)value_;
- (void)addEmployeesObject:(Employee*)value_;
- (void)removeEmployeesObject:(Employee*)value_;

@end

@interface _Manager (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDepartment;
- (void)setPrimitiveDepartment:(NSString*)value;





- (NSMutableSet*)primitiveEmployees;
- (void)setPrimitiveEmployees:(NSMutableSet*)value;


@end
