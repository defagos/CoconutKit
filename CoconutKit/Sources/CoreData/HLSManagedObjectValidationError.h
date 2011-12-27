//
//  HLSCoreDataError.h
//  CoconutKit
//
//  Created by Samuel Défago on 26.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSError.h"

/**
 * Designated initializer: initWithManagedObject:fieldName:errors:
 */
@interface HLSManagedObjectValidationError : HLSError {
@private
    
}

+ (id)errorWithManagedObject:(NSManagedObject *)managedObject
                   fieldName:(NSString *)fieldName
                      errors:(NSArray *)errors;
+ (id)errorWithManagedObject:(NSManagedObject *)managedObject
                   fieldName:(NSString *)fieldName
                       error:(NSError *)error;

- (id)initWithManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName
                     errors:(NSArray *)errors;
- (id)initWithManagedObject:(NSManagedObject *)managedObject
                  fieldName:(NSString *)fieldName
                      error:(NSError *)error;

@end
