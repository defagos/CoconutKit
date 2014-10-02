//
//  UIView+HLSViewBindingImplementation.h
//  CoconutKit
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
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
 * You can call -bindToObject:, -refreshBindings:, etc. on any view, whether it actually implement -updateViewWithValue:
 * or not. This will recursively traverse its view hierarchy wherever possible (see -bindsSubviewsRecursively) and
 * perform binding resolution for views deeper in its hierarchy, stopping at view controller boundaries
 */
- (void)updateViewWithValue:(id)value;

/**
 * UIView subclasses can implement this method to return YES if subviews must be updated recursively when the
 * receiver is updated. When not implemented, the default behavior is YES
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
 * underlying bound value. Two methods have been provided, one which does not update the underlying value but performs
 * checks, the other one checking and updating the value if valid. In general, you want to call the latter in your
 * own implementation, except if you intend to implement some kind of on-the-fly validation while a value is being
 * entered (e.g. validating user input in some kind of text field while the user is typing)
 */
@interface UIView (HLSViewBindingImplementation)

/**
 * View subclasses which want to provide update of bound values when the value they display change must call this
 * method in their implementation to update and check the underlying value (whether this actually happens depends
 * on the checkingDisplayedValueAutomatically and updatingModelAutomatically values)
 *
 * The methods returns YES iff the value could be updated and successfully checked. Errors are returned to the
 * binding delegate as well as to the caller. Update is made first. If it fails, then no check is made
 */
- (BOOL)updateAndCheckModelWithDisplayedValue:(id)displayedValue error:(NSError **)pError;

@end
