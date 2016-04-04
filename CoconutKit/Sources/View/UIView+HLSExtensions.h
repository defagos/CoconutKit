//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define HLSViewAutoresizingAll UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |         \
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |                               \
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin

@interface UIView (HLSExtensions)

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
- (void)enableOutsideActionWithBlock:(void (^)())outsideActionBlock;
- (void)disableOutsideAction;

/**
 * The distance to keep (at least) between keyboard and content. For scroll views, this value is @(10.f) by default,
 * otherwise nil. For all views within a scroll view, the value defined by the scroll view is used. This value can
 * be overridden on a view basis if needed
 */
@property (nonatomic, null_resettable) IBInspectable NSNumber *keyboardDistance;

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
