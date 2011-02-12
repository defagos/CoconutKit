//
//  HLSViewController.h
//  nut
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
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
 * Raw view controller class adding useful stuff to UIViewController. This class is not meant to be instantiated directly,
 * you should subclass it to define your own view controllers.
 *
 * If your subclass overrides any of the view lifecycle events methods (viewWill..., viewDid...), be sure to call the super
 * method first, otherwise the behaviour is undefined.
 *
 * Designated initializer: initWithNibName:bundle:
 */
@interface HLSViewController : UIViewController {
@private
    HLSViewControllerLifeCyclePhase m_lifeCyclePhase;
}

/**
 * Override this method in you subclass, and release all views retained by the view controller in its implementation. This method 
 * gets called automatically when deallocating or receiving a viewDidUnload event. This allows to cleanly separate the object releasing
 * code of a view controller into two blocks:
 *   - in releaseViews: Release all views retained by the view controller. If your view controller subclass retains view controllers
 *     to avoid creating their views too often ("view caching"), also set the views of thesee view controllers to nil in this method
 *   - in dealloc: Release all other resources owned by the view controller (model objects, other view controllers, etc.)
 * If you are subclassing a class already subclassing HLSViewController, do not forget to send the releaseView message to super first.
 */
- (void)releaseViews;

/**
 * Return the life cycle phase the view controller is currently in
 * Not meant to be overridden
 */
- (HLSViewControllerLifeCyclePhase)lifeCyclePhase;

@end
