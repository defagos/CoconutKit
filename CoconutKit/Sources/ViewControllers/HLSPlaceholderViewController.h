//
//  HLSPlaceholderViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSReloadable.h"
#import "HLSTransitionStyle.h"
#import "HLSViewController.h"

// Forward declarations
@class HLSContainerContent;
@protocol HLSPlaceholderViewControllerDelegate;

/**
 * View controllers must sometimes embbed another view controller as "subview". In such cases, it is difficult and
 * cumbersome to achieve correct event propagation (e.g. view lifecycle events, rotation events) to the embedded
 * view controller. The placeholder view controller class allows you to achieve such embeddings, without having
 * to worry about event propagation anymore. Simply subclass HLSPlaceholderViewController and define an area
 * where embedded view controllers ("insets") must be drawn, either by binding the placeholder view outlet
 * in your subclass xib, or by instantiating it in the loadView method. Note that this class also supports view 
 * controllers different depending on the orientation (see HLSOrientationCloner protocol). 
 *
 * The reason this class exists is that embedding view controllers by directly adding a view controller's view as 
 * subview of another view controller's view does not work correctly out of the box. Most view controller events will 
 * be fired up correctly (e.g viewDidLoad or rotation events), but other simply won't (e.g. viewWillAppear:). This 
 * means that when adding a view controller's view directly as subview, the viewWillAppear: message has to be sent
 * manually, which can be easily forgotten or done incorrectly (the same has of course to be done when removing the 
 * view).
 *
 * The inset view controller can be swapped with another one at any time. Several built-in transition styles are
 * available when swapping insets. If the transition is animated, all inset view controller viewWill / viewDid lifecycle 
 * methods will receive animated = YES, even if one of the views is not moved. This is not an error (what matters is 
 * whether the transition is animated or not, not if individual views are).
 *
 * When a view controller's view is set as inset view controller, its view frame is automatically adjusted to match 
 * the placeholder view bounds, as for usual UIKit containers (UITabBarController, UINavigationController). Be sure that
 * the view controller's view size and autoresizing behaviors are correctly set.
 *
 * When you derive from HLSPlaceholderViewController, it is especially important not to forget to call the super class
 * view lifecycle, orientation, animation and initialization methods first if you override any of them, otherwise the 
 * behavior is undefined:
 *   - initWithNibName:bundle:
 *   - initWithCoder: (for view controllers instantiated from a xib)
 *   - viewWill...
 *   - viewDid...
 *   - shouldAutorotateToInterfaceOrientation: : If the call to the super method returns NO, return NO immediately (this
 *                                               means that the inset cannot rotate)
 *   - willRotateToInterfaceOrientation:duration:
 *   - willAnimate...
 *   - didRotateFromInterfaceOrientation:
 *   - viewAnimation...
 * This view controller uses the smoother 1-step rotation available from iOS3. You cannot use the 2-step rotation
 * in subclasses (it will be ignored, see UIViewController documentation) and inset view controllers. The 2-step
 * rotation is deprecated starting with iOS 5, you should not use it anymore anyway.
 *
 * As with standard built-in view controllers (e.g. UINavigationController), the inset view controller's view rect is known
 * when viewWillAppear: gets called for it, not earlier. If you need to insert code requiring to know the final view dimensions
 * or changing the screen layout (e.g. hiding a navigation bar), be sure to insert it in viewWillAppear: or events thereafter 
 * (in other words, NOT in viewDidLoad). You should not alter the inset view controller's view frame or transform yourself, 
 * otherwise the behavior is undefined.
 *
 * About view controller reuse:
 * A view controller is retained when set as inset, and released when removed. If no other object keeps a strong reference 
 * to it, it will get deallocated, and so will its view. This is perfectly fine in general since it contributes to saving 
 * resources. But if you need to reuse a view controller's view instead of creating it from scratch again (most likely if 
 * you plan to display it later within the same placeholder view controller), you need to have another object retain the 
 * view controller to keep it alive.
 * For example, you might use HLSPlaceholderViewController to switch through a set of view controllers using a button bar. 
 * If those view controllers bear heavy views, you do not want to have them destroyed when you switch view controllers, since
 * this would make navigating between tabs slow. You want to pay the price once, either by creating all views at the 
 * beginning, or more probably by using some lazy creation mechanism.
 * In such cases, be sure to retain all those view controllers elsewhere (most naturally by the same object which
 * instantiates the placeholder view controller). You must then ensure that this owner object is capable of releasing 
 * the views when memory is critically low. If the owner object is a view controller, it suffices to implement its 
 * viewDidUnload method and, within it, to set the view property of all cached view controllers to nil. Of course,
 * after having set a view to nil, you should forward its view controller the viewDidUnload message as well. If several
 * views are cached but only a subset (probably one) displayed at once, you also need to implement the didReceiveMemoryWarning
 * method to set invisible cached views to nil and send their view controller the viewDidUnload message.
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSPlaceholderViewController : HLSViewController <HLSReloadable> {
@private
    HLSContainerContent *m_containerContent;                // Wraps the view controller added as inset
    HLSContainerContent *m_oldContainerContent;             // Retains the old inset view controller wrapper when swapping with a new one
    UIView *m_placeholderView;                              // View onto which the inset view is drawn
    BOOL m_forwardingProperties;                            // Does the container forward inset navigation properties transparently?
    id<HLSPlaceholderViewControllerDelegate> m_delegate;
}

/**
 * Set the view controller to display as inset. The transition is made without animation.
 * Setting the inset view controller to nil removes the one currently display (if any)
 * This property can also be set before the placeholder view controller is displayed.
 */
