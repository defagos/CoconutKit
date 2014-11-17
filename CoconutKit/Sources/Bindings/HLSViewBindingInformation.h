//
//  HLSViewBindingInformation.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingDelegate.h"

/**
 * Private class encapsulating view binding information, and performing lazy binding parameter resolving, caching,
 * and automatic synchronization via KVO when possible
 */
@interface HLSViewBindingInformation : NSObject

/**
 * Store view binding information. A keypath and a view supporting bindings are mandatory, otherwise the method returns 
 * nil. A transformer name is optional. All kinds of keypaths are supported, including those containing keypath operators
 */
- (instancetype)initWithKeyPath:(NSString *)keyPath
                transformerName:(NSString *)transformerName
                           view:(UIView *)view NS_DESIGNATED_INITIALIZER;

/**
 * Return the current value corresponding to the stored binding information (the transformer method is applied, if any). 
 * If keypath information is invalid, this method returns nil
 */
- (id)value;

/**
 * The plain value retrieved from the keypath. No transformer is applied
 */
- (id)rawValue;

/**
 * The value currently displayed by the view. If the view does not support input (supportingInput = NO), the method
 * returns nil
 */
- (id)inputValue;

/**
 * Update the view using the current underlying bound value. Then change can be animated if the view supports it
 */
- (void)updateViewAnimated:(BOOL)animated;

/**
 * Try to transform back a value into a value which is compatible with the keypath. Return YES and the value iff the 
 * reverse transformation could be achieved (the method always succeeds if no transformer has been specified).
 * Errors are returned to the binding delegate (if any) and to the caller
 */
- (BOOL)convertTransformedValue:(id)transformedValue toValue:(id *)pValue withError:(NSError **)pError;

/**
 * Check whether a value is correct according to any validation which might have been set (validation is made through
 * KVO, see NSKeyValueCoding category on NSObject for more information). The method returns YES iff the check is 
 * successful, otherwise the method returns NO, in which case errors are returned to the binding delegate (if any) and 
 * to the caller
 */
- (BOOL)checkValue:(id)value withError:(NSError **)pError;

/**
 * Update the value which the key path points at with another value. Does not perform any check, -checkValue:withError: 
 * must be called for that purpose. Returns YES iff the value could be updated, NO otherwise (e.g. if no setter is 
 * available). Errors are returned to the validation delegate (if any) and to the caller
 */
- (BOOL)updateWithValue:(id)value error:(NSError **)pError;

/**
 * Return the keypath to which binding is made
 */
@property (nonatomic, readonly, strong) NSString *keyPath;

/**
 * The bound view
 */
@property (nonatomic, readonly, weak) UIView *view;

/**
 * Return the transformer name specified during initialization
 */
@property (nonatomic, readonly, strong) NSString *transformerName;

/**
 * Return the resolved bound object, nil if none or not resolved yet
 */
@property (nonatomic, readonly, weak) id objectTarget;

/**
 * Return the object which the transformation selector will be called on, nil if none or not resolved yet
 */
@property (nonatomic, readonly, weak) id transformationTarget;

/**
 * Return the selector which will be called on the transformation target, nil if none or not resolved yet
 */
@property (nonatomic, readonly, assign) SEL transformationSelector;

/**
 * Return the object binding events will be sent to, nil if none or not resolved yet
 */
@property (nonatomic, readonly, weak) id<HLSViewBindingDelegate> delegate;

/**
 * Return YES iff the binding has been verified completely. If verified, use the error property to check whether
 * the binding was successfully resolved or not. If not verified, use the error property to retrieve information
 * about why the binding could not be verified
 */
@property (nonatomic, readonly, assign, getter=isVerified) BOOL verified;

/**
 * Reason why a binding cannot be completely verified yet (if verified = NO), why binding failed (if verified = YES),
 * or nil if no information is available
 */
@property (nonatomic, readonly, strong) NSError *error;

/**
 * Return YES iff the view is automatically updated when the underlying model changes
 */
@property (nonatomic, readonly, assign, getter=isUpdatedAutomatically) BOOL updatedAutomatically;

/**
 * Return YES iff the view supports input
 */
@property (nonatomic, readonly, assign, getter=isSupportingInput) BOOL supportingInput;

/**
 * Return YES iff the model is automatically updated when the view changes
 */
@property (nonatomic, readonly, assign, getter=isUpdatingAutomatically) BOOL updatingAutomatically;

@end

@interface HLSViewBindingInformation (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

@interface HLSViewBindingInformation (ConvenienceMethods)

- (BOOL)checkInputValue:(id)inputValue withError:(NSError **)pError;
- (BOOL)updateModelWithInputValue:(id)inputValue error:(NSError **)pError;
- (BOOL)checkAndUpdateModelWithInputValue:(id)inputValue error:(NSError **)pError;

- (BOOL)checkInputValueWithError:(NSError **)pError;
- (BOOL)updateModelWithInputValueError:(NSError **)pError;
- (BOOL)checkAndUpdateModelWithInputValueError:(NSError **)pError;

@end
