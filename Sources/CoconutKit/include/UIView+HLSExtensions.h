//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

#define HLSViewAutoresizingAll UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |         \
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |                               \
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin

typedef void (^HLSFocusRectCompletionBlock)(CGRect focusRect);

/**
 * View classes can implement the following methods to customize how they behave in the presence of the keyboard
 */
@protocol HLSKeyboardAvodingBehavior <NSObject>

@optional

/**
 * Locate the rect onto which focus should be kept when the keyboard is displayed. Implementations must call the supplied 
 * completion block after they could locate where the focus must reside (immediately if this information is readily
 * available), otherwise the behavior is undefined.
 * 
 * If this method is not implemented, focus will be assumed to be on the whole view
 */
- (void)locateFocusRectWithCompletionBlock:(HLSFocusRectCompletionBlock)completionBlock;

@end

@interface UIView (HLSExtensions) <HLSKeyboardAvodingBehavior>

/**
 * Return the view controller from which the receiver is the view, nil otherwise
 */
@property (nonatomic, readonly, weak, nullable) __kindof UIViewController *viewController;

/**
 * Return the nearest view controller which displays the view, nil if none
 */
@property (nonatomic, readonly, weak, nullable) __kindof UIViewController *nearestViewController;

/**
 * Use this property if you want to tag your view with a string instead of an integer
 */
@property (nonatomic, copy, nullable) NSString *tag_hls;

/**
 * Use this dictionary to convey additional information about your views
 */
@property (nonatomic, nullable) NSDictionary *userInfo_hls;

/**
 * Return the view and all its subview flattened as a UIImage
 */
@property (nonatomic, readonly) UIImage *flattenedImage;

/**
 * Convenience method to apply a mask to a view, fading in the specified directions from a given fraction of the
 * width / height.
 *
 * This method replaces any mask layer which might have been applied. Only one effect can be applied
 */
- (void)fadeLeft:(CGFloat)left right:(CGFloat)right;
- (void)fadeTop:(CGFloat)top bottom:(CGFloat)bottom;

/**
 * Return the first responder view contained within the receiver, nil if none
 */
@property (nonatomic, readonly, nullable) UIView *firstResponderView;

/**
 * Set the view to call the given action block (mandatory) when any interaction outside its bounds happens. The action
 * is called only once per interaction (even with continuous interactions like panning or zooming).
 *
 * Action blocks can be useful when you want to implement modal-like behavior for a view (e.g. if you want that any
 * interaction outside a view to dismiss it).
 * 
 * The action block is automatically discarded when the view is removed from the view hierarchy. If you need to remove 
 * the action before the view is removed from the view hierarchy, call -disableOutsideAction.
 */
- (void)enableOutsideActionWithBlock:(void (^)(void))outsideActionBlock;
- (void)disableOutsideAction;

/**
 * The distance to keep (at least) between keyboard and content when the keyboard is displayed, for a scroll view
 * with hls_avoidingKeyboard set to YES (see UIScrollView+HLSExtensions.h). The value can be set on the scroll view
 * itself and / or on views located within it. If a view has a keyboard distance of CGFLOAT_MAX set (the default), 
 * then the keyboard distance defined on the enclosing scroll view will be used (the default value for a scroll
 * view is 10.f).
 *
 * Note that the value of 10.f corresponds to 10 pixels for a standard iPad in landscape orientation. For larger or 
 * smaller screen heights, the value is changed proportionally, so that the distance is larger for larger heights 
 * and smaller for smaller ones
 */
@property (nonatomic) IBInspectable CGFloat keyboardDistance;

@end

#ifdef DEBUG

@interface UIView (HLSDebugging)

/**
 * Private method printing the receiver view hierarchy recursively. Only use for debugging purposes
 */
- (void)printRecursiveDescription;

@end

#endif

NS_ASSUME_NONNULL_END
