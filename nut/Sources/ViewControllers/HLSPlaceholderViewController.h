//
//  HLSPlaceholderViewController.h
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSReloadable.h"

#import "HLSAnimation.h"
#import "HLSAnimationStep.h"
#import "HLSTwoViewAnimationStepDefinition.h"
#import "HLSViewController.h"

typedef enum {
    HLSTransitionStyleEnumBegin = 0,
    HLSTransitionStyleNone = HLSTransitionStyleEnumBegin,                                       // No transtion
    HLSTransitionStyleCoverFromBottom,                                                          // The new view covers the old one starting from the bottom
    HLSTransitionStyleCoverFromTop,                                                             // The new view covers the old one starting from the top
    HLSTransitionStyleCoverFromLeft,                                                            // The new view covers the old one starting from the left
    HLSTransitionStyleCoverFromRight,                                                           // The new view covers the old one starting from the right
    HLSTransitionStyleCoverFromTopLeft,                                                         // The new view covers the old one starting from the top left corner
    HLSTransitionStyleCoverFromTopRight,                                                        // The new view covers the old one starting from the top right corner
    HLSTransitionStyleCoverFromBottomLeft,                                                      // The new view covers the old one starting from the bottom left corner
    HLSTransitionStyleCoverFromBottomRight,                                                     // The new view covers the old one starting from the bottom right corner
    HLSTransitionStyleCrossDissolve,                                                            // The old view fades out as the new one fades in
    HLSTransitionStylePushFromBottom,                                                           // The new view pushes up the old one
    HLSTransitionStylePushFromTop,                                                              // The new view pushes down the old one
    HLSTransitionStylePushFromLeft,                                                             // The new view pushes the old one to the right
    HLSTransitionStylePushFromRight,                                                            // The new view pushes the old one to the left
    HLSTransitionStyleEmergeFromCenter,                                                         // The new view emerges from the center of the placeholder view
    HLSTransitionStyleEnumEnd,
    HLSTransitionStyleEnumSize = HLSTransitionStyleEnumEnd - HLSTransitionStyleEnumBegin
} HLSTransitionStyle;

// Forward declarations
@protocol HLSPlaceholderViewControllerDelegate;

