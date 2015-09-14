//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "ConcreteClassD.h"

#import "TestErrors.h"

@implementation ConcreteClassD

#pragma mark Individual validations

// noValidationNumberD and noValidationStringD: No validation constraints, neither in the code, nor in the xcdatamodel

#pragma mark Consistency validations

- (BOOL)checkForDelete:(NSError *__autoreleasing *)pError
{
    if ([self.noValidationStringD isEqualToString:@"LOCKED"]) {
        if (pError) {
            *pError = [NSError errorWithDomain:TestValidationErrorDomain
                                          code:TestValidationLockedObjectError];            
        }
        return NO;
    }
    
    return YES;
}

@end
