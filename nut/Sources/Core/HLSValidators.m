//
//  HLSValidators.m
//  nut
//
//  Created by Samuel Défago on 10/13/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSValidators.h"

#import "HLSAssert.h"

@implementation HLSValidators

+ (BOOL)validateEmailAddress:(NSString *)emailAddress
{
    // For some obscure reason, escaping the % in the directly in the format string (using %%) does not work and crashes at runtime! But creating the
    // regex outside and inserting it into the control string works. Are control strings in Objective-C really standard? 
    // Not perfect, but should suit 98% of the e-mail addresses
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailPredicate evaluateWithObject:emailAddress];
}

#pragma mark Object creation and destruction

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

@end