/**
 * View controllers which must be able to embed another view controller as subview can inherit from this class
 * to benefit from correct event propagation (e.g. view lifecycle events, rotation events, etc.). Moreover, this class
 * also supports view controller different depending on the orientation (see HLSOrientationCloner protocol). To
 * define the area where embedded view controllers ("insets") will all be drawn, the subclass must supply a properly
 * initialized placeholder view, either using a xib or by implementing the loadView method.
 * 
 * The reason this class exists is that embedding view controllers by directly adding a view controller's view as 
 * subview of another view controller's view does not work correctly out of the box. Most view controller events will 
 * be fired up correctly (e.g viewDidLoad or rotation events), but other simply won't (e.g. viewWillAppear:). This 
 * means that when adding a view controller's view directly as subview, the viewWillAppear: message has to be sent
 * manually, which can be easily forgotten or done incorrectly (the same has of course to be done when removing the 
 * view).
 *
 * The inset view controller can be swapped with another one at any time. Several built-in transition styles are
 * available when swapping insets, or you can provide your own animation definition. If the transition is animated, 
 * all inset view controller viewWill / viewDid lifecycle methods will receive animated = YES, even if one of the views 
 * is not moved. This is not an error (what matters is whether the transition is animated or not, not if individual 
 * views are).
 *
 * When you derive from HLSPlaceholderViewController, it is especially important not to forget to call the super class
 * view lifecycle, orientation, animation and initialization methods first if you override any of them, otherwise the 
 * behaviour is undefined:
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
 * in subclasses (it will be ignored, see UIViewController documentation).
 *
 * As with standard built-in view controllers (e.g. UINavigationController), the inset view controller's view rect is known
 * when viewWillAppear: gets called for it, not earlier. If you need to insert code requiring to know the final view dimensions
 * or changing the screen layout (e.g. hiding a navigation bar), be sure to insert it in viewWillAppear: or events thereafter 
 * (in other words, NOT in viewDidLoad). You should not alter the inset view controller's view frame or transform yourself, 
 * otherwise the behavior is undefined.
 *
 * About view reuse: A view controller is retained when set as inset, and released when removed. If no other object keeps
 * a strong reference to it, it will get deallocated, and so will its view. This is perfectly fine in general since
 * it contributes to saving resources. But if you need to reuse a view controller's view instead of creating it from
 * scratch again (most likely if you plan to display it later within the same placeholder view controller), you need 
 * to have another object retain the view controller to keep it alive.
 * For example, you might use HLSPlaceholderViewController to switch through a set of view controllers using a button bar. 
 * If those view controllers bear heavy views, you do not want to have them destroyed when you switch view controllers, since
 * this would make navigating between tabs slow. You want to pay the price once, either by creating all views at the 
 * beginning, or more probably by using some lazy creation mechanism.
 * In such cases, be sure to retain all those view controllers elsewhere (most naturally by the same object which
 * instantiates the placeholder view controller). You must then ensure that this owner object is capable of releasing 
 * the views when memory is critically low. If the owner object is a view controller, it suffices to implement its 
 * viewDidUnload method and, within it, to set the view property of all cached view controllers to nil.
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSPlaceholderViewController : HLSViewController <HLSReloadable, HLSAnimationDelegate> {
@private
    UIViewController *m_insetViewController;                // The view controller displayed as inset
    BOOL m_insetViewAddedAsSubview;                         // Avoid testing the view controller view property (this triggers view loading,
                                                            // which we want to precisely control so that it happens when it has to). Test
                                                            // this boolean value instead, which means that the inset view controller's view
                                                            // has been added to the placeholder view as subview (which is actually when
                                                            // we precisely need view loading to occur)
    CGAffineTransform m_originalInsetViewTransform;         // Save initial inset view properties that the placeholder might alter to restore
    CGFloat m_originalInsetViewAlpha;                       // it when it is released
    UIViewController *m_oldInsetViewController;             // View controller which is being removed. Kept alive during the whole transition 
                                                            // animation (even if no fade out animation occurs)
    CGAffineTransform m_oldOriginalInsetViewTransform;      // Save the original properties during animation
    CGFloat m_oldOriginalInsetViewAlpha;                    // (same as above)
    UIView *m_placeholderView;                              // View onto which the inset view is drawn
    BOOL m_adjustingInset;                                  // Automatically adjust the inset view according to its autoresizing mask?
    id<HLSPlaceholderViewControllerDelegate> m_delegate;
}

/**
 * Set the view controller to display as inset. The transition is made without animation
 */
@property (nonatomic, retain) UIViewController *insetViewController;

/**
 * Display an inset view controller using one of the available built-in transition styles. The transition duration is set
 * by the animation itself
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Display an inset view controller using one of the available built-in transition styles (the duration can be
 * freely set; it will be distributed evenly on the animation steps composing the animation, preserving its original
 * aspect)
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration;

/**
 * Set the view controller to display as inset. The transition can be animated by providing an NSArray of HLSTwoViewAnimationStepDefinition 
 * objects (first view = old inset view, second view = new inset view)
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions;

/**
 * The view where inset view controller's view must be drawn. Must either created programmatically in a subclass' loadView method 
 * or bound to a UIView in Interface Builder
 */
@property (nonatomic, retain) IBOutlet UIView *placeholderView;

/**
 * If set to YES, the inset view controller's view frame is automatically adjusted to match the placeholder bounds. The resizing
 * behavior stiull depends on the autoresizing behavior of the inset view, though (for example, if an inset view is able to stretch 
 * in both directions, it will fill the entire placeholder view). If set to NO, the inset view is used as is.
 * Default value is NO
 */
@property (nonatomic, assign, getter=isAdjustingInset) BOOL adjustingInset;

@property (nonatomic, assign) id<HLSPlaceholderViewControllerDelegate> delegate;

@end

@protocol HLSPlaceholderViewControllerDelegate <NSObject>
@optional

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willShowInsetViewController:(UIViewController *)viewControlller
                         animated:(BOOL)animated;
- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didShowInsetViewController:(UIViewController *)viewControlller
                         animated:(BOOL)animated;

@end
