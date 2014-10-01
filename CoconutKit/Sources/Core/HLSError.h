//
//  HLSError.h
//  CoconutKit
//
//  Created by Samuel Défago on 10.12.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

/**
 * Lightweight abstract subclass of NSError providing a convenient way to create errors and to define and access
 * their properties.
 *
 * This class enforces the link between accessor methods and underlying userInfo dictionary keys. This is not
 * required, as explained in the documentation:
 *   http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorHandling/ErrorHandling.html
 */
@interface HLSError : NSError

/**
 * Instantiate an error with some code within a domain. The error is created with no information, use the mutators below to 
 * add the information you need
 */
+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code;

/**
 * Convenience instantiation method for the most common case (an error conveying a description message). You can still
 * use the mutators below to add more information if needed
 */
+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription;

/**
 * Initialize an error with some code within a domain. The error is created with no information, use the mutators below to
 * add the information you need
 */
- (instancetype)initWithDomain:(NSString *)domain code:(NSInteger)code NS_DESIGNATED_INITIALIZER;

/**
 * Various mutators for setting standard NSError properties. Please refer to the NSError documentation for more information
 */
- (void)setLocalizedDescription:(NSString *)localizedDescription;
- (void)setLocalizedFailureReason:(NSString *)localizedFailureReason;
- (void)setLocalizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion;
- (void)setLocalizedRecoveryOptions:(NSArray *)localizedRecoveryOptions;
- (void)setRecoveryAttempter:(id)recoveryAttempter;
- (void)setHelpAnchor:(NSString *)helpAnchor;

/**
 * Set a nested error
 */
- (void)setUnderlyingError:(NSError *)underlyingError;

/**
 * Sets an object for some key. The key can either be a reserved one (see NSError) or a custom one. Instead 
 * of using this generic mutator to set objects corresponding to reserved keys, use the mutators provided
 * by HLSError
 */
- (void)setObject:(id)object forKey:(NSString *)key;

@end
