//
//  HLSValidators.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/13/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Not meant to be instantiated
 */
@interface HLSValidators : NSObject {
@private
    
}

/**
 * Validates an e-mail address
 */
+ (BOOL)validateEmailAddress:(NSString *)emailAddress;

@end
