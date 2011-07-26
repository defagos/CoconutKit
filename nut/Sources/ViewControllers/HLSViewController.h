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
 * method first, otherwise the behaviour is undefined. The same holds for view orientation events.
 *
 * There is only one major difference with UIViewController. For UIViewController, shouldAutorotateToInterfaceOrientation:
 * returns YES only for portrait orientations when not overridden. This creates an exception to the rule that subclasses
 * should call the super view event and orientation methods first. This is confusing and ugly, especially for view controllers
 * picked from a library (in such cases, super has to be called or not depending on the view controller's implementation).
 * If you are lucky, the documentation of a view controller will explicitly state what sublcasses must do, but I think it is
 * best to stick to a single rule, namely to always begin by calling the super implementation. To fix this inconsistency,
 * HLSViewController returns YES for all orientations. Then, If a view controller inherits from HLSViewController (either
 * directly or indirectly), its implementation of shouldAutorotateToInterfaceOrientation: (if overridden) must always
 * always begin with:
 *   if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
 *      return NO;
 *   }
 *   // Rest of the implementation here
 *
 * This class also provides a way to debug view controller events (lifecycle, rotation, memory warnings). You must
 * use the debug version of the library (obtained by compiling it with -DDEBUG added to your target "Other C flags"),
 * and set the logger level of your application to DEBUG (see HLSLogger.h to know how this is achieved). Then use 
 * the console when running your application to have a look at view controller events.
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
 *   - in releaseViews: Release all views created when loading the view, and retained by the view controller. If your view controller 
 *     subclass retains view controllers to avoid creating their views too often ("view caching"), also set the views of thesee view 
 *     controllers to nil in this method. If you are subclassing a class already subclassing HLSViewController, always send the releaseView 
 *     message to super first.
 *   - in dealloc: Release all other resources owned by the view controller (model objects, other view controllers, views
 *     existing before the view is loaded, etc.)
 */
- (void)releaseViews;

/**
 * Convenience method to set the view controller to nil and forward viewDidUnload to its view controller
 * Not meant to be overridden
 * Note: Originally I intented to call this method unloadView, but UIViewController already implements this method... privately
 */
- (void)unloadViews;

/**
 * Return the life cycle phase the view controller is currently in
 * Not meant to be overridden
 */
- (HLSViewControllerLifeCyclePhase)lifeCyclePhase;

/**
 * Return YES iff the view has been loaded
 */
- (BOOL)isViewLoaded;

/**
 * Return YES iff the view has appeared
 */
- (BOOL)isViewVisible;

@end
