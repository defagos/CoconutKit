//
//  UIView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Usually, when you have to display or set some value on screen, and if you are using Interface Builder to design
 * your user interface, you have to create and bind an outlet. Though this process is completely straightforward,
 * this tends to clutter you code and becomes increasingly boring, especially when the number of values to 
 * manage is large.
 *
 * CoconutKit view bindings allow you to bind values to views directly in Interface Builder, via user-defined
 * runtime attributes instead of outlets. Two attributes are available to this purpose:
 *   - bindKeyPath: The keypath pointing at the value to which the view will be bound. This can be any kind of 
 *                  keypath, even one containing keypath operators
 *   - bindTransformer: Values to be displayed by bound views must have an appropriate type, most of the time
 *                      NSString. The classes supported for binding to a view are returned by the bound view
 *                      +supportedBindingClasses class method (if not implemented, defaults to NSString). If
 *                      bindKeyPath returns a non-supported kind of object, you must provide the name of a
 *                      transformer method 'methodName', which can either be an instance method with prototype
 *                        - (id<HLSTransformer>)methodName        or
 *                        - (NSFormatter *)methodName             or
 *                        - (NSValueTransformer *)methodName
 *                      or a class method with prototype
 *                        + (id<HLSTransformer>)classMethodName   or
 *                        + (NSFormatter *)classMethodName        or
 *                        + (NSValueTransformer *)classMethodName
 *                      returning an HLSTransformer, NSFormatter or NSValueTransformer transforming the object 
 *                      into another one with supported type. These methods are looked up along the responder 
 *                      chain, as described below. Alternatively, you can provide a global class method 
 *                      '[SomeClass methodName]', returning either an HLSTransformer, NSFormatter or
 *                      NSValueTransformer object.
 *
 * Transformers are required when the type of the value returned by the key path does not match one of the supported
 * types, but can also be used to apply arbitrary changes to values displayed by bound views. For example, if a view 
 * supports binding to NSNumber, and if the key path returns an NSNumber, you might still want to use a transformer 
 * to round the value, multiply it with some constant, etc. If an HLSTransformer is only used when displaying values,
 * not when reading values from a bound view, or if its use only makes sense when displaying values, you can only 
 * implement the forward transformation method (see HLSTransformer protocol for more information)
 *
 * With no additional measures, keypath lookup is performed along the responder chain, starting with the view
 * bindKeyPath has been set on, and stopping at the first encountered view controller (if any is found). View
 * controllers namely define a local context, and it does not make sense to proceed further along the responder
 * chain. The same is true for transformer selector lookup (at each step along the responder chain, instance
 * method existence is tested first, then class method existence).
 *
 * Often, though, values to be bound stem from a model object, not from the responder chain. In such cases,
 * you must call -bindToObject: on the view to be bound, passing it the object to be bound against. The keypath 
 * you set must be be valid for this object. Transformer lookup is first made on the object class itself (instance,
 * then class method), then along the responder chain (instance, then class method, again stopping at view controller 
 * boundaries), except if a global class transformer is used.
 *
 * To summarize, transformer lookup for a method named 'methodName' is performed from the most specific to
 * the most generic context, within the boundaries of a view controller (if any), as follows:
 *   - instance method -methodName on bound object (if -bindToObject: has been used)
 *   - class method +methodName on bound object (if -bindToObject: has been used)
 *   - for each responder along the responder chain starting with the bound view:
 *       - instance method -methodName on the responder object
 *       - class method +methodName on the responder object
 * In addition, global transformer names can be provided in the form of class methods '+[SomeClass methodName]'
 *
 * The binding information is resolved as late as possible (usually when the view is displayed), i.e. when the whole
 * responder chain context is available. This information is then stored for efficient later use. The view is not
 * updated automatically when the underlying bound objects changes, this has to be done manually:
 *   - when the object is changed, call -bindToObject: to set bindings with the new object
 *   - if the object does not change but has different values for its bounds properties, simply call -refreshBindingsForced:
 *     to reflect the new values which are available
 *
 * It would be painful to call -bindToObject:, -refreshBindingsForced:, etc. on all views belonging to a view hierarchy
 * when bindings must be established or refreshed. For this reason, those calls are made recursively. This means you can 
 * simply call one of those methods at the top of the view hierarchy (or even on the view controller itself, see 
 * UIViewController+HLSViewBinding.h) to bind or refresh the whole associated view hierarchy. Note that each view class 
 * decides whether it recursively binds or refreshes its subviews (this behavior is controlled via the HLSViewBinding 
 * protocol)
 *
 * In most cases, you want to bind a single view hierarchy to a single object. But you can also have separate 
 * view hierarchies within the same view controller context if you want, each one bound to a different object.
 * Nesting is possible as well, but can be more subtle and depends on the order in which -bindToObject: is 
 * called. Though you should in general avoid such designs, you can still bind nested views correctly by 
 * calling -bindToObject: on parent views first.
 *
 * Bindings can also be used to update a model with the value displayed by a bound view, provided the keypath supports
 * it (keypaths containing operators obviously do not provide such capabilities). Values can be transferred to the model 
 * either manually by calling -updateModelWithError: on a top view, or automatically by setting the updatingModelAutomatically 
 * property to YES (the default value is NO). As for display, a required attached transformer might be needed if the value 
 * to be displayed is not natively supported by the view (+supportedBindingClasses method). Bound fields can also be 
 * validated by calling -checkDisplayedValues:withError: on a top view. Update and check status (including any
 * errors which might be encountered) are reported to a binding delegate. The binding delegate of a bound view is resolved 
 * by looking along the responder chain starting with the view for a class conforming to the HLSBindingDelegate protocol.
 *
 * TODO: Document validation via -validate and soon-to-be-implemented -check methods
 * TODO: Document: Validation is always available, even if a view cannot update the underlying model object
 *
 * Here is how UIKit view classes play with bindings:
 *   - UILabel: The label displays the value which the keypath points at. Bindings are not recursive. The only 
 *              supported class is NSString
 *   - UIProgressView: The progress view displays the value which the keypath points at, and dragging the slider
 *                     changes the underlying value. Bindings are not recursive. The only supported class is NSNumber 
 *                     (treated as a float)
 *   - UITableView: No direct binding is available, and bindings are not recursive. You can still bind table view
 *                  cells and headers created from nibs, though
 *   - UISegmentedControl: <explain>
 *   - UIStepper: <explain>
 *   - UISwitch: The switch displays the value which the keypath points at, and toggling the switch changes the
 *               underlying value. Bindings are not recursive. The only supported class is NSNumber (treated as a 
 *               boolean)
 *   - UITextField: <explain>
 *   - UITextView: <explain>
 *   - UIWebView: <explain>
 *
 * CoconutKit classes support bindings as well:
 *   - HLSCursor: <explain>
 *   - HLSLabel: Automatic, as subclass of UILabel
 *
 * You can customize the binding behavior for other UIView subclasses (whether these classes are your own or stem
 * from a 3rd party library) by implementing the HLSViewBinding protocol. For views which must be able to update
 * the underlying object when the value they display change, call methods from the HLSViewBindingUpdateImplementation
 * category in your implementation. For 3rd party classes, binding implementation is best achieved using a category 
 * conforming to HLSViewBinding (see CoconutKit UILabel+HLSViewBinding for an example).
 */

