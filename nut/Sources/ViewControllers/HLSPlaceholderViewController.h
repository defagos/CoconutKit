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
 * When you derive from HLSPlaceholderViewController, it is especially important not to forget to call the super
 * view lifecycle methods first, otherwise the behaviour will be undefined. Similarly for methods related to interface
 * orientation and initialization methods. This means:
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
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSPlaceholderViewController : UIViewController <HLSReloadable, HLSViewAnimationDelegate> {
@private
    UIViewController *m_insetViewController;
    UIViewController *m_oldInsetViewController;
    NSArray *m_fadeInAnimationSteps;
    HLSTransitionStyle m_transitionStyle;
    UIView *m_placeholderView;
    BOOL m_autoresizesInset;
    BOOL m_firstDisplay;
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
 * Remark: If this method is called when no view controller was displayed (e.g. right after creation and before the
 *         placeholder view controller is displayed), then the fade out animation is ignored. Similarly, if no
 *         view controller is being installed (insetViewController is nil), then the fade in animation will be
 *         ignored
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

@property (nonatomic, retain) IBOutlet UIView *placeholderView;

/**
 * If set to YES, then the inset view is automatically resized to fill the placeholder view, otherwise
 * it keeps its original size. Default is NO
 */
@property (nonatomic, assign) BOOL autoresizesInset;

@end
