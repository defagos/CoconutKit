//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXPORT NSString * const HLSDetailedErrorsKey;           // Key for storing the multiple error list in the user info dictionary

/**
 * Extensions to NSError providing a convenient way to create errors. Mutability methods have been implemented so that
 * information can be added to existing errors. The usual NSError interface only allows immutable errors creation, but:
 *   - creating errors this way is ugly (the error information must be provided as a dictionary with reserved keys)
 *   - when you want to add information, e.g. nest more errors as you perform validations in a row, you have to
 *     create a new error
 * The extensions below make error creation more descriptive by letting you add error information via properly named
 * methods. Moreover, they make it possible to add informaton to an existing error, without having to create a new
 * one. 
 *
 * Since conventional NSErrors are immutable, these extensions cheat by changing the object identity (dynamic
 * subclassing) when a mutator is first called, so that a mutable userInfo can be internally added. If you do 
 * not use any mutability method, these extension have no runtime or space cost in comparison to a standard NSError.
 *
 * The interface below enforces the link between accessor methods and underlying userInfo dictionary keys. This is not
 * required, as explained in the documentation:
 *   http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorHandling/ErrorHandling.html
 */
@interface NSError (HLSExtensions)

/**
 * Instantiate an error with some code within a domain. The error is created with no information, use the mutators below to
 * add the information you need
 */
+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code;

/**
 * Convenience instantiation method for the most common case (an error conveying a description message). You can still
 * use the mutators below to add more information if needed
 */
// FIXME: Warning: This method already exists elsewhere! Check class dump!
+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(nullable NSString *)localizedDescription;

/**
 * Combine a given error with another existing one, passed by reference. For convenience of use, the resulting error is
 * returned by reference, and also as method returned value. Multiple errors are combined as an HLSCoreErrorMultipleErrors
 * in the HLSCoreErrorDomain error domain. If no existing error is provided, the new resulting error is simply the
 * new error provided. Wrapped errors can be retrieved as an array of errors under the HLSDetailedErrorsKey key.
 */
+ (nullable NSError *)combineError:(nullable NSError *)newError withError:(inout NSError *__autoreleasing *)pExistingError;

/**
 * Initialize an error with some code within a domain. The error is created with no information, use the mutators below to
 * add the information you need
 */
- (instancetype)initWithDomain:(NSString *)domain code:(NSInteger)code;

/**
 * Set / return a nested error
 */
@property (nonatomic, nullable) NSError *underlyingError;

/**
 * Return the object set for a given key. The key can either be a reserved one (see NSError) or a custom
 * one. Instead of using this generic accessor to retrieve objects corresponding to reserved keys, use the
 * standard accessors provided by NSError, or the additional ones provided above
 */
- (nullable id)objectForKey:(NSString *)key;

/**
 * Return the object set for a given key. If no object has been set, the method returns nil. If an array of
 * objects has been set, the method returns it. In all other cases (single object, or other collection of
 * objects, e.g. a set), the method wraps the object into an array before returning it
 */
- (nullable NSArray *)objectsForKey:(NSString *)key;

/**
 * Return the user-specific information (i.e. without the information corresponding to reserved keys)
 */
@property (nonatomic, readonly, nullable) NSDictionary *customUserInfo;

/**
 * Various mutators for setting standard NSError properties. Please refer to the NSError documentation for more information
 */
@property (nonatomic, copy, nullable) NSString *localizedDescription;
@property (nonatomic, copy, nullable) NSString *localizedFailureReason;
@property (nonatomic, copy, nullable) NSString *localizedRecoverySuggestion;
@property (nonatomic, nullable) NSArray<NSString *> *localizedRecoveryOptions;
@property (nonatomic, nullable) id recoveryAttempter;
@property (nonatomic, copy, nullable) NSString *helpAnchor;

/**
 * Set an object for some key. The key can either be a reserved one (see NSError header) or a custom one. Instead
 * of using this generic mutator to set objects corresponding to reserved keys, you should use the mutators 
 * provided above
 */
- (void)setObject:(nullable id)object forKey:(NSString *)key;

/**
 * Add an object for some key. If the key is already set and points to a single object, this object is wrapped
 * into an array, and the new object is added to its end. It the key already points to an array, the new object 
 * is simply appended to it. If the key does not currently point at any object, the method simply assigns it
 * the provided object
 */
- (void)addObject:(nullable id)object forKey:(NSString *)key;

/**
 * Same as -addObject:forKey:, but adding several objects from an array.
 */
- (void)addObjects:(nullable NSArray *)objects forKey:(NSString *)key;

/**
 * Return YES iff the receiver has the provided error domain and code
 */
- (BOOL)hasCode:(NSInteger)code withinDomain:(NSString *)domain;

@end

NS_ASSUME_NONNULL_END
