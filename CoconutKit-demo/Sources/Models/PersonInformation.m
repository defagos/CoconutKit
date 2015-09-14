//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "PersonInformation.h"

#import "DemoErrors.h"

@implementation PersonInformation

#pragma mark Individudal validation methods

- (BOOL)checkFirstName:(NSString *)firstName error:(NSError *__autoreleasing *)pError
{
    if (! [firstName isFilled]) {
        if (pError) {
            *pError = [NSError errorWithDomain:DemoErrorDomain
                                          code:DemoMandatoryError
                          localizedDescription:NSLocalizedString(@"Missing first name", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkLastName:(NSString *)lastName error:(NSError *__autoreleasing *)pError
{
    if (! [lastName isFilled]) {
        if (pError) {
            *pError = [NSError errorWithDomain:DemoErrorDomain
                                          code:DemoMandatoryError
                          localizedDescription:NSLocalizedString(@"Missing last name", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkEmail:(NSString *)email error:(NSError *__autoreleasing *)pError
{
    // Optional
    if (! [email isFilled]) {
        return YES;
    }
    
    if (! [HLSValidators validateEmailAddress:email]) {
        if (pError) {
            *pError = [NSError errorWithDomain:DemoErrorDomain
                                          code:DemoIncorrectError
                          localizedDescription:NSLocalizedString(@"Invalid email address", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkNbrChildren:(NSNumber *)nbrChildren error:(NSError *__autoreleasing *)pError
{
    if ([nbrChildren integerValue] < 0) {
        if (pError) {
            *pError = [NSError errorWithDomain:DemoErrorDomain
                                          code:DemoIncorrectError
                          localizedDescription:NSLocalizedString(@"This value cannot be negative", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkStreet:(NSString *)street error:(NSError *__autoreleasing *)pError
{
    // Optional
    return YES;
}

- (BOOL)checkCity:(NSString *)city error:(NSError *__autoreleasing *)pError
{
    if (! [city isFilled]) {
        if (pError) {
            *pError = [NSError errorWithDomain:DemoErrorDomain
                                          code:DemoMandatoryError
                          localizedDescription:NSLocalizedString(@"Missing city", nil)];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)checkState:(NSString *)state error:(NSError *__autoreleasing *)pError
{
    // Optional
    return YES;
}

- (BOOL)checkCountry:(NSString *)country error:(NSError *__autoreleasing *)pError
{
    if (! [country isFilled]) {
        if (pError) {
            *pError = [NSError errorWithDomain:DemoErrorDomain
                                          code:DemoMandatoryError
                          localizedDescription:NSLocalizedString(@"Missing country", nil)];
        }
        return NO;
    }
    
    return YES;
}

@end
