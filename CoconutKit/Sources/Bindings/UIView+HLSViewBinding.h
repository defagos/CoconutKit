//
//  UIView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSTransformer.h"


/**
 * View bindings error codes. Errors are in the CoconutKitErrorDomain domain
 */
typedef NS_ENUM(NSInteger, HLSViewBindingError) {
    HLSViewBindingErrorInvalidKeyPath,                  // The key path is incorrect
    HLSViewBindingErrorObjectTargetNotFound,            // No meaningful target could be found for the key path
    HLSViewBindingErrorInvalidTransformer,              // The transformer is invalid or could not be resolved
    HLSViewBindingErrorNilValue,                        // The value retrieved from the key path is nil
    HLSViewBindingErrorUnsupportedType,                 // The view cannot display the value
    HLSViewBindingErrorUnsupportedOperation             // The operation (e.g. update) is not supported
};

/**
 * This category adds Cocoa-inspired bindings to iOS
 *
 * CoconutKit bindings provide a convenient and efficient way to bind (thus the name) a view displayed on screen to 
 * an underlying model object, connected to it by a given key path. With no or very few lines of code, bindings 
 * ensure that:
 *   - When the model changes, the bound view gets automatically updated
 *   - When the bound view changes, the model gets automatically updated. If a validation is associated with the
 *     key path, it can optionally be triggered automatically
 *
 * A view can be bound to a given list of types it natively supports. For example, a UILabel natively supports
 * strings. If the key path returns a string, everything is fine, otherwise you can always ensure that some 
 * proper type is provided to a bound view by applying some conversion first. This is the role of transformers.
 *
 * Transformers provide one-way or two-way conversion between objects. A transformer can e.g. turn a number into
 * a string. Another transformer can perform date formatting and parsing. A third one can simply accept a number
 * as input and round it. When appropriate, such transformers can be assigned to a bound view for automatic 
 * conversion of values, for display and / or input reading.
 *
 * One of the primary goals of CoconutKit bindings is to be able to define a binding with as few information as
 * possible. The remaining of the bindings properties is resolved and checked at runtime. This is why only key
 * path and transformers are in fact required to define a properly working binding.
 *
 * During binding resolution, each bound view is assigned a status. This status can be examined using an in-app 
 * debugging interface, making programmer error detection easy.
 *
 *
 *
 * 1. Binding definition
 * ---------------------
 * 
 * To define a binding, only two pieces of information are required:
 *   - The keypath to bind the view to (bindKeyPath)
 *   - If the value returned by the key path is not natively supported by the view, or if the value must be somehow
 *     pre-processed first (e.g. rounded), a transformer can optionally be provided (bindTransformer)
 *
 * These two string properties can be set either using Interface Builder (by far the recommended, most efficient way) or
 * in code (for those who do not use Interface Builder):
 *   - Using Interface Builder: Select the view to bind, open its Attributes inspector, and set the 'Bind Key Path' and 
 *     'Bind Transformer' custom attributes
 *   - In code: After having instantiated the view to bind, call -bindToKeyPath:withTransformer: on it
 *
 * To understand how to set these two properties, it is crucial to understand how binding information is resolved at 
 * runtime.
 *
 *
 *
 * 2. Keypath resolution
 * ---------------------
 *
 * The bindKeyPath property is a string describing which key path has to be called. The target onto which the call is
 * actually be made is unspecified by bindKeyPath and resolved at runtime.
 *
 * To efficiently restrict where to look for a target, binding resolution needs context. A view naturally belongs to
 * some technical context, whether it is the one of its view hierarchy, or the one of an enclosing view controller. 
 * The most natural way to explore this technical context is to climb up the responder chain, starting from the bound 
 * view parent. This lookup must stop at view controller boundaries, though. View controllers are namely units of
 * functional context. Exploring the whole view controller hierarchy for targets would not only be inefficient, it
 * would also most certainly lead to functionally irrelevant matches.
 *
 * For example, suppose you have some label, for which you set bindKeyPath to 'name'. At runtime, when bindings
 * resolution takes place, a target responding to this key path will be searched along the responder chain starting 
 * with the bound label parent view. As soon a target responding to the key path has been found, the key path is 
 * invoked on it and the result displayed by the label. If no target is found in the bound view context (e.g. if
 * lookup crosses view controller boundaries), lookup fails and the binding is considered invalid.
 *
 * To ensure the lookup process can access the complete responder chain, bindings are resolved just after the view 
 * hierarchy has been built. The resolution process itself is made once for obvious performance reasons, and
 * its results are cached.
 *
 *
 *
 * 3. Keypath syntax
 * -----------------
 *
 * CoconutKit bindings are compatible with all kinds of keypaths, including those containing operators. For example:
 *   - 'name'
 *   - 'employee.name'
 *   - 'employees.@avg.age'
 *
 * Once a keypath target has been resolved, any changes made to the underlying objects are detected using KVO, and
 * automatically reflected by the bound view.
 *
 * Note that keypaths containing operators are not KVO-compliant. If one or several of the underlying objects change,
 * associated bound views must be updated manually by calling -updateBoundViewHierarchy:. As its name suggests, this
 * method recursively traverses the view hierarchy, again stopping at view controller boundaries, to update the
 * all bound views located in it.
 *
 *
 *
 * 4. Transformers
 * ---------------
 *
 * The bindTransformer property is a string describing which transformer must be used to pre-process values between 
 * the model and the bound view.
 *
 * Views namely define the set of types they want to natively support. For example, UILabel supports only NSString,
 * whereas UISlider can only work with NSNumber. UIImageView, on the other hand, supports UIImage, but also NSString
 * (image names or file paths) and NSURL (file paths).
 *
 * If the key path connecting the bound view to its underlying model returns a value with non-supported type, you 
 * must provide a transformer. A transformer is a method with no parameters returning an instance of either:
 *   - NSFormatter, including the usual NSDateFormatter and NSNumberFormatter
 *   - NSValueTransformer, the official Cocoa way of transforming values
 *   - A class conforming to the HLSTransformer protocol, a generic transformation protocol. The HLSBlockTransformer 
 *     class is an implementation of this protocol and provides a way to conveniently define conversions using blocks
 *
 * As for the binding key path, the transformer method is resolved at runtime. There are two types of transformers:
 * local and global ones.
 *
 *
 * 4.1. Local transformer
 * ----------------------
 *
 * A local transformer is specified by its method name, e.g. 'decimalNumberFormatter'. As for key path resolution, no
 * target onto which the method must be called is specified. Unlike key path resolution, though, local formatter 
 * resolution explores a slightly broader context, always from the most specific to the most generic:
 *   - The responder chain starting with the bound view parent, and stopping at view controller boundaries. At each 
 *     step instance methods are searched first, then class methods
 *   - If no match is found, the key path is examined to find where the end value comes from, which depends on the
 *     keypath syntax:
         * Simple keypath 'name': The object found by key path resolving supplies the value. The transformer method
 *         is searched among its instance methods, then among its class methods
 *       * Composed keypath 'object1.object2.name': Since object2 ultimately supplies the value, a transformer method
 *         is searched among its instance methods, then among its class methods
 *       * Keypath ending with an operator 'objects.@operator.name': Lookup extracts the first object from the objects
 *         list, and search the transformer method in its class methods only. It namely does not make sense to search
 *         for instance methods since objects in the collection are different. Moreover, lookup assumes that all 
 *         objects are instances of the same class
 *
 * Rules for local transformer resolution are more complicated than the ones for key path resolution. In general,
 * though, you should simply remember them as follows:
 *   - Responder chain lookup, instance methods first, then class methods
 *   - Object supplying the end value, instance methods first (if applicable), then class methods
 *
 * For example, if the keypath is 'employee.birthdate', lookup looks along the responder chain first (class, then instance
 * methods), then on employee (class, then instance methods).
 *
 *
 * 4.2. Global transformer
 * -----------------------
 *
 * A global transformer is a class method of the form 'ClassName:methodName', e.g. 'GlobalTransformer:shortDateTransformer'
 *
 *
 *
 * 5. Bound views supporting input
 * -------------------------------
 *
 * Some classes, e.g. UITextField or UISlider, naturally accepts user input. If bound to a key paths for which a setter
 * is available, CoconutKit bindings encure that interacting with such views automatically updates the underlying model.
 *
 * Unlike display, though, input is error-prone. A value might need to be transformed but transformation can fail due to
 * incorrect input. Even if correctly transformed, the resulting value might be incorrect according to some model validation
 * rules. Even updating the model objet can fail. All these events can be caught by a binding delegate.
 *
 *
 * 5.1. Binding delegate
 * ---------------------
 *
 * As for the key path, binding delegate resolution is performed along the responder chain, starting from the bound view
 * parent, and stopping at view controller boundaries. The first instance of a class conforming to the HLSViewBindingDelegate
 * protocol is automatically set to be the delegate of the bound view, and will receive success and failure events, depending
 * on which protocol methods are implemented.
 *
 *
 * 5.2. Validation and update
 * --------------------------
 *
 *
 *
 *
 *
 *
 * 7. Natively supported views
 * ---------------------------
 *
 *
 * 8. Bindings for custom views
 * ----------------------------
 *
 *
 *
 * 9. Debugging bindings
 * ---------------------
 *
 *
 */
