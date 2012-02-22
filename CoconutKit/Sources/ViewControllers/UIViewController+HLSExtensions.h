//
//  UIViewController+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

// Lifecycle phases
typedef enum {
    HLSViewControllerLifeCyclePhaseEnumBegin = 0,
    HLSViewControllerLifeCyclePhaseInitialized = HLSViewControllerLifeCyclePhaseEnumBegin,
    HLSViewControllerLifeCyclePhaseViewDidLoad,
    HLSViewControllerLifeCyclePhaseViewWillAppear,
    HLSViewControllerLifeCyclePhaseViewDidAppear,
    HLSViewControllerLifeCyclePhaseViewWillDisappear,
    HLSViewControllerLifeCyclePhaseViewDidDisappear,
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
 * As written in UIKit documentation (though slightly scattered all around), view controller's view frame dimensions
 * are only known when viewWillAppear: gets called, not earlier (this means you should avoid making calculations
 * depending on it in the viewDidLoad method; the frame is the one you got from the xib, not necessarily the one which
 * will be used after status, navigation bar, etc. have been added, or after some container controller updates the
 * view controller's frame for display).
 * The same is true for rotations: The final frame dimensions are known in willAnimateRotationToInterfaceOrientation:duration:
 * (1-step rotation) or willAnimateFirstHalfOfRotationToInterfaceOrientation:duration: (2-step rotation, deprecated
 * starting with iOS 5).
 */
@interface UIViewController (HLSExtensions)

/**
 * Convenience method to set the view controller to nil and forward viewDidUnload to its view controller
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
 * Return YES iff the view is visible (appearing, appeared, or disappearing)
 */
- (BOOL)isViewVisible;

/**
 * Original size of the view right after creation (i.e. right after xib deserialization or construction by loadView)
 */
- (CGSize)originalViewSize;

/**
 * Return YES iff the current view controller lifecycle can be transitioned to the one received as parameter
 */
- (BOOL)isReadyForLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase;

@end
