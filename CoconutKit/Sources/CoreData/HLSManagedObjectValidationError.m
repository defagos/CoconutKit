//
//  HLSManagedObjectValidationError.m
//  CoconutKit
//
//  Created by Samuel Défago on 26.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSManagedObjectValidationError.h"

#import "HLSAssert.h"

@implementation HLSManagedObjectValidationError

#pragma mark Class methods

+ (id)errorWithManagedObject:(NSManagedObject *)managedObject
                   fieldName:(NSString *)fieldName
                      errors:(NSArray *)errors
{
    return [[[[self class] alloc] initWithManagedObject:managedObject fieldName:fieldName errors:errors] autorelease];
}

+ (id)errorWithManagedObject:(NSManagedObject *)managedObject
                   fieldName:(NSString *)fieldName
                       error:(NSError *)error
{
    return [[[[self class] alloc] initWithManagedObject:managedObject fieldName:fieldName error:error] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName
                     errors:(NSArray *)errors
{
    HLSAssertObjectsInEnumerationAreKindOfClass(errors, NSError);
    NSAssert(managedObject != nil, @"A managed object must be provided");
    NSAssert([managedObject respondsToSelector:NSSelectorFromString(fieldName)], @"Invalid field name");
    NSAssert([errors count] != 0, @"At least one error must be provided");
    
    NSInteger code = ([errors count] == 1 ? NSManagedObjectValidationError : NSValidationMultipleErrorsError);
    if ((self = [super initWithDomain:NSSQLiteErrorDomain code:code])) {
        [self setObject:managedObject forKey:NSValidationObjectErrorKey];
        [self setObject:fieldName forKey:NSValidationKeyErrorKey];
        [self setObject:errors forKey:NSDetailedErrorsKey];
        
        if (code == NSValidationMultipleErrorsError) {
            [self setLocalizedDescription:NSLocalizedStringFromTable(@"Multiple validation errors", @"CoconutKit_Localizable", @"Multiple validation errors")];
        }
        else {
            [self setLocalizedDescription:NSLocalizedStringFromTable(@"Validation error", @"CoconutKit_Localizable", @"Validation error")];
        }
    }
    return  self;
}

- (id)initWithManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName
                      error:(NSError *)error
{
    return [self initWithManagedObject:managedObject fieldName:fieldName errors:[NSArray arrayWithObject:error]];
}

#pragma mark Accessors and mutators

- (NSArray *)errors
{
    return [self objectForKey:NSDetailedErrorsKey];
}

@end
