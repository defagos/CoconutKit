//
//  HLSPlaceholderViewController.h
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSReloadable.h"

#import "HLSAnimationStep.h"
#import "HLSViewAnimation.h"

typedef enum {
    HLSTransitionStyleEnumBegin = 0,
    HLSTransitionStyleNone = HLSTransitionStyleEnumBegin,                                       // No transtion
    HLSTransitionStyleCoverFromBottom,                                                          // The new view covers the old one starting from the bottom
    HLSTransitionStyleCoverFromTop,                                                             // The new view covers the old one starting from the top
    HLSTransitionStyleCoverFromLeft,                                                            // The new view covers the old one starting from the left
    HLSTransitionStyleCoverFromRight,                                                           // The new view covers the old one starting from the right
    HLSTransitionStyleCrossDissolve,                                                            // The old view fades out as the new one fades in
    HLSTransitionStylePushFromBottom,                                                           // The new view pushes up the old one
    HLSTransitionStylePushFromTop,                                                              // The new view pushes down the old one
    HLSTransitionStylePushFromLeft,                                                             // The new view pushes the old one to the right
    HLSTransitionStylePushFromRight,                                                            // The new view pushes the old one to the left
    HLSTransitionStyleEnumEnd,
    HLSTransitionStyleEnumSize = HLSTransitionStyleEnumEnd - HLSTransitionStyleEnumBegin
} HLSTransitionStyle;

typedef enum {
    LifeCyclePhaseEnumBegin = 0,
    LifeCyclePhaseInitialized = LifeCyclePhaseEnumBegin,
    LifeCyclePhaseViewDidLoad,
    LifeCyclePhaseViewWillAppear,
    LifeCyclePhaseViewDidAppear,
    LifeCyclePhaseViewWillDisappear,
    LifeCyclePhaseViewDidDisappear,
    LifeCyclePhaseViewDidUnload,
    LifeCyclePhaseEnumEnd,
    LifeCyclePhaseEnumSize = LifeCyclePhaseEnumEnd - LifeCyclePhaseEnumBegin
} LifeCyclePhase;

