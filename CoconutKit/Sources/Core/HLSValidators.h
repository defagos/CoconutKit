//
//  HLSValidators.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/13/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

/**
 * Not meant to be instantiated
 */
@interface HLSValidators : NSObject

/**
 * Validates an e-mail address
 */
+ (BOOL)validateEmailAddress:(NSString *)emailAddress;

@end

@interface HLSValidators (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
