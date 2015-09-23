//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HLSViewAutoresizingAll UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |         \
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |                               \
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin

@interface UIView (HLSExtensions)

/**
 * Return the view controller from which the receiver is the view, nil otherwise
 */
@property (nonatomic, readonly, weak) UIViewController *viewController;

/**
 * Return the nearest view controller which displays the view, nil if none
 */
@property (nonatomic, readonly, weak) UIViewController *nearestViewController;

/**
 * Use this property if you want to tag your view with a string instead of an integer
 */
@property (nonatomic, strong) NSString *tag_hls;

/**
 * Use this dictionary to convey additional information about your views
 */
@property (nonatomic, strong) NSDictionary *userInfo_hls;

/**
 * Return the view and all its subview flattened as a UIImage
 */
- (UIImage *)flattenedImage;

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
- (UIView *)firstResponderView;

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

@end

#ifdef DEBUG

@interface UIView (HLSDebugging)

/**
 * Private method printing the receiver view hierarchy recursively. Only use for debugging purposes
 */
- (void)printRecursiveDescription;

@end

#endif