@interface UIView (HLSViewBinding)

/**
 * Display an overlay on top of the application key window, displaying bound views and their current status. This
 * is your primary tool to debug binding issues. Tap on a field to get information about it (status, description
 * of issues, resolved objects, etc.)
 */
+ (void)showBindingsDebugOverlay;

/**
 * The keypath to bind to (most conveniently set via Interface Builder, but can also be set programmatically by calling
 * -bindToKeyPath:withTransformer:)
 */
@property (nonatomic, readonly, strong) IBInspectable NSString *bindKeyPath;

/**
 * The name of the transformer to apply (most conveniently set via Interface Builder, can also be set programmatically 
 * by calling -bindToKeyPath:withTransformer:)
 */
@property (nonatomic, readonly, strong) IBInspectable NSString *bindTransformer;

/**
 * Set to YES iff updates made to the model object are applied to the bound view with an animation, provided the latter
 * supports animation during updates (this is e.g. the case for UIDatePicker, but not for UIStepper)
 *
 * The default value is NO
 */
@property (nonatomic, assign, getter=isBindUpdateAnimated) IBInspectable BOOL bindUpdateAnimated;

/**
 * Set to YES to perform validation when the bound view content is changed
 *
 * The default value is NO. In this case, call -check:update:withCurrentinputValue:error: to manually trigger the check when
 * needed (the call can be made on a top view or view controller containing the receiver)
 */
