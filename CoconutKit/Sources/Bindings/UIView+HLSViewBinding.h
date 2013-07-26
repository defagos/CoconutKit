//
//  UIView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Usually, when you have to display some value on screen, and if you are using Interface Builder to design your
 * interface, you have to create and bind an outlet. Though this process is completely straightforward, this 
 * tends to clutter you code and becomes increasingly boring, especially when the number of values to display
 * is large.
 *
 * CoconutKit view bindings allow you to bind values to views directly in Interface Builder, via user-defined
 * runtime attributes instead of outlets. Two attributes are available:
 *   - bindKeyPath: The keypath to which the view will be bound. This can be any kind of keypath, even one
 *                  containing keypath operators
 *   - bindFormatter: Values to be displayed must be strings. If bindKeyPath returns another kind of object,
 *                    you must provide the name of a formatter method with prototype
 *                       - (NSString *)methodName:(<Class>)object
 *                    turning it into a string. In this case, bindFormatter must be set to 'methodName:' (how
 *                    method lookup is performed is explained below). Alternatively, you can provide a
 *                    global class formatter method '+[<Class> methodName:]'
 *
 * With no additional measure, keypath lookup is performed along the responder chain, starting with the view
 * bindKeyPath has been set on, and stopping at the first encountered view controller (if any is found). View
 * controllers namely define a local context, and it does not make sense to proceed further along the responder
 * chain. The same is true for formatter selector lookup.
 *
 * Often, though, values to be bound stem from a model object, not from the responder chain. In this case,
 * call -bindToObject:, passing it the object bindings must be made against. In this case, the keypath must
 * be valid for this object. Formatter lookup is first made on the object class itself, then along the responder
 * chain (again stopping at view controller boundaries). Global formatters can of course still be used as well.
 *
 * The binding information is resolved once when views are unarchived, and stored for efficient later use. Values
 * are not updated automatically. You can call -bindToObject: to set a new object, or if you want to update
 * the bound views with the most recent values available, simply call -refreshBindings. Each view decides
 * whether bindings, and therefore refreshes, are recursively made or not (see HLSViewBinding protocol).
 *
 * In most common cases, you want to bind a single view hierarchy to a single object. You can of course have
 * separate view hierarchies within the same view controller context, each one bound to a different object.
 * Nesting can be more subtle and depends on the order in which -bindToObject: is called. Though you should
 * in general avoid such designs, you can still bind objects by calling -bindToObject: from the topmost parent
 * view to the bottommost child view. Since bindings are often made for the root view of a view controller,
 * convenience binding methods have been provided on UIViewController as well (see UIViewController+HLSViewBinding)
 *
 * TODO: Document validation and sync in the other direction (when available)
 *
 * Bindings have been implemented for the following UIView subclasses:
 *   - UILabel
 * You can implement bindings for other classes by having them implement the HLSViewBinding protocol.
 */
@protocol HLSViewBinding <NSObject>

@optional

/**
 * UIView subclasses can implement this method to perform the logic necessary to update the view using the new 
 * value corresponding to an identified biding. If this method is not implemented, bindings will not be available
 */
- (void)updateViewWithText:(NSString *)text;

/**
 * UIView subclasses can implement this method to return YES if subviews must be updated recursively when the
 * receiver is updated. If not implemented, the default behavior is YES
 */
- (BOOL)updatesSubviewsRecursively;

// TODO: This can be implemented to sync from view to model. Do it for UITextField (implement validation too? Make
//       Core Data bindings a special case)
- (BOOL)updateBoundObjectWithText:(NSString *)text;

// TODO: Optional validation (see Key-Value coding programming guide, -validate<field>:error:)

@end

@interface UIView (HLSViewBinding) <HLSViewBinding>

/**
 * Bind an object to the specified bind path. This bind path must be a KVC-compliant keypath. Object updates
 * are not automatically reflected, call -refreshBindings when appropriate. Subviews are bound recursively 
 * (if enabled, see HLSViewBinding protocol), stopping at view controller boundaries
 */
- (void)bindToObject:(id)object;

/**
 * Refresh bound values, recursively if enabled (see HLSViewBinding protocol). Stops at view controller
 * boundaries
 */
- (void)refreshBindings;

@end