/**
 * View controllers which must be able to embed another view controller as subview can inherit from this class
 * to benefit from correct event propagation (e.g. viewDidLoad, rotation events, etc.). Moreover, this class
 * also supports view controller different depending on the orientation (see HLSOrientationCloner protocol).
 * The inherited class must create a placeholder view instance, either using a xib or by implementing the viewDidLoad
 * method.
 * 
 * The reason this class exists is that embedding view controllers by directly adding a view controller's
 * view as subview of another view controller's view does not work correctly out of the box. Most view controller
 * events will be fired up correctly (e.g viewDidLoad or rotation events), but other simply won't (e.g. viewWillAppear:).
 * This means that when adding a view controller's view directly as subview, the viewWillAppear: message has to be sent
 * manually, which is disturbing and awkward (the same has to be done when removing the view).
 *
 * The wrapped view controller can be swapped with another one at any time. Simply update the viewController property. 
 * This makes pages or tabs easy to code.
 *
 * When you derive from HLSPlaceholderViewController, it is especially important not to forget to call the super class
 * view lifecycle methods first if you override any of them, otherwise the behaviour will be undefined. Similarly 
 * for methods related to interface orientation and initialization methods. This means:
 *   - initWithNibName:bundle:
 *   - initWithCoder: (for view controllers instantiated from a xib)
 *   - viewWill...
 *   - viewDid...
 *   - shouldAutorotateToInterfaceOrientation: : If the call to the super method returns NO, return NO immediately (this
 *                                               means that the inset cannot rotate).
 *   - willRotateToInterfaceOrientation:duration:
 *   - willAnimate...
 *   - didRotateFromInterfaceOrientation:
 * and to animation:
 *   - viewAnimation...
 *
 * As with standard built-in view controllers (e.g. UINavigationController), the inset view controller's view rect is known
 * when viewWillAppear: gets called for it. If you need to insert code requiring to know the final view dimensions or changing
 * the screen layout (e.g. hiding a navigation bar), be sure to insert it in viewWillAppear: or events thereafter (in other
 * words, NOT in viewDidLoad).
 * You should not alter the inset view controller's view frame yourself, otherwise the behavior is undefined.
 *
 * About view reuse: A view controller is retained when set as inset, and released when done. If no other object keeps
 * a strong reference to it, it will get deallocated, and so will its view. This is perfectly fine in general since
 * it contributes to saving resources. But if you need to reuse a view which has already been built (most likely if you
 * you plan to display it later by the same placeholder view controller), you need to have another object retain the view 
 * controller to keep it alive.
 * For example, you might use HLSPlaceholderViewController to switch through N view controllers using toggle buttons. If 
 * those view controllers bear heavy views, you do not want to have them destroyed when you switch view controllers. You want
 * to pay the price once, either by creating all views at the beginning, or more probably by using some lazy creation mechanism.
 * In such cases, be sure to retain all those view controllers elsewhere (most naturally by the same object which
 * instantiated the placeholder view controller). In such cases, though, you must ensure that this object is capable of
 * releasing the views if memory is critically low. If this object is a view controller, this means you must implement
 * didReceiveMemoryWarning so that cached view controller's views can be set to nil when needed.
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSPlaceholderViewController : UIViewController <HLSReloadable, HLSViewAnimationDelegate> {
@private
    UIViewController *m_insetViewController;
    BOOL m_insetViewAddedAsSubview;                 // Avoid testing the view controller view property (this triggers view loading,
                                                    // which we want to precisely control so that it happens when it has to). Test
                                                    // this boolean value instead, which means that the inset view controller's view
                                                    // has been added to the placeholder view as subview (which is actually when
                                                    // we precisely need view loading to occur)
    CGAffineTransform m_originalInsetViewTransform;
    CGFloat m_originalInsetViewAlpha;
    UIViewController *m_oldInsetViewController;
    CGAffineTransform m_oldOriginalInsetViewTransform;
    CGFloat m_oldOriginalInsetViewAlpha;
    UIView *m_placeholderView;
    LifeCyclePhase m_lifeCyclePhase;                // Which lifecycle phase is the placeholder view controller currently in?
    BOOL m_adjustingInset;
}

/**
 * Set the view controller to display as inset. The transition is made without animation
 */
@property (nonatomic, retain) UIViewController *insetViewController;

/**
 * Set the view controller to display as inset. A fade out animation can be applied (if not nil) to the view controller
 * which is removed (when the animation ends, the associated view is removed), and a fade in animation can be applied 
 * (if not nil) to the view controller which is installed. In both cases, simply supply the sequence of HLSAnimationSteps
 * to apply
 * This method does not apply any animation if the view controller is not visible or about to be displayed, or if no 
 * inset view controller is installed (insetViewController set to nil) or changed
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
     withFadeOutAnimationSteps:(NSArray *)fadeOutAnimationSteps
          fadeInAnimationSteps:(NSArray *)fadeInAnimationSteps;

/**
 * Display an inset view controller using one of the available built-in transition styles (default transition duration,
 * which can vary depending on the animation)
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Display an inset view controller using one of the available built-in transition styles (the duration can be
 * freely set; it will be distributed evenly on the animation steps composing the animation)
 */
- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration;

/**
 * The view where inset view controller's view must be drawn. Either created programmatically in a subclass' loadView method 
 * or bound to a UIView in Interface Builder
 */
@property (nonatomic, retain) IBOutlet UIView *placeholderView;

/**
 * If set to YES, the inset view controller's view frame is automatically adjusted to match the placeholder bounds. The behavior
 * depends on the autoresizing behavior of the inset view (e.g. it will fulfill the placeholder view when able to stretch in
 * both directions). If set to NO, the inset view is used as is.
 * Default value is NO
 */
@property (nonatomic, assign, getter=isAdjustingInset) BOOL adjustingInset;

// TODO: Add a delegate mechanism similar to the one of UINavigationController

@end
