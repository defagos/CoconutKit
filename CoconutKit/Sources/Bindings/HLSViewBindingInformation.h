//
//  HLSViewBindingInformation.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingDelegate.h"

/**
 * Private class encapsulating view binding information, and performing lazy binding parameter validation and caching
 */
@interface HLSViewBindingInformation : NSObject

/**
 * Store view binding information. A keypath and a view are mandatory, otherwise the method returns nil. The object
 * parameter can be one of the following:
 *   - a non-nil object, which the keypath is applied to (binding to an object)
 *   - nil, in which case the keypath is applied to the responder chain starting with view
 */
- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath transformerName:(NSString *)transformerName view:(UIView *)view NS_DESIGNATED_INITIALIZER;

/**
 * Return the current value corresponding to the stored binding information (the transformer method is applied, if any). 
 * If keypath information is invalid, this method returns nil
 */
- (id)value;

- (id)rawValue;

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
- (BOOL)checkValue:(id)displayedValue withError:(NSError **)pError;

/**
 * Update the value which the key path points at with another value. Does not perform any check, -checkValue:withError: 
 * must be called first. Returns YES iff the value could be updated, NO otherwise (e.g. if no setter is available). Errors
 * are returned to the validation delegate (if any) and to the caller
 */
- (BOOL)updateWithValue:(id)value error:(NSError **)pError;

- (void)notifySuccess:(BOOL)success withValue:(id)value error:(NSError *)error;

/**
 * Return the object which has been bound, nil if none or not resolved yet
 */
@property (nonatomic, readonly, weak) id object;

/**
 * Return the keypath to which binding is made
 */
@property (nonatomic, readonly, strong) NSString *keyPath;

@property (nonatomic, readonly, weak) UIView *view;

/**
 * Return the transformer to use, nil if none
 */
@property (nonatomic, readonly, strong) NSString *transformerName;

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
@property (nonatomic, readonly, weak) id<HLSBindingDelegate> delegate;

/**
 * Return a message describing current issues with the binding, nil if none
 */
@property (nonatomic, readonly, strong) NSString *errorDescription;

/**
 * Return YES iff the binding has been verified once
 */
@property (nonatomic, readonly, assign, getter=isVerified) BOOL verified;

@end
