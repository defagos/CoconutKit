//
//  UIView+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSTransformer.h"

/**
 * Cocoa-inspired bindings on iOS
 * ------------------------------
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
 * possible. The remaining of the binding properties is resolved and checked at runtime. During binding resolution,
 * each bound view is assigned a status. This status can be examined using an in-app debugging interface, making 
 * programmer error detection easy.
 *
 * The next sections describe all aspects of bindings in more detail.
 *
 *
 *
 * 1. Bindings in practice
 * ------------------------
 *
 * Usually, when you have to display some information or grab some input from the user, you first start by creating
 * a dedicated view controller, which usually provides a self-contained, reusable functional unit. 
 *
 * If you are using Interface Builder, you probably proceed as follows:
 *   - You attach a model object to the view controller. The model object will provide values to be displayed,
 *     and receive values provided interactively
 *   - In the xib or storyboard file, you drop a few labels and text fields on the view controller view
 *   - Switching to the view controller implementation, you add the corresponding outlets, which you carefully bind
 *     to the labels and text fields in the xib, one by one
 *   - To update labels and provide text fields with their initial value, you write some kind of reload method,
 *     which assigns to each label and text field the appropriate value. Depending on the value, e.g. dates,
 *     some formatting might be needed, usually achieved by applying an NSFormatter
 *   - You ensure that if the object changes reloading of the labels and text fields is properly made. Usually 
 *     calling the reload method when appropriate suffices, but you can also use KVO to be notified about changes 
 *     automatically. Of course, if you use KVO, you implement the corresponding observation methods, with an
 *     appropriate context, and you do not forget to unregister the view controller when it gets deallocated
 *   - You grab changes from text fields and update the underlying model object accordingly. This usually means
 *     setting the view controller as delegate of each text field, or listening to change notifications
 *   - Some text fields might allow entering a formatted date. In such cases, you need to parse the input first 
 *     (using an NSFormatter) before updating the model
 *   - You add some validation methods (e.g. to check for negative ages), and you call them where appropriate
 *     to ensure data correctness
 *   - You spend some time fixing issues (incorrectly bound outlets, missing displayed values, incorrectly updated
 *     model) until your screen works as expected
 *
 * Using CoconutKit bindings, this tedious process is made a lot easier:
 *   - You attach a model object to the view controller. The model object will provide values to be displayed,
 *     and receive values provided interactively
 *   - In the xib or storyboard file, you drop a few labels and text fields on the view controller view. For each
 *     one, you specify a key path to bind to, e.g. 'employee.firstName', 'employee.age' or 'employee.birthdate', 
 *     assuming your model object is made available as a view controller 'employee' property
 *   - For each value which requires formatting for display or which needs to be parsed, you implement a date formatter,
 *     either on the view controller, the model class, or somewhere at global scope. In the xib, you provide for
 *     each view which requires formatting the name of this date formatter
 *   - You write KVC-compliant validation methods on your model object, and make the view controller inherit from
 *     a binding delegation protocol to catch validation events. With a single call, you trigger a validation for
 *     all text fields when needed
 *   - You build and run your application. All fields are kept synchronized, even if the model object changes
 *   - If you find some issues, you fire up an in-app debugging interface, locate the issues, and fix them in a snap
 *
 *
 *
 * 2. Binding definition
 * ---------------------
 * 
 * To define a binding, only two pieces of information are needed:
 *   - bindKeyPath: The keypath to bind the view to, which is required
 *   - bindTransformer: If the value returned by the key path is not natively supported by the view, or if the value 
 *     must somehow be pre-processed first (e.g. rounded), a transformer can optionally be provided
 *
 * These two string properties can be set either using Interface Builder (by far the recommended, most efficient way) or
 * programmatically (for those who do not use Interface Builder):
 *   - Using Interface Builder: Select the view to bind, open its Attributes inspector, and set the 'Bind Key Path' and 
 *     'Bind Transformer' custom attributes. If you are using Interface Builder, you can literally bind a whole screen
 *     without the need to add a single outlet!
 *   - Programmatically : After having instantiated the view to bind, call -bindToKeyPath:withTransformer: on it
 *
 * To understand how to set these two properties, it is crucial to understand how binding information is resolved at 
 * runtime.
 *
 *
 *
 * 3. Keypath resolution
 * ---------------------
 *
 * The bindKeyPath property is a string describing which key path has to be called. The target onto which the call is
 * actually made is unspecified by bindKeyPath and resolved at runtime.
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
 * its results are cached until the view is destroyed.
 *
 *
 *
 * 4. Keypath syntax
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
 * value displayed by all bound views located in it.
 *
 * If the last key path component (in the examples above, name and age respectively) corresponds to a property,
 * type information can be extracted and the correctness of bindings can be asserted. If the last path key component
 * corresponds to a getter (and maybe an associated setter), no such information can be retrieved. In this case, 
 * be careful about possible type mismatches or missing transformers. The debugging information (see 9.) displays
 * these fields in yellow. If you can, replace them with properties so that correct types can be enforced.
 *
 * Currently, bindings can be made with values having the following types:
 *   - All primitive types (NSInteger, float, CGFloat, etc.)
 *   - Objects
 *   - Structs
 *
 *
 *
 * 5. Transformers
 * ---------------
 *
 * The bindTransformer property is a string describing which transformer must be used to pre-process values between 
 * the model and the bound view.
 *
 * Views namely define the set of types they want to natively support. For example, UILabel supports only NSString,
 * whereas UISlider can only work with NSNumber (and primitive types). UIImageView, on the other hand, supports 
 * UIImage, but also NSString (image names or file paths) and NSURL (file paths).
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
 * 5.1. Local transformer
 * ----------------------
 *
 * A local transformer is specified by its method name, e.g. 'decimalNumberFormatter'. As for key path resolution, no
 * target onto which the method must be called is specified. Unlike key path resolution, though, local formatter 
 * resolution explores a slightly broader context, always from the most specific to the most generic:
 *   - First the responder chain starting with the bound view parent, and stopping at view controller boundaries. For 
 *     each responder along the chain, a match is searched among instance methods first, then among class methods
 *   - If no match is found, the key path is examined to perform lookup where the end value comes from. This depends 
 *     on the keypath syntax:
 *       * Simple keypath 'name': The object found by key path resolving supplies the value. The transformer method
 *         is searched among its instance methods, then among its class methods
 *       * Composed keypath 'object1.object2.name': Since object2 ultimately supplies the value, a transformer method
 *         is searched among its instance methods, then among its class methods
 *       * Keypath ending with an operator 'objects.@operator.name': Lookup extracts the first object from the objects
 *         list, and searches the transformer method in its class methods only. It namely does not make sense to search
 *         for instance methods since objects in the collection are different. Note that lookup assumes that all objects
 *         are instances of the same class
 *
 * Rules for local transformer resolution are more complicated than the ones for key path resolution. In general,
 * though, you should simply remember them as follows:
 *   - Responder chain lookup, instance methods first, then class methods
 *   - Object supplying the end value, instance methods first (if applicable), then class methods
 *
 * For example:
 *   - If the key path is 'age' and a local number transformer 'decimalNumberFormatter' is provided, lookup is made 
 *     along the responder chain first, then on the object to which the key path has been bound (instance, then class 
 *     methods)
 *   - If the key path is 'employee.birthdate' and a local date transformer 'shortDateFormatter' is provided, lookup 
 *     is made along the responder chain first (instance, then class methods), then on employee (instance, then class
 *     methods)
 *   - If the key path is 'company.employees.@avg.age' and a local number transformer 'decimalNumberFormatter 'is 
 *     provided, lookup is made along the responder chain first (instance, then class methods), then on the first 
 *     collection object, an employee (class methods only)
 *
 *
 * 5.2. Global transformer
 * -----------------------
 *
 * A global transformer is a class name followed by a method name, separated by a colon, for example e.g. 
 * 'GlobalTransformer:shortDateTransformer'. No resolution mechanism is needed, the method is simply checked for existence.
 *
 *
 *
 * 6. Input and validation
 * -----------------------
 *
 * Some classes, e.g. UITextField or UISlider, naturally accepts user input. If bound to a key paths for which a setter
 * is available, CoconutKit bindings ensure that interacting with such views automatically updates the underlying model.
 *
 * Unlike display, though, input is error-prone. A value might need to be transformed but transformation could fail due to
 * incorrect input. Even if correctly transformed, the resulting value might be incorrect according to some model validation
 * rules. Even updating the model objet can fail. All these events can be caught by a binding delegate.
 *
 *
 * 6.1. Binding delegate
 * ---------------------
 *
 * A binding delegate must conform to the HLSViewBindingDelegate protocol, by which it shows interest in receiving binding
 * events.
 *
 * As for the key path, binding delegate resolution is performed along the responder chain, starting from the bound view
 * parent, and stopping at view controller boundaries. Along the way, the first object conforming to HLSViewBindingDelegate
 * will be the binding delegate of the bound view.
 *
 *
 * 6.2. Validation
 * ---------------
 *
 * Validation follows KVC conventions, and can be manually triggered by calling -[UIView checkBoundViewHierarchyWithError:]
 * on a view. As its name suggests, this method validates all bound views located in the view hierarchy of the receiver. If
 * the key path associated with a bound view points at an object / field pair for which a method
 *
 *    - (BOOL)validate<fieldName>:(<class> *)pValue error:(NSError *__autoreleasing *)pError
 *
 * is available, it will be automatically invoked. Validation events are received by a binding delegate (if any), which
 * makes it possible to update the user interface appropriately, e.g. by displaying a message to the user.
 *
 * By default, validation must be triggered manually. By setting the bindInputChecked to YES on a bound view, though, input 
 * can be validated automatically when the view changes.
 *
 *
 *
 * 7. Natively supported views
 * ---------------------------
 * 
 * Bindings are available for most UIKit classes:
 *
 *     UIActivityIndicatorView              UIPageControl                           UIStepper
 *     UIDatePicker                         UIProgressView                          UISwitch
 *     UIImageView                          UISegmentedControl                      UITextField
 *     UILabel                              UISlider                                UITextView
 *
 * Refer to the corresponding <ClassName>+HLSViewBinding.h header file for more information about how these views
 * support bindings.
 *
 * Moreover, CoconutKit HLSCursor supports bindings as well.
 *
 *
 *
 * 8. Bindings for custom views
 * ----------------------------
 *
 * CoconutKit bindings can be enabled for your own classes with very little effort.
 *
 * See UIView+HLSViewBindingImplementation.h for more information
 *
 *
 *
 * 9. Debugging bindings
 * ---------------------
 *
 * To identify bindings issues, a debugging overlay has been provided. This overlay can be displayed by calling the
 * +[UIView showBindingsDebugOverlay] method. Either provide a button somewhere in your debug builds or pause the
 * debugger and issue the following command:
 *
 *     (lldb) expr (void)[UIView showBindingsDebugOverlay]
 *
 * then resume the execution.
 *
 *
 *
 * 10. Performance considerations
 * ------------------------------
 *
 * Binding resolution is kept minimal, but of course incurs an overhead I tried to keep small. For very deep view 
 * hierarchies and a large number of fields to bind, the performance cost cannot be neglected, but in most practical 
 * cases using bindings should not be a performance issue.
 *
 * Bindings can also be defined within collection or table view cells: When properly reused, only the few reused cells
 * are initially bound. Cached information is then reused for fast updates during scrolling.
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
 * The default value is NO. In this case, call -checkBoundViewHierarchyWithError: to manually trigger a check when
 * needed
 */
@property (nonatomic, assign, getter=isBindInputChecked) IBInspectable BOOL bindInputChecked;

/**
 * Return YES iff binding is possible against the receiver. This method is provided for information purposes, trying
 * to bind a view which does not support bindings is safe (i.e. won't crash) but does nothing
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
 * Check the value displayed by the receiver and the whole view hierarchy rooted at it, stopping at view controller
 * boundaries. Errors are individually reported to the validation delegate, and chained as a single error returned 
 * to the caller as well. The method returns YES iff all operations have been successful
 */
- (BOOL)checkBoundViewHierarchyWithError:(NSError *__autoreleasing *)pError;

@end

@interface UIView (HLSViewBindingProgrammatic)

/**
 * Programmatically bind a view to a given keypath with a given transformer. This method can also be used to change 
 * an existing binding (if the view is displayed, it will automatically be updated)
 */
- (void)bindToKeyPath:(NSString *)keyPath withTransformer:(NSString *)transformer;

@end