/**
 * View binding additions. All methods can be called whether a view implements binding support or not. When calling
 * one of those methods on a view, the view hierarchy rooted at it is traversed, until views which do not support
 * recursion are found (see HLSViewBinding protocol), or until a view controller boundary is reached
 */
@interface UIView (HLSViewBinding)

@property (nonatomic, strong) IBInspectable NSString *bindKeyPath;
@property (nonatomic, strong) IBInspectable NSString *bindTransformer;

/**
 * Bind the view (and recursively the view hierarchy rooted at it) to a given object (can be nil). During view 
 * hierarchy traversal, keypaths and transformers set via user-defined runtime attributes will be used to automatically
 * fill those views which implement binding support
 */
- (void)bindToObject:(id)object;

/**
 * Refresh the value displayed by the view, recursively traversing the view hierarchy rooted at it. If forced is set
 * to NO, bindings are not checked again (i.e. keypaths and transformers are not resolved again), values are only updated 
 * using information which has been cached the first time bindings were successfully checked. If you want to force bindings
 * to be checked again first (i.e. keypaths and transformers to be resolved again), set forced to YES
 */
- (void)refreshBindingsForced:(BOOL)forced;

/**
 * Recursively check bound values, stopping at view controller boundaries. Errors are reported to the validation
 * delegates individually, and chained as a single error returned to the caller as well. All bound values are 
 * checked, and all corresponding errors are returned
 *
 * The method returns YES iff all checks have been successful
 */
- (BOOL)checkDisplayedValuesWithError:(NSError **)pError;

/**
 * Trigger a recursive update of the model for those views which can change their underlying value. The view hierarchy
 * is traversed up to view controller boundaries. No rollback mechanism is provided; if you need one, you need to implement 
 * it yourself or use objects supporting rollback natively, e.g. Core Data objects.
 *
 * The method returns YES iff all bound values were correctly updated, otherwise NO and errors to the caller
 *
 * If all views to be updated have updatingModelAutomatically set to YES, calling this method is redundant and therefore
 * not needed.
 */
- (BOOL)updateModelWithError:(NSError **)pError;

@end