@property (nonatomic, assign, getter=isBindInputChecked) IBInspectable BOOL bindInputChecked;

/**
 * Return YES iff binding is possible against the receiver. This method is provided for information purposes, trying
 * to bind a view which does not support bindings is safe but does not work
 */
@property (nonatomic, readonly, assign, getter=isBindingSupported) BOOL bindingSupported;

/**
 * Update the value displayed by the receiver and the whole view hierarchy rooted at it, stopping at view controller
 * boundaries. Successfully resolved binding information is not resolved again. If animated is set to YES, the
 * change is made animated (provided the views support animated updates), otherwise no animation takes place
 */
- (void)updateBoundViewHierarchyAnimated:(BOOL)animated;

/**
 * Same as -updateBoundViewHierarchyAnimated:, but each view is animated according to the its bindUpdateAnimated
 * setting
 */
- (void)updateBoundViewHierarchy;

/**
 * Check and / or update the value attached to the receiver and the whole view hierarchy rooted at it, stopping
 * at view controller boundaries. Errors are individually reported to the validation delegate, and chained as
 * a single error returned to the caller as well. The method returns YES iff all operations have been successful
 */
- (BOOL)check:(BOOL)check update:(BOOL)update boundViewHierarchyWithError:(NSError *__autoreleasing *)pError;

@end

@interface UIView (HLSViewBindingProgrammatic)

/**
 * Programmatically bind a view to a given keypath with a given transformer. This method can also be used
 * to change an existing binding (if the view is displayed, it will automatically be updated)
 */
- (void)bindToKeyPath:(NSString *)keyPath withTransformer:(NSString *)transformer;

@end
