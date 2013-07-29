//
//  UIView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Usually, when you have to display some value on screen, and if you are using Interface Builder to design 
 * your interface, you have to create and bind an outlet. Though this process is completely straightforward, 
 * this tends to clutter you code and becomes increasingly boring, especially when the number of values to 
 * display is large.
 *
 * CoconutKit view bindings allow you to bind values to views directly in Interface Builder, via user-defined
 * runtime attributes instead of outlets. Two attributes are available to this purpose:
 *   - bindKeyPath: The keypath to which the view will be bound. This can be any kind of keypath, even one
 *                  containing keypath operators
 *   - bindFormatter: Values to be displayed must be strings. If bindKeyPath returns another kind of object,
 *                    you must provide the name of an instance formatter method 'methodName:' which can 
 *                    either be an instance method with prototype
 *                      - (NSString *)methodName:(SomeClass *)object
 *                    or a class method with prototype
 *                      + (NSString *)classMethodName:(SomeClass *)object
 *                    transforming the value into a string. Alternatively, you can provide a global class 
 *                    formatter method '+[SomeClass methodName:]'
 *
 * With no additional measure, keypath lookup is performed along the responder chain, starting with the view
 * bindKeyPath has been set on, and stopping at the first encountered view controller (if any is found). View
 * controllers namely define a local context, and it does not make sense to proceed further along the responder
 * chain. The same is true for formatter selector lookup (at each step along the responder chain, instance
 * method existence is tested first, then class method existence).
 *
 * Often, though, values to be bound stem from a model object, not from the responder chain. In such cases,
 * you must call -bindToObject:, passing it the object to be bind against. The keypath you set must be be 
 * valid for this object. Formatter lookup is first made on the object class itself (instance, then class
 * method), then along the responder chain (instance, then class method, again stopping at view controller 
 * boundaries), except if a global class formatter is used
 *
 * To summarize, formatter lookup for a method named 'methodName:' is performed from the most specific to 
 * the most generic context, within the boundaries of a view controller (if any), as follows:
 *   - instance method -methodName: on bound object (if -bindToObject: has been used)
 *   - class method +methodName: on bound object (if -bindToObject: has been used)
 *   - for each responder along the responder chain starting with the bound view:
 *       - instance method -methodName: on the responder object
 *       - class method +methodName: on the responder object
 * In addition, global formatter names can also point to class methods '+[SomeClass methodName:]'
 *
 * The binding information is resolved once when views are unarchived, and stored for efficient later use. 
 * Values are not updated automatically when the underlying bound objects changes, this has to be done
 * manually:
 *   - if the object is not the same, call -bindToObject: to set bindings with the new object
 *   - if the object is the same but has different values for its bounds properties, simply call -refreshBindings 
 *     to reflect the new values which are available
 *
 * It would be painful to call -bindToObject:, -refreshBindings:, etc. on all views belonging to a view hierarchy
 * when bindings must be established or refreshed. For this reason, those calls have been made recursive. This 
 * means you can simply call one of those methods at the top of the view hierarchy (or even on the view controller 
 * itself, see UIViewController+HLSViewBinding) to bind or refresh all associated view hierarchy. Note that each 
 * view class decides whether it recursively binds or refreshes its subviews (see HLSViewBinding protocol)
 *
 * In most cases, you want to bind a single view hierarchy to a single object. But you can also have separate 
 * view hierarchies within the same view controller context if you want, each one bound to a different object.
 * Nesting is possible as well, but can be more subtle and depends on the order in which -bindToObject: is 
 * called. Though you should in general avoid such designs, you can still bind nested views correctly by 
 * calling -bindToObject: on parent views first.
 *
 * TODO: Document validation and sync in the other direction (when available)
 *
 * Here is how UIKit view classes play with bindings:
 *   - UILabel: The label displays the value which the keypath points at. Recursive bindings have been disabled
 *   - UITextField: <explain>
 *   - UITextView: <explain>
 *   - UITableView: No direct binding is available, and recursive bindings haven been disabeld. You can still
 *                  bind table view cells and headers created from nibs
 *
 * You can customize the binding behavior for other UIView subclasses (even your own) by implementing the
 * HLSViewBinding protocol
 */

/**
 * This protocol can be implemented by UIView subclasses to customize binding behavior 
 */
@protocol HLSViewBinding <NSObject>

@optional

/**
 * UIView subclasses which want to provide bindings MUST implement this method. Its implementation should update the 
 * view according to the text which is received as parameter. For UIView classes which do not implement this method, 
 * bindings will not be available.
 *
 * You can call -bindToObject:,  -refreshBindings:, etc. on any view, whether it actually implement -updateViewWithText:
 * or not. This will recursively traverse its view hierarchy wherever possible (see -bindsSubviewsRecursively)
 */
- (void)updateViewWithText:(NSString *)text;

/**
 * UIView subclasses can implement this method to return YES if subviews must be updated recursively when the
 * receiver is updated. When not implemented, the default behavior is YES
 */
- (BOOL)bindsSubviewsRecursively;

// TODO: Implement and document
#if 0
// TODO: This can be implemented to sync from view to model. Do it for UITextField (implement validation too? Make
//       Core Data bindings a special case)
- (BOOL)updateObjectWithText:(NSString *)text;

// TODO: Optional validation (see Key-Value coding programming guide, -validate<field>:error:)
#endif

@end

/**
 * View binding additions. All methods can be called whether a view implements binding support or not. When calling
 * one of those methods on a view, the view hierarchy rooted at it is traversed, until views which do not support
 * recursion are found (see HLSViewBinding protocol), or until a view controller boundary is reached
 */
@interface UIView (HLSViewBinding)

/**
 * Bind the view (and recursively the view hierarchy rooted at it) to a given object (can be nil). During view 
 * hierarchy traversal, keypaths and formatters set via user-defined runtime attributes will be used to automatically 
 * fill those views which implement binding support
 */
- (void)bindToObject:(id)object;

/**
 * Refresh the value displayed by the view, recursively traversing the view hierarchy rooted at it. If forced is set
 * to YES, bindings are not checked again (i.e. formatters are not resolved again), values are only updated using
 * information which has been cached the first time bindings were successfully checked. If you want to force bindings
 * to be checked again first (i.e. formatters to be resolved again), set forced to YES
 */
- (void)refreshBindingsForced:(BOOL)forced;

@end
