//
//  HLSPlaceholderViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSContainerStack.h"
#import "HLSViewController.h"

// Forward declarations
@protocol HLSPlaceholderViewControllerDelegate;

/**
 * View controllers must sometimes embed other view controllers as "subviews". The HLSPlaceholderViewController class 
 * allows you to achieve such embeddings very easily. Simply subclass HLSPlaceholderViewController and define areas where
 * embedded view controllers ("insets") must be drawn, either by binding the placeholder view outlet collection
 * in your subclass nib, or by instantiating them in the -loadView method. If you bind your placeholder views in
 * the nib, be sure to tag them in increasing order, so that the placeholder view with the lowest tag comes first
 * (refer to the placeholderViews property documentation for more information).
 *
 * The inset view controllers can be swapped with other ones at any time. Several built-in transition animations are
 * available when swapping insets, and you can even use custom animations if you want.
 *
 * When a view controller's view is set as inset view controller, its view frame is automatically adjusted to match 
 * its placeholder view bounds, as is the case for usual UIKit containers (UITabBarController, UINavigationController). 
 * Be sure that the view controller's view size and autoresizing behaviors are correctly set.
 *
 * You can preload view controllers into a placeholder view controller before it is displayed. Simply use the
 * -setInsetViewController... methods to load view controllers at specific indices before the placeholder view
 * controller is displayed. You must only ensure that the number of placeholder views suffices to hold all the view 
 * controllers you have preloaded.
 *
 * You can resize or move (even animate!) the placeholder views, even when insets are displayed. This makes the
 * creation of innovative user interfaces as easy as it can be.
 *
 * When you subclass HLSPlaceholderViewController, it is especially important not to forget to call the super class
 * view lifecycle, orientation, animation and initialization methods first if you override any of them, otherwise the 
 * behavior is undefined:
 *   -initWithNibName:bundle:
 *   -initWithCoder: (for view controllers instantiated from a nib)
 *   -awakeFromNib
 *   -viewWill...
 *   -viewDid...
 *   -shouldAutorotate and supportedInterfaceOrientations
 *   -willRotateToInterfaceOrientation:duration:
 *   -willAnimate...
 *   -didRotateFromInterfaceOrientation:
 *
 * This view controller uses the smoother 1-step rotation available from iOS 3. You cannot use the 2-step rotation
 * in subclasses and inset view controllers (it will be ignored, see UIViewController documentation). The 2-step
 * rotation is deprecated starting with iOS 5, you should not use it anymore anyway.
 *
 * You can also use placeholder view controllers with storyboards:
 *   - drop a view controller onto the storyboard, and set its class to HLSPlaceholderViewController. Add one or several
 *     subviews which you connect to the placeholderViews outlet collection. This defines where inset view controllers
 *     will be drawn
 *   - drop another view controller onto the storyboard. You can display this view controller as inset as follows:
 *       - if you want to preload the view controller so that it gets displayed when the placeholder view controller
 *         gets displayed, bind the placeholder view controller with it using an HLSPlaceholderInsetSegue with the 
 *         reserved identifier 'hls_preload_at_index_N', where N is the index at which the view controller must be 
 *         displayed. N must be between 0 and 19 (this limit is arbitrary and should be sufficient in practice). The 
 *         transition style which gets applied is HLSTransitionStyleNone and cannot be customized
 *       - if you want to display the view controller after the placeholder view controller has been displayed, use
 *         an HLSPlaceholderInsetSegue (with any non-reserved identifier). If you need to customize the index at which
 *         the view controller must be displayed (by default 0) or the transition settings (style and duration), you 
 *         must implement the -prepareForSegue:sender: method in your source view controller
 *   - if you have several placeholder views, repeat this process as needed
 *   - when you want to install a new inset view controller, you can also bind an existing inset view controller
 *     to it (in other words, the source view controller does not need to be the placeholder view controller, but
 *     can be one of its children). The new inset view controller will be inserted into the placeholder view controller 
 *     the source inset view controller belongs to
 * For further information, refer to the documentation of HLSPlaceholderInsetSegue.
 *
 * About view controller's view reuse:
 * A view controller is retained when set as inset, and released when removed. If no other object keeps a strong reference 
 * to it, it will get deallocated, and so will its view. This is perfectly fine in general since it contributes to saving 
 * resources. But if you need to reuse a view controller's view instead of creating it from scratch again (most likely if 
 * you plan to display it later within the same placeholder view controller), you need to have another object retain the 
 * view controller to keep it alive.
 * For example, you might use a placeholder view controller to switch through a set of view controllers using tabs.
 * If those view controllers bear heavy views, you do not want to have them destroyed when you switch view controllers, 
 * since this would make navigating between tabs slow. In such cases, it makes sense to keep strong references to
 * those view controllers elsewhere (most probably as additional ivars of your placeholder view controller subclass)
 */
