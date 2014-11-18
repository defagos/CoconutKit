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
