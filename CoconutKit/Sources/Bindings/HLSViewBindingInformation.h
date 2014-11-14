//
//  HLSViewBindingInformation.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingDelegate.h"

/**
 * Private class encapsulating view binding information, and performing lazy binding parameter validation and caching
 */
@interface HLSViewBindingInformation : NSObject

/**
 * Store view binding information. A keypath and a view are mandatory, otherwise the method returns nil. The object
 * parameter can be one of the following:
 *   - a non-nil object, which the keypath is applied to (binding to an object)
 *   - nil, in which case the keypath is applied to the responder chain starting with view.superview
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
 * The value retrieved from the keypath. No transformer is applied
 */
- (id)rawValue;

/**
 * The value currently displayed by the view
 */
- (id)displayedValue;

/**
 * Update the view using the current underlying bound value
 */
- (void)updateViewAnimated:(BOOL)animated;

/**
 * Try to transform back a value into a value which could be assigned to the key path. Return YES and the value iff the 
 * reverse transformation could be achieved, i.e. if a reverse transformation is available (if a transformer has been set)
 * and could be successfully applied. Errors are returned to the validation delegate (if any) and to the caller
 */
- (BOOL)convertTransformedValue:(id)transformedValue toValue:(id *)pValue withError:(NSError **)pError;

/**
 * Check whether a value is correct according to any validation which might have been set. Errors are returned to the 
 * validation delegate (if any) and to the caller
 *
 * Returns YES iff the check was successful
 */
- (BOOL)checkValue:(id)value withError:(NSError **)pError;

/**
 * Update the value which the key path points at with another value. Does not perform any check, -checkValue:withError: 
 * must be called first. Returns YES iff the value could be updated, NO otherwise (e.g. if no setter is available). Errors
 * are returned to the validation delegate (if any) and to the caller
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
 * Return the transformer to use, nil if none
 */
@property (nonatomic, readonly, strong) NSString *transformerName;

/**
 * Return the resolved bound object
 */
@property (nonatomic, readonly, weak) id objectTarget;

/**
 * Return the object which the transformer will be called on, nil if none or not resolved yet
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
 * Return YES iff the binding has been verified completely. If verified, check the error property to check whether
 * the binding was successfully resolved or not. If not verified, check the error property to retrieve information
 * about why the binding could not be verified
 */
@property (nonatomic, readonly, assign, getter=isVerified) BOOL verified;

/**
 * Reason why a binding cannot be completely verified yet (if verified = NO), why binding failed (if verified = NO),
 * or nil if no information is available
 */
@property (nonatomic, readonly, strong) NSError *error;

/**
 * Return YES iff the binding can be automatically kept in sync with the underlying model when the latter changes. This 
 * is always the case except when the keypath contains operators
 */
@property (nonatomic, readonly, assign, getter=isUpdatedAutomatically) BOOL updatedAutomatically;

@end

@interface HLSViewBindingInformation (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

@interface HLSViewBindingInformation (ConvenienceMethods)

- (BOOL)checkDisplayedValue:(id)displayedValue withError:(NSError **)pError;
- (BOOL)updateModelWithDisplayedValue:(id)displayedValue error:(NSError **)pError;
- (BOOL)checkAndUpdateModelWithDisplayedValue:(id)displayedValue error:(NSError **)pError;

@end
