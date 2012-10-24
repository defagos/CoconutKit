//
//  UIViewController+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAutorotation.h"

// Lifecycle phases
typedef enum {
    HLSViewControllerLifeCyclePhaseEnumBegin = 0,
    HLSViewControllerLifeCyclePhaseInitialized = HLSViewControllerLifeCyclePhaseEnumBegin,
    HLSViewControllerLifeCyclePhaseViewDidLoad,
    HLSViewControllerLifeCyclePhaseViewWillAppear,
    HLSViewControllerLifeCyclePhaseViewDidAppear,
    HLSViewControllerLifeCyclePhaseViewWillDisappear,
    HLSViewControllerLifeCyclePhaseViewDidDisappear,
    HLSViewControllerLifeCyclePhaseViewWillUnload,
    HLSViewControllerLifeCyclePhaseViewDidUnload,
    HLSViewControllerLifeCyclePhaseEnumEnd,
    HLSViewControllerLifeCyclePhaseEnumSize = HLSViewControllerLifeCyclePhaseEnumEnd - HLSViewControllerLifeCyclePhaseEnumBegin
} HLSViewControllerLifeCyclePhase;

/**
 * Various useful additions to UIViewController, most notably the ability get more information about the view lifecycle.
 * This category also provide automatic keyboard dismissal when a view controller disappears while a text field was
 * active.
 *
 * Moreover, this category makes the new iOS 6 rotation methods also available on iOS 4 and iOS 5. This means you can
 * setup the rotation behavior of any view controller by simply implementing the two methods
 *     -shouldAutorotate 
 * and -supportedInterfaceOrientations
 * instead of implementing the old -shouldRotateToInterfaceOrientation: method. Rotation masks compatible with iOS 6
 * ones are defined in HLSOrientationMode if you need to compile against the iOS 4 or 5 SDKs. If you compile against
 * the iOS 6 SDK, you should use the new UIInterfaceOrientationFlags instead.
 *
 * As a quick reference:
 *    -shouldAutorotateToInterfaceOrientation: is called on iOS 4 and 5 by UIKit, never by UIKit on iOS 6. It can
 *     still be called by client code on iOS 6
 *    -shouldAutorotate and -supportedInterfaceOrientations are never called by UIKit directly on iOS 4 and 5, and
 *     are only called by UIKit starting with iOS 6. They can still be called by client code on iOS 4 and 5 since
 *     CoconutKit adds support for those methods on iOS 4 and 5 as well
 *
 * You can still implement the usual -shouldRotateToInterfaceOrientation: method if you prefer, but by implementing
 * the new iOS 6 methods above, your code will be the same for all versions of iOS. If you implement both the old
 * and new methods, only the new ones will be taken into account.
 *
 * Remark:
 * -------
 * As written in the UIKit documentation (though slightly scattered all around), view controller's view frame dimensions
 * are only known when viewWillAppear: gets called, not earlier (this means you should avoid making calculations
 * depending on it in the viewDidLoad method; the frame is the one you got from the xib, not necessarily the one which
 * will be used after status, navigation bar, etc. have been added, or after some container controller updates the
 * view controller's frame for display).
 *
 * The same is true for rotations: The final frame dimensions are known in willAnimateRotationToInterfaceOrientation:duration:
 * (1-step rotation) or willAnimateFirstHalfOfRotationToInterfaceOrientation:duration: (2-step rotation, deprecated
 * starting with iOS 5).
 */
@interface UIViewController (HLSExtensions)

/**
 * Convenience method to set the view controller to nil and forward -viewWill/DidUnload events correctly
 * Not meant to be overridden
 * Note: Originally I intended to call this method unloadView, but UIViewController already implements this method... privately
 */
- (void)unloadViews;

/**
 * Return the lifecycle phase the view controller is currently in
 * Not meant to be overridden
 */
- (HLSViewControllerLifeCyclePhase)lifeCyclePhase;

/**
 * Return the view controller's view if loaded, nil otherwise
 */
- (UIView *)viewIfLoaded;

/**
 * Return YES iff the view is displayed and visible (appearing, appeared, or disappearing)
 */
- (BOOL)isViewVisible;

/**
 * Return YES iff the view has been displayed (it might be invisible, though). Note that the frame of a view is reliable 
 * only when it is displayed
 */
- (BOOL)isViewDisplayed;

/**
 * Original size of the view right after creation (i.e. right after xib deserialization or construction by loadView)
 */
- (CGSize)originalViewSize;

/**
 * Return YES iff the current view controller lifecycle can be transitioned to the one received as parameter
 */
- (BOOL)isReadyForLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase;

/**
 * Return YES iff the receiver can autorotate to at least one of the supplied orientations
 */
- (BOOL)shouldAutorotateForOrientations:(HLSInterfaceOrientationMask)orientations;

/**
 * Return YES iff the receiver has at least one compatible orientation with the supplied view controller
 */
- (BOOL)isOrientationCompatibleWithViewController:(UIViewController *)viewController;

@end