- (void)setInsetViewController:(UIViewController *)insetViewController;

/**
 * Display an inset view controller using one of the available built-in transition styles. The transition duration is 
 * set by the animation itself
 * Setting the inset view controller to nil removes the one currently display (if any). Only the HLSTransitionStyleNone
 * transition is available in such cases.
 * This method can also be called before the placeholder view controller is displayed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Display an inset view controller using one of the available built-in transition styles (the duration will be 
 * evenly distributed on the animation steps composing the animation so that the animation rhythm stays the same)
 * Use the special value kAnimationTransitionDefaultDuration as duration to get the default transition duration 
 * (same result as the method above)
 * Setting the inset view controller to nil removes the one currently display (if any). Only the following styles are
 * available in this case: HLSTransitionStyleNone and HLSTransitionStyleCrossDissolve
 * This method can also be called before the placeholder view controller is displayed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration;

/**
 * The view where inset view controller's views must be drawn. Must either created programmatically in a subclass' loadView 
 * method or bound to a UIView using Interface Builder
 */
@property (nonatomic, retain) IBOutlet UIView *placeholderView;

/**
 * Return the view controller set as inset, nil if none
 */
- (UIViewController *)insetViewController;

/**
 * If set to YES, properties of the inset view controller (title, navigation item, toolbar) are forwarded to the placeholder 
 * view controller. When inserted into a navigation controller, the placeholder view controller thus behaves as if its
 * inset view controller had been directly pushed into it.
 *
 * Default value is NO.
 */
@property (nonatomic, assign, getter=isForwardingProperties) BOOL forwardingProperties;

@property (nonatomic, assign) IBOutlet id<HLSPlaceholderViewControllerDelegate> delegate;

@end

@protocol HLSPlaceholderViewControllerDelegate <NSObject>
@optional

/**
 * Called when an inset view controller will be shown, before the transition happens
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willShowInsetViewController:(UIViewController *)viewController
                         animated:(BOOL)animated;
/**
 * Called when an inset view controller will be shown, before the transition has ended
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didShowInsetViewController:(UIViewController *)viewController
                         animated:(BOOL)animated;

@end

@interface UIViewController (HLSPlaceholderViewController)

/**
 * Return the placeholder view controller the view controller is inserted in, or nil if none.
 */
@property (nonatomic, readonly, assign) HLSPlaceholderViewController *placeholderViewController;

@end
