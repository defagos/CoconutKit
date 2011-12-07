//
//  NSManagedObject+HLSValidation.h
//  CoconutKit
//
//  Created by Samuel Défago on 19.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable Core Data validation extensions early. Good places are 
 * for example main.m or your application delegate .m file
 */
#define HLSEnableNSManagedObjectValidation()                                                          \
    __attribute__ ((constructor)) void HLSEnableNSManagedObjectValidationConstructor(void)            \
    {                                                                                                 \
        [NSManagedObject injectValidation];                                                           \
    }

/**
 * Writing Core Data validations is cumbersome, error-prone and ultimately painful. Though the initial idea 
 * is good (writing a set of methods beginning with 'validate' and which perform individual and consistency
 * validations), there are several issues which make writing object validations rather inconvenient
 * (read http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CoreData/Articles/cdValidation.html
 * for more information):
 *   - the parameter received by the validation methods is an object pointer, not an object. Having to
 *     dereference an object is ugly (moreover, the pointer itself must be tested against NULL before
 *     dereferencing it), and even uglier when the documentation says you should never use this reference 
 *     to alter the object
 *   - when implementing the consistency validation methods, the super method must always be called first.
 *     If done improperly, i.e. if the NSManagedObject implementation of the consistency methods is not
 *     ultimately called, then neither will individual validations
 *   - validation methods implemented on model object classes are called when a managed object context
 *     containing a modified object is saved. On the user side, this generally happens after some form has 
 *     been completely filled. Sometimes, though, you want validations to occur as the form is being filled, 
 *     so that the user gets more accurate information about which values are incorrect and why. In such cases,
 *     validation has to be triggered for each field. Always having to write the required code (which means 
 *     catching end of input and synchronizing the model and the view) is often leads to a bunch of redundant 
 *     code which is hard to maintain
 *   - errors received by validation methods (both individual or global validation methods) must be chained 
 *     manually in their implementation according to the documentation. Not only is this error-prone and
 *     distracting (you end up merging validation code with error-chaining code), it also does not make sense 
 *     if the validation methods need to be called directly (e.g. when validating a text field interactively). 
 *     You could imagine having two sets of validation methods, one performing chaining, the other not, but
 *     this is far from ideal
 *   - global validation for insertion / update is the same, but Core Data lets you implement both separately.
 *     This does not really make sense, the logic should be the same in both cases
 *
 * The HLSValidation class extensions (there are several of them) are meant to solve those issues. Those
 * extensions need to be enabled by calling the HLSEnableNSManagedObjectValidation macro at global scope.
 * When HLSValidation extensions have been enabled, model object validation must be implemented in a different
 * way:
 *   - instead of implementing 
 *         - (BOOL)validate<fieldName>:(<class> *)pValue error:(NSError **)pError
 *     for each model field to validate, you now implement methods with signature
 *         - (BOOL)check<fieldName>:(<class>)value error:(NSError **)pError
 *     (value is always an object)
 *     As for the 'validate' methods, the 'check' methods are not meant to be called directly (i.e. public)
 *     and should remain hidden in the model object implementation file. Note that the first parameter of 
 *     'check' methods is an object, not an object pointer anymore. The pError pointer is guaranteed to be 
 *     valid (and such that *pError = nil upon method entry), eliminating the need to check the pointer 
 *     before dereferencing it. You can use this pointer to return errors which might be encountered during 
 *     field validation. Those errors will automatically be chained for you.
 *   - instead of implementing -validateForUpdate: and -validateForInsert: methods, you now implement a single
 *     -checkForConsistency: method which will be called when an inserted or updated object is saved. As for
 *     individual validations, pError is guaranteed to be valid (with *pError = nil upon method entry), you
 *     therefore do not need to check the pointer before dereferencing it. Moreover, error-chaining will be
 *     performed for you
 * Other HLSValidation class extensions leverage this new set of validation methods by providing binding
 * between widgets (currently UITextField) and model object fields. This makes synchronization and validation 
 * of forms very easy to implement. Refer to the documentation of the other HLSValidation class extensions
 * for more information.
 * 
 * This magic is implemented behing the scene by having usual -validate<fieldName>:error: methods being
 * created and injected at runtime. Those are wrappers around -check<fieldName>:error: methods which
 * factor out all usual Core Data boilerplate validation code. When you enable HLSValidation class
 * extensions, it is therefore especially important that you NEVER implement 'validate' methods anymore,
 * since this would likely conflict with the methods added at runtime.
 */
@interface NSManagedObject (HLSValidation)

/**
 * Inject the validation extensions of NSManagedObject (disabled by default). You should not call this method
 * directly, use the HLSEnableNSManagedObjectValidation macro instead
 */
+ (void)injectValidation;

/**
 * Check that a given value is valid for a specific field. The validation logic can be implemented in the 
 * xcdatamodel and / or in a -check<fieldName>:error: method. The method returns YES iff the value is valid
 */
- (BOOL)checkValue:(id)value forKey:(NSString *)key error:(NSError **)pError;

/**
 * Subclasses of NSManagedObject can override this method to perform additional consistency validations when
 * inserted or updated objects are committed (i.e. when the managed object context they live in is saved).
 * This defaut implementation does nothing and returns YES.
 *
 * When implementing this method, you do not have to (and should not) call the method on super first.
 */
- (BOOL)checkForConsistency:(NSError **)pError;

/**
 * Same as checkForConsistency: (see above), but when an object deletion is committed
 */
- (BOOL)checkForDelete:(NSError **)pError;

@end
