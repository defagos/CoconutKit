//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewBindingDelegate.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Private class encapsulating view binding information, and performing lazy binding parameter resolving, caching,
 * and automatic synchronization via KVO when possible. The bound object is resolved automatically at runtime. There
 * is no way to change or recalculate binding information: If binding information changes for some view, create a
 * new instance and replace the previous one with it
 */
@interface HLSViewBindingInformation : NSObject

/**
 * Store view binding information. A keypath and a view supporting bindings are mandatory, otherwise the method returns 
 * nil. A transformer name is optional. All kinds of keypaths are supported, including those containing keypath operators
 */
- (instancetype)initWithKeyPath:(NSString *)keyPath
                transformerName:(nullable NSString *)transformerName
                           view:(UIView *)view NS_DESIGNATED_INITIALIZER;

/**
 * Return the current value corresponding to the stored binding information (the transformer method is applied, if any). 
 * The method returns nil if the bound object has not been resolved yet
 */
@property (nonatomic, readonly, nullable) id value;

/**
 * The plain value retrieved from the bound object, without any transformation, nil if the bound object has not been
 * resolved yet, or if the view cannot display it
 */
@property (nonatomic, readonly, nullable) id rawValue;

/**
 * The value currently made available for input by the view. If the view does not support input (supportingInput = NO), 
 * the method returns nil
 */
@property (nonatomic, readonly, nullable) id inputValue;

/**
 * Update the view using the current underlying bound value. Then change can be animated if the view supports it
 */
- (void)updateViewAnimated:(BOOL)animated;

/**
 * Return the keypath to which binding is made
 */
@property (nonatomic, readonly, copy) NSString *keyPath;

/**
 * The bound view
 */
@property (nonatomic, readonly, weak, nullable) UIView *view;

/**
 * Return the transformer name specified during initialization
 */
@property (nonatomic, readonly, copy, nullable) NSString *transformerName;

/**
 * Return the resolved bound object, nil if none or not resolved yet
 */
@property (nonatomic, readonly, weak, nullable) id objectTarget;

/**
 * Return the last component of the key path (might be prefixed with an operator)
 */
@property (nonatomic, readonly, copy) NSString *lastKeyPathComponent;

/**
 * Return the last object in the key path (before the final key path component is applied)
 */
@property (nonatomic, readonly, nullable) id lastObjectTarget;

/**
 * The expected class for the raw model value, nil if it cannot be reliably determined
 */
@property (nonatomic, readonly, nullable) Class rawClass;

/**
 * The expected class for input, nil if it cannot be reliably determined
 */
@property (nonatomic, readonly, nullable) Class inputClass;

/**
 * Return the object which the transformation selector will be called on, nil if none or not resolved yet
 */
@property (nonatomic, readonly, weak, nullable) id transformationTarget;

/**
 * Return the selector which will be called on the transformation target, NULL if none or not resolved yet
 */
@property (nonatomic, readonly, nullable) SEL transformationSelector;

/**
 * Return the object binding events will be sent to, nil if none or not resolved yet
 */
@property (nonatomic, readonly, weak, nullable) id<HLSViewBindingDelegate> delegate;

/**
 * Return YES iff the binding has been verified completely. If verified, use the error property to check whether
 * the binding was successfully resolved or not. If not verified, use the error property to retrieve information
 * about why the binding could not be verified
 */
@property (nonatomic, readonly, getter=isVerified) BOOL verified;

/**
 * Reason why a binding cannot be completely verified yet (if verified = NO), why binding failed (if verified = YES),
 * or nil if no information is available
 */
@property (nonatomic, readonly, nullable) NSError *error;

/**
 * Return YES iff the view supports input
 */
@property (nonatomic, readonly, getter=isSupportingInput) BOOL supportingInput;

/**
 * Return YES iff the view is automatically updated when the underlying model changes
 */
@property (nonatomic, readonly, getter=isViewAutomaticallyUpdated) BOOL viewAutomaticallyUpdated;

/**
 * Return YES iff the model is automatically updated when the view changes
 */
@property (nonatomic, readonly, getter=isModelAutomaticallyUpdated) BOOL modelAutomaticallyUpdated;

/**
 * Check and / or update the model using the current input value, as returned by -inputValue. Return YES iff successful,
 * otherwise NO and error information. Fails if the view does not support input (supportingInput = NO). If both
 * check and update are made, failure to perform one does not prevent the other from being attempted
 */
- (BOOL)check:(BOOL)check update:(BOOL)update withError:(out NSError *__autoreleasing *)pError;

/**
 * Check and / or update the model using the specified value. Return YES iff successful, otherwise NO and error information.
 * Fails if the view does not support input (supportingInput = NO). If both check and update are made, failure to perform 
 * one does not prevent the other from being attempted
 */
- (BOOL)check:(BOOL)check update:(BOOL)update withInputValue:(id)inputValue error:(out NSError *__autoreleasing *)pError;

@end

@interface HLSViewBindingInformation (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

