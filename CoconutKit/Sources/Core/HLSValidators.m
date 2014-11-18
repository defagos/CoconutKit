//
//  HLSValidators.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/13/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSValidators.h"

@implementation HLSValidators

+ (BOOL)validateEmailAddress:(NSString *)emailAddress
{
    // For some obscure reason, escaping the % in the directly in the format string (using %%) does not work and crashes at runtime! But creating the
    // regex outside and inserting it into the control string works. Are control strings in Objective-C really standard? 
    // The following regex is the one used by Apple, e.g. in iOS mail. Thanks to Cédric Lüthi (0xced) for its extraction
    // (method -[NSString(NSEmailAddressString) mf_isLegalEmailAddress] in /System/Library/PrivateFrameworks/MIME.framework)
    NSString *emailRegex = @"^[[:alnum:]!#$%&'*+/=?^_`{|}~-]+((\\.?)[[:alnum:]!#$%&'*+/=?^_`{|}~-]+)*@[[:alnum:]-]+(\\.[[:alnum:]-]+)*(\\.[[:alpha:]]+)+$";
    
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailPredicate evaluateWithObject:emailAddress];
}

@end
