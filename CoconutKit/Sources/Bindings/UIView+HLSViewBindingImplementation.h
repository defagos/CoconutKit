//
//  UIView+HLSViewBindingImplementation.h
//  CoconutKit
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

/**
 * CoconutKit bindings for custom view classes
 * -------------------------------------------
 *
 * To implement bindings for your own view class:
 *   - Have your view class conform to the HLSViewBindingImplementation protocol
 *   - In your implementation, be sure to use the HLSViewBindingUpdateImplementation category when implementing
 *     update operations
 */

@protocol HLSViewBindingImplementation <NSObject>

@required

/**
 * UIView subclasses which want to provide bindings MUST implement this method. Its implementation should update the
 * view according to the value which is received as parameter (if this value can be something else than an NSString,
 * be sure to implement the +supportedBindingClasses method accordingly). If a UIView class does not implement this
 * method, bindings will not be available for it
 */
- (void)updateViewWithValue:(id)value animated:(BOOL)animated;

@optional

/**
 * Return the list of classes supported for bindings. If this method is not implemented, the supported types default
 * to NSString only
 */
+ (NSArray *)supportedBindingClasses;

/**
 * Should return YES iff the UIView subclass is able to display a placeholder. If not implemented, the default
 * behavior is NO. For classes which can display a placeholder, it will be ensured that for bound methods with 
 * primitive return types (int, float, etc.), the view displays nil instead of 0, so that the placeholder can
 * be seen
 */
+ (BOOL)canDisplayPlaceholder;

/**
 * UIView subclasses which want to be able to update the underlying model MUST implement this method, returning
 * the currently displayed value, as an instance of the class provided as parameter. The provided class is always
 * one of the classes returned by +supportedBindingClasses. If your view binds only to one type, you can ignore
 * this parameter and return an object with the according class
 */
- (id)inputValueWithClass:(Class)inputClass;

@end

/**
 * Methods meant to be called when implementing binding support for view subclasses which must be able to update the
 * underlying bound value. The -checkupdateModelWithInputValue:error: should also be called when the view
 * gets updated programmatically, so that the model gets updated in all cases
 */

@interface UIView (HLSViewBindingUpdateImplementation)

/**
 * When implementing a class supporting bindings, call this method when the value displayed by the view is changed,
 * whether interactively or programmatically. You can only check, only update, or both (calling the method with
 * NO for both values raises an assertion). This makes it possible to implement bindings where check / updates are
 * made at very specific times. You could for example imagine some text field where no check is performed during
 * input, only when leaving edit mode
 *
 * The method returns YES on success, NO and error information on failure
 *
 * Remark: Setting check = YES does not necessary leads to a check if the view has its bindInputChecked property
 *         set to NO. Setting check to NO, however, disables checks in all cases
 */
- (BOOL)check:(BOOL)check update:(BOOL)update withInputValue:(id)inputValue error:(NSError *__autoreleasing *)pError;

@end
