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
 * Remark:
 * -------
 * As written in the UIKit documentation (though slightly scattered all around), view controller's view frame dimensions
 * are only known when -viewWillAppear: gets called, not earlier (this means you should avoid making calculations
 * depending on it in the viewDidLoad method; the frame is the one you got from the xib, not necessarily the one which
 * will be used after status, navigation bar, etc. have been added, or after some container controller updates the
 * view controller's frame for display).
 *
 * The same is true for rotations: The final frame dimensions are known in -willAnimateRotationToInterfaceOrientation:duration:
 * (1-step rotation) or -willAnimateFirstHalfOfRotationToInterfaceOrientation:duration: (2-step rotation, deprecated
 * starting with iOS 5).
 */
@interface UIViewController (HLSExtensions)

/**
 * Convenience method to set the view controller to nil and forward -viewWill/DidUnload events correctly
 * Not meant to be overridden
 *
 * Remark: Originally I intended to call this method unloadView, but UIViewController already implements this method... privately
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
 * Original size of the view right after creation (i.e. right after xib deserialization or construction by -loadView)
 */
- (CGSize)originalViewSize;

/**
 * Return YES iff the current view controller lifecycle can be transitioned to the one received as parameter
 */
- (BOOL)isReadyForLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase;

/**
 * Return YES iff the receiver implements the new iOS 6 rotation methods -shouldAutorotate and -supportedInterfaceOrientations
 * (also possible for iOS 4 when using CoconutKit)
 */
- (BOOL)implementsNewAutorotationMethods;

/**
 * Return YES iff the receiver can autorotate to at least one of the supplied orientations
 */
- (BOOL)shouldAutorotateForOrientations:(UIInterfaceOrientationMask)orientations;

/**
 * Return YES iff the receiver has at least one compatible orientation with the supplied view controller. If viewController
 * is nil, this method returns NO
 */
- (BOOL)isOrientationCompatibleWithViewController:(UIViewController *)viewController;

/**
 * Return YES iff the receiver can autorotate to the supplied interface orientation
 */
- (BOOL)autorotatesToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 * Return the first interface orientation supported by the receiver, and compatible with a given orientation set
 * (respectively a view controller). Orientations are checked in the following order:
 *   - portrait (the usual default orientation on iPhone and iPad)
 *   - landscape right (on iPad, this is the orientation we get when using a smart cover)
 *   - landscape left
 *   - portrait upside down (the usually disabled orientation on iPhone)
 *
 * Return 0 if no compatible orientation is found, or if viewController is nil
 */
- (UIInterfaceOrientation)compatibleOrientationWithOrientations:(UIInterfaceOrientationMask)orientations;
- (UIInterfaceOrientation)compatibleOrientationWithViewController:(UIViewController *)viewController;

@end
