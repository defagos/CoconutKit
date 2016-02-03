//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

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