@interface HLSPlaceholderViewController : HLSViewController <HLSContainerStackDelegate>

/**
 * Set a view controller to display as inset on the placeholder view corresponding to the given index. The transition 
 * is made without animation. Setting an inset view controller to nil removes the one currently displayed at this index
 * (if any) using the animation it was displayed with
 *
 * This method can also be called to preload view controllers before the placeholder view controller is displayed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index;

/**
 * Display an inset view controller using some transition animation, on the placeholder view corresponding to the given 
 * index. The transition duration is set by the animation itself. Setting the inset view controller to nil removes the 
 * one currently displayed at this index (if any) using the animation it was displayed with, in which case the transition
 * animation class will be ignored
 *
 * This method can also be called to preload view controllers before the placeholder view controller is displayed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionClass:(Class)transitionClass;

/**
 * Display an inset view controller using some transition animation and duration, on the placeholder view corresponding 
 * to the given index (the animation will look the same, only slower or faster). Use the special value 
 * kAnimationTransitionDefaultDuration as duration to get the default transition duration. Setting the inset view
 * controller to nil removes the one currently displayed at this index (if any) using the animation it was displayed
 * with, in which case the transition animation class and duration will be ignored
 *
 * This method can also be called to preload view controllers before the placeholder view controller is displayed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionClass:(Class)transitionClass
                      duration:(NSTimeInterval)duration;

/**
 * The views where inset view controller's views must be drawn. Must either be created programmatically in a subclass' 
 * -loadView method or bound to a UIView using Interface Builder. You cannot change the number of placeholder views 
 * once the placeholder view controller has been displayed once.
 *
 * The order of the placeholder views in the IBOutletCollection is the one in which they are bound in the corresponding
 * nib or storyboard file
 */
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *placeholderViews;

/**
 * Return the placeholder view at the given index, or nil if none
 */
- (UIView *)placeholderViewAtIndex:(NSUInteger)index;

/**
 * Return the view controller displayed on the placeholder view at the given index, or nil if none
 */
- (UIViewController *)insetViewControllerAtIndex:(NSUInteger)index;

/**
 * Set how the placeholder view controller decides whether it must rotate or not
 *
 * HLSAutorotationModeContainer
 * HLSAutorotationModeContainerAndTopChildren
 * HLSAutorotationModeContainerAndAllChildren: All child view controllers decide whether rotation can occur, and receive
 *                                             the related events
 * HLSAutorotationModeContainerAndNoChildren: No children decide whether rotation occur, and none receive the
 *                                            related events
 *
 * The default value is given by HLSAutorotationModeContainer
 */
@property (nonatomic, assign) HLSAutorotationMode autorotationMode;

/**
 * The placeholder view controller delegate
 */
@property (nonatomic, weak) IBOutlet id<HLSPlaceholderViewControllerDelegate> delegate;

/**
 * If set to YES, the user interface interaction is blocked during the time the animation is running (see
 * the running property documentation for more information about what "running" actually means)
 *
 * Default is NO
 */
@property (nonatomic, assign) BOOL lockingUI;

@end

@protocol HLSPlaceholderViewControllerDelegate <NSObject>
@optional

/**
 * Called when a view controller is about to be displayed
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willShowInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated;

/**
 * Called when a view controller has been displayed
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didShowInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated;

/**
 * Called when a view controller is about to be hidden
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willHideInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated;

/**
 * Called when a view controller has been hidden
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didHideInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated;

@end

@interface UIViewController (HLSPlaceholderViewController)

/**
 * Return the placeholder view controller a view controller is inserted in, or nil if none
 */
@property (nonatomic, readonly, weak) HLSPlaceholderViewController *placeholderViewController;

@end
