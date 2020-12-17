//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Not meant to be instantiated
 */
@interface HLSValidators : NSObject

/**
 * Validates an e-mail address
 */
+ (BOOL)validateEmailAddress:(nullable NSString *)emailAddress;

@end

@interface HLSValidators (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
