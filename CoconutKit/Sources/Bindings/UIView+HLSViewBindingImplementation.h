//
//  UIView+HLSViewBindingImplementation.h
//  CoconutKit
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

/**
 * UIView subclasses must use the protocol and category below to implement binding behavior
 */

/**
 * This protocol can be implemented by UIView subclasses to customize binding behavior
 */
@protocol HLSViewBindingImplementation <NSObject>

@optional

/**
 * Return the list of classes supported for bindings. If this method is not implemented, the supported types default
 * to NSString only
 */
+ (NSArray *)supportedBindingClasses;

/**
 * UIView subclasses which want to provide bindings MUST implement this method. Its implementation should update the
 * view according to the value which is received as parameter (if this value can be something else than an NSString,
 * be sure to implement the +supportedBindingClasses method as well). If a UIView class does not implement this method,
 * bindings will not be available for it.
 *
 * You can call -bindToObject:, -refreshBindings:, etc. on any view, whether it actually implement -updateViewWithValue:animated:
 * or not. This will recursively traverse its view hierarchy wherever possible (see -bindsSubviewsRecursively) and
 * perform binding resolution for views deeper in its hierarchy, stopping at view controller boundaries
 */
- (void)updateViewWithValue:(id)value animated:(BOOL)animated;

/**
 * UIView subclasses can implement this method to return YES if subviews must be bound recursively when the receiver is 
 * bound. When not implemented, the default behavior is YES
 */
- (BOOL)bindsSubviewsRecursively;

/**
 * UIView subclasses which want to be able to update the underlying model MUST implement this method, returning
 * the currently displayed value. The type of the returned value must be one of the classes declared by
 * +supportedBindingClasses
 */
- (id)displayedValue;

@end

/**
 * Methods meant to be called when implementing binding support for view subclasses which must be able to update the
 * underlying bound value. The -checkAndUpdateModelWithDisplayedValue:error: should also be called when the view
 * gets updated programmatically, so that the model gets updated in all cases
 */
@interface UIView (HLSViewBindingUpdateImplementation)

- (BOOL)checkDisplayedValue:(id)displayedValue withError:(NSError **)pError;
- (BOOL)updateModelWithDisplayedValue:(id)displayedValue error:(NSError **)pError;
- (BOOL)checkAndUpdateModelWithDisplayedValue:(id)displayedValue error:(NSError **)pError;

@end
