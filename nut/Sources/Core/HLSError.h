//
//  HLSError.h
//  nut
//
//  Created by Samuel Défago on 04.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Helper macros for defining error identifiers.
 *
 * A module introducing new errors should:
 *   1) import this header file in its own header file
 *   2) in its header file, declare the new error identifier using the HLSDeclareError macro
 *   3) in its implementation file, define the new error identifier using the HLSDefineError macro
 * If two modules try to introduce the same error identifier, a linker error will occur (since the symbol 
 * is in this case multiply defined in two separate translation units). This is good expected behavior, 
 * and this matches the approach applied in the Apple frameworks (see e.g. NSWindow on MacOS, or UIWindow on iOS)
 *
 * Note that error identifier names should end with "Error"
 */
#define HLSDeclareError(name)           extern NSString * const name
#define HLSDefineError(name)            NSString * const name = @#name

/**
 * Class for easy NSError creation. Provides a mechanism for defining standard errors, and enforces each error
 * code to be associated with a domain and a unique code (unique inside the domain) first. Each set of standard 
 * properties is associated with a unique identifier, through which default errors can be created in a snap.
 *
 * Use the convenience methods to instantiate error objects.
 */
@interface HLSError : NSError {
@private
    
}

/**
 * Register default properties for an HLSError, and associate them with a given error identifier. These properties
 * will be used when instantiating an error from this identifier.
 * The method returns NO if it could not register the new error definition.
 *
 * If you do not need to set more than a domain and a description, use the shorter form of this method below
 *
 * This method is thread-safe
 */
+ (BOOL)registerDefaultCode:(NSInteger)code
                     domain:(NSString *)domain 
       localizedDescription:(NSString *)localizedDescription 
     localizedFailureReason:(NSString *)localizedFailureReason
localizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion
   localizedRecoveryOptions:(NSArray *)localizedRecoveryOptions
          recoveryAttempter:(id)recoveryAttempter
                 helpAnchor:(NSString *)helpAnchor
              forIdentifier:(NSString *)identifier;

/**
 * Shorter form of the default property registration method. Should be sufficient most of the time
 *
 * This method is thread-safe
 */
+ (BOOL)registerDefaultCode:(NSInteger)code
                     domain:(NSString *)domain 
       localizedDescription:(NSString *)localizedDescription 
              forIdentifier:(NSString *)identifier;

/**
 * Create an error using the standard set of properties associated with the identifier
 * 
 * The userInfo dictionary can be used to convey additional information. As documented in NSError.h, some keys can be 
 * used to define error properties (e.g. NSLocalizedDescriptionKey for localizedDescription). These keys are used
 * by HLSError for consistency. If userInfo happens to contain one of them, it will be omitted.
 *
 * If the identifier has not been registered, nil is returned.
 *
 * This method is thread-safe
 */
+ (id)errorFromIdentifier:(NSString *)identifier nestedError:(NSError *)nestedError userInfo:(NSDictionary *)userInfo;

/**
 * Same as errorFromIdentifier:nestedError:userInfo:, but without user information
 */
+ (id)errorFromIdentifier:(NSString *)identifier nestedError:(NSError *)nestedError;

/**
 * Same as errorFromIdentifier:nestedError:userInfo:, but without nested error
 */
+ (id)errorFromIdentifier:(NSString *)identifier userInfo:(NSDictionary *)userInfo;

/**
 * Same as errorFromIdentifier:nestedError:userInfo:, but without nested error and user information
 */
+ (id)errorFromIdentifier:(NSString *)identifier;

/**
 * Return the nested error if any
 */
- (NSError *)nestedError;

/**
 * Return the really user-specific information conveyed by the error (i.e. without all "reserved" keys)
 */
- (NSDictionary *)customUserInfo;

@end
