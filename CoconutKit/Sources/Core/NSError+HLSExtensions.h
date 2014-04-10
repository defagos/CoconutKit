//
//  NSError+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Additions to NSError providing a convenient way to create errors and to define and access their properties.
 *
 * The interface below enforces the link between accessor methods and underlying userInfo dictionary keys. This is not
 * required, as explained in the documentation:
 *   http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorHandling/ErrorHandling.html
 *
 * Designated initializer: -initWithDomain:code:userInfo:
 */
@interface NSError (HLSExtensions)

/**
 * Instantiate an error with some code within a domain. The error is created with no information, use the mutators below to
 * add the information you need
 */
+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code;

/**
 * Convenience instantiation method for the most common case (an error conveying a description message). You can still
 * use the mutators below to add more information if needed
 */
+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription;

/**
 * Initialize an error with some code within a domain. The error is created with no information, use the mutators below to
 * add the information you need
 */
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code;

/**
 * Return the nested error which has been set (if any)
 */
- (NSError *)underlyingError;

/**
 * Return the object set for a given key. The key can either be a reserved one (see NSError) or a custom
 * one. Instead of using this generic accessor to retrieve objects corresponding to reserved keys, use the
 * standard accessors provided by NSError, or the additional ones provided above
 */
- (id)objectForKey:(NSString *)key;

/**
 * Return the user-specific information (i.e. without the information corresponding to reserved keys)
 */
- (NSDictionary *)customUserInfo;

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
 * Sets an object for some key. The key can either be a reserved one (see NSError header) or a custom one. Instead
 * of using this generic mutator to set objects corresponding to reserved keys, you should use the mutators 
 * provided above
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/**
 * Return YES iff the receiver has the provided error domain and code
 */
- (BOOL)hasCode:(NSInteger)code withinDomain:(NSString *)domain;

@end
