//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSAutorotation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Lifecycle phases
typedef NS_ENUM(NSInteger, HLSViewControllerLifeCyclePhase) {
    HLSViewControllerLifeCyclePhaseEnumBegin = 0,
    HLSViewControllerLifeCyclePhaseInitialized = HLSViewControllerLifeCyclePhaseEnumBegin,
    HLSViewControllerLifeCyclePhaseViewDidLoad,
    HLSViewControllerLifeCyclePhaseViewWillAppear,
    HLSViewControllerLifeCyclePhaseViewDidAppear,
    HLSViewControllerLifeCyclePhaseViewWillDisappear,
    HLSViewControllerLifeCyclePhaseViewDidDisappear,
    HLSViewControllerLifeCyclePhaseEnumEnd,
    HLSViewControllerLifeCyclePhaseEnumSize = HLSViewControllerLifeCyclePhaseEnumEnd - HLSViewControllerLifeCyclePhaseEnumBegin
};

/**
 * Various useful additions to UIViewController, most notably the ability get more information about the view lifecycle.
 *
 * Remark:
 * -------
 * As written in the UIKit documentation (though slightly scattered all around), view controller's view frame dimensions
 * are only known when -viewWillAppear: gets called, not earlier (this means you should avoid making calculations
 * depending on it in the -viewDidLoad method; the frame is the one you got from the xib, not necessarily the one which
 * will be used after status, navigation bar, etc. have been added, or after some container controller updates the
 * view controller's frame for display).
 *
 * The same is true for rotations: The final frame dimensions are known in -willAnimateRotationToInterfaceOrientation:duration:
 */
@interface UIViewController (HLSExtensions)

/**
 * Return the lifecycle phase the view controller is currently in
 * Not meant to be overridden
 */
@property (nonatomic, readonly) HLSViewControllerLifeCyclePhase lifeCyclePhase;

/**
 * Return the view controller's view if loaded, nil otherwise
 */
@property (nonatomic, readonly) UIView *viewIfLoaded;

/**
 * Return YES iff the view is displayed and visible (appearing, appeared, or disappearing)
 */
@property (nonatomic, readonly, getter=isViewVisible) BOOL viewVisible;

/**
 * Return YES iff the view has been displayed (it might be invisible, though). Note that the frame of a view is reliable 
 * only when it is displayed
 */
@property (nonatomic, readonly, getter=isViewDisplayed) BOOL viewDisplayed;

/**
 * Size of the view right after it has been created (more precisely, right before -viewDidLoad is called)
 */
@property (nonatomic, readonly) CGSize createdViewSize;

/**
 * Return YES iff the current view controller lifecycle can be transitioned to the one received as parameter
 */
- (BOOL)isReadyForLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase;

@end

#ifdef DEBUG

@interface UIViewController (HLSDebugging)

/**
 * Private method printing the receiver view controller hierarchy recursively. Only use for debugging purposes
 */
- (void)_printHierarchy;

@end

#endif

NS_ASSUME_NONNULL_END
