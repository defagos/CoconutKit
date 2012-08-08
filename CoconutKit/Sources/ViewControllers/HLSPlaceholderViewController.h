//
//  HLSPlaceholderViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSContainerStack.h"
#import "HLSViewController.h"

// Forward declarations
@protocol HLSPlaceholderViewControllerDelegate;

/**
 * View controllers must sometimes embed other view controllers as "subviews". In such cases, it is difficult and
 * cumbersome to achieve correct event propagation (e.g. view lifecycle events, rotation events) to the embedded
 * view controllers. The HLSPlaceholderViewController class allows you to achieve such embeddings, without having
 * to worry about event propagation anymore. Simply subclass HLSPlaceholderViewController and define areas where
 * embedded view controllers ("insets") must be drawn, either by binding the placeholder view outlet collection
 * in your subclass nib, or by instantiating them in the loadView method. If you bind your placeholder views in
 * the nib, be sure to tag them in increasing order, so that the placeholder view with the lowest tag comes first
 * (refer to the placeholderViews property documentation for more information). Note that this class also supports 
 * view controllers different depending on the orientation (see HLSOrientationCloner protocol). 
 *
 * The reason this class exists is that embedding view controllers by directly adding a view controller's view as 
 * subview of another view controller's view does not work correctly out of the box. Most view controller events will 
 * be fired up correctly (e.g viewDidLoad or rotation events), but other simply won't (e.g. viewWillAppear:). This 
 * means that when adding a view controller's view directly as subview, the viewWillAppear: message has to be sent
 * manually, which can be easily forgotten or done incorrectly (the same has of course to be done when removing the 
 * view).
 *
 * The inset view controllers can be swapped with other ones at any time. Several built-in transition styles are
 * available when swapping insets. If the transition is animated, all inset view controller viewWill / viewDid lifecycle 
 * methods will receive animated = YES, even if one of the views is not moved. This is not an error (what matters is 
 * whether the transition is animated or not, not if individual views are).
 *
 * When a view controller's view is set as inset view controller, its view frame is automatically adjusted to match 
 * its placeholder view bounds, as for usual UIKit containers (UITabBarController, UINavigationController). Be sure
 * that the view controller's view size and autoresizing behaviors are correctly set.
 *
 * You can preload view controllers into an placeholder view controller before it is displayed. Simply use the
 * setInsetViewController... methods to load view controllers at specific indices. You must only ensure that the 
 * number of placeholder views suffices to hold all the view controllers you have preloaded.
 *
 * When you derive from HLSPlaceholderViewController, it is especially important not to forget to call the super class
 * view lifecycle, orientation, animation and initialization methods first if you override any of them, otherwise the 
 * behavior is undefined:
 *   - initWithNibName:bundle:
 *   - initWithCoder: (for view controllers instantiated from a nib)
 *   - awakeFromNib
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
 * As with standard built-in view controllers (e.g. UINavigationController), the inset view controller's view rects are known
 * when viewWillAppear: gets called for them, not earlier. If you need to insert code requiring to know the final view dimensions
 * or changing the screen layout (e.g. hiding a navigation bar), be sure to insert it in viewWillAppear: or events thereafter 
 * (in other words, NOT in viewDidLoad). You should not alter an inset view controller's view frame or transform yourself, 
 * otherwise the behavior is undefined.
 *
 * You can also use placeholder view controllers with storyboards (a feature available since iOS 5);
 *   - drop a view controller onto the storyboard, and set its class to HLSPlaceholderViewController. Add one or several
 *     subviews which you connect to the placeholderViews outlet collection. This defines where inset view controllers will
 *     be drawn
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
@interface HLSPlaceholderViewController : HLSViewController <HLSContainerStackDelegate> {
@private
    NSMutableArray *m_containerStacks;
    NSArray *m_placeholderViews;                            // Views onto which the inset views are drawn
    id<HLSPlaceholderViewControllerDelegate> m_delegate;
    BOOL m_loadedOnce;
}

/**
 * Set a view controller to display as inset on the placeholder view corresponding to the given index. The transition 
 * is made without animation. Setting an inset view controller to nil removes the one currently display at this
 * (if any)
 * This property can also be set before the placeholder view controller is displayed.
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index;

/**
 * Display an inset view controller using one of the available built-in transition styles, on the placeholder view
 * corresponding to the given index. The transition duration is set by the animation itself. Setting the inset view 
 * controller to nil removes the one currently display (if any). Only the HLSTransitionStyleNone transition is available 
 * in such cases.
 * This method can also be called before the placeholder view controller is displayed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionClass:(Class)transitionClass;

/**
 * Display an inset view controller using one of the available built-in transition styles, on the placeholder view
 * corresponding to the given index (the duration will be evenly distributed on the animation steps composing the 
 * animation so that the animation rhythm stays the same). Use the special value kAnimationTransitionDefaultDuration 
 * as duration to get the default transition duration (same result as the method above). Setting the inset view 
 * controller to nil removes the one currently display (if any). Only the HLSTransitionStyleNone transition is available
 * in such cases.
 * This method can also be called before the placeholder view controller is displayed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionClass:(Class)transitionClass
                      duration:(NSTimeInterval)duration;

/**
 * The views where inset view controller's views must be drawn. Must either created programmatically in a subclass' loadView 
 * method or bound to a UIView using Interface Builder. You cannot change the number of placeholder views once the
 * placeholder view controller has been displayed once.
 *
 * The order of the outlets in an IBOutletCollection is unreliable (it is sadly not the order in which they are bound
 * in the nib). To fix this, the placeholderViews property expect you to index placeholder views using the UIView tag
 * property, and will sort them in increasing order
 */
@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *placeholderViews;

/**
 * Return the placeholder view at the given index, or nil if none
 */
- (UIView *)placeholderViewAtIndex:(NSUInteger)index;

/**
 * Return the view controller displayed on the placeholder view at the given index, or nil if none
 */
- (UIViewController *)insetViewControllerAtIndex:(NSUInteger)index;

/**
 * If set to YES, properties of the first inset view controller (title, navigation item, toolbar) are forwarded to the 
 * placeholder view controller. When inserted into a navigation controller, the placeholder view controller thus behaves 
 * as if its first inset view controller had been directly pushed into it.
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
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated;
/**
 * Called when an inset view controller has been shown, after the transition has ended
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didShowInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated;

/**
 * Called when an inset view controller will be hidden, before the transition happens
 */
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willHideInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated;
/**
 * Called when an inset view controller has been hidden, after the transition has ended
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
@property (nonatomic, readonly, assign) HLSPlaceholderViewController *placeholderViewController;

@end
