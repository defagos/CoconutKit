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
 * Should return YES iff the UIView subclass is able to display a placeholder. If not implemented, the default
 * behavior is NO. For such classes, it will be ensured that for bound methods with primitive return types
 * (int, float, etc.), the view displays nil instead of 0
 */
+ (BOOL)canDisplayPlaceholder;

/**
 * UIView subclasses which want to provide bindings MUST implement this method. Its implementation should update the
 * view according to the value which is received as parameter (if this value can be something else than an NSString,
 * be sure to implement the +supportedBindingClasses method accordingly). If a UIView class does not implement this
 * method, bindings will not be available for it
 */
- (void)updateViewWithValue:(id)value animated:(BOOL)animated;

/**
 * UIView subclasses which want to be able to update the underlying model MUST implement this method, returning
 * the currently displayed value. The type of the returned value must be one of the classes declared by
 * +supportedBindingClasses
 */
- (id)inputValue;

@end

/**
 * Methods meant to be called when implementing binding support for view subclasses which must be able to update the
 * underlying bound value. The -checkupdateModelWithInputValue:error: should also be called when the view
 * gets updated programmatically, so that the model gets updated in all cases
 */
@interface UIView (HLSViewBindingUpdateImplementation)

- (BOOL)check:(BOOL)check update:(BOOL)update withInputValue:(id)inputValue error:(NSError *__autoreleasing *)pError;

@end
