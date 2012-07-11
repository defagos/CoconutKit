//
//  HLSContainerContent.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSContainerStack.h"
#import "HLSTransitionStyle.h"
#import "UIViewController+HLSExtensions.h"

/**
 * View controllers inserted into view controller containers exhibit common properties:
 *   - they belong to a container, which they must be able to identify, and they should not be inserted into several
 *     containers at the same time
 *   - they are added and removed using some transition style, and their view frame is adjusted to match the container
 *     view they are added to
 *   - a view controller's view should be created lazily at the time it is really required
 *   - it must be possible to preload a view controller container before it gets actually displayed
 *   - a view controller container must retain the view controllers it manages
 *   - a view controller's view properties should be restored when it is removed from a container. It might namely
 *     happen that a client caches this view controller for later reuse
 *   - view lifecycle events must be forwarded correctly from the container to the contained view controllers
 *   - we sometimes may want the view controller container to forward some properties of a contained view controller
 *     (e.g. title, navigation elements, toolbar, etc.) transparently
 *   - a view controller added to a a container should be able to present or dismiss another view controller modally
 *     by calling the corresponding UIViewController methods on self. In such cases, it is actually the container
 *     which must present the modal view controller. This mechanism must be transparent for the user
 *   - the UIViewController interfaceOrientation property (readonly) is only correctly set when the view controller
 *     is presented using built-in UIKit view controller containers. This has to be fixed when a view controller is
 *     presented using a custom container
 *   - a remark: The UIViewController parentViewController property returns the parent view controller if it is one 
 *     of the buit-in UIKit containers (according to UIViewController documentation). It would make sense to have this
 *     property also return a container for view controllers displayed in custom container view controllers. Sadly
 *     this is not possible: Doing so has some real benefits (automatic forwarding of navigation title and bar color,
 *     correct value for interfaceOrientation), but we lose the ability to choose whether we actually want forwarding
 *     to occur or not. UIKit built-in containers automatically reflect their content, but this must namely not be the 
 *     case for containers in general (imagine a container displaying two view controllers simultaneously: Which one 
 *     is going to give its title to the container controller? The container may also want to have its own title after 
 *     all). For this reason, the parentViewController property has not been altered and returns nil even when a view
 *     controller is embedded into a custom container view controller.
 *
 * The HLSContainerContent class provides a way to ensure that the above common properties can be easily implemented. It 
 * can be seen as some kind of smart pointer object, taking ownership of a view controller when inserted into a view 
 * controller container. Note that the view controller's view is NOT released when the HLSContainerContent object is
 * destroyed. This lets clients decide whether they want to cache the view (by retaining the associating view controller
 * themeselves) or not (if the view controller is not retained elsewhere, it will simply be deallocated when the 
 * HLSContainerContent object managing it is destroyed, and so will be its view).
 * 
 * When implementing a view controller container, use an HLSContainerContent object (retained by the container) to take 
 * ownership of a view controller when it is inserted, and simply release the HLSContainerContent object when the view 
 * controller gets removed from the container. When interacting with the view controller, use the HLSContainerContent
 * object as a proxy to help you guarantee that the common properties listed above are fulfilled. In particular,
 * use all provided methods for animating views, forwarding lifecycle events, etc.
 *
 * HLSContainerContent can only be used when implementing containers for which automatic view lifecycle event forwarding
 * has been disabled, i.e. for which the
 *    automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
 * method returns NO (a feature available as of iOS 5).
 * 
 * Designated initializer: initWithViewController:containerViewController:transitionStyle:duration:
 */
@interface HLSContainerContent : NSObject {
@private
    UIViewController *m_viewController;
    UIViewController *m_containerViewController;
    HLSTransitionStyle m_transitionStyle;
    NSTimeInterval m_duration;
    BOOL m_addedToContainerView;
    CGRect m_originalViewFrame;
    CGFloat m_originalViewAlpha;
    UIViewAutoresizing m_originalAutoresizingMask;
    HLSViewControllerLifeCyclePhase m_lifeCyclePhase;
    BOOL m_forwardingProperties;
}

/**
 * Return the container of the specified class, in which a given view controller has been inserted, or nil if none
 */
+ (id)containerControllerKindOfClass:(Class)containerControllerClass forViewController:(UIViewController *)viewController;

/**
 * Initialize a container content manager object. Requires the view controller to be managed, the container in which
 * it is inserted, as well as the details of the transition with which it gets displayed. Use the reserved
 * kAnimationTransitionDefaultDuration duration for the default animation duration.
 * The view controller is retained.
 */
- (id)initWithViewController:(UIViewController *)viewController
     containerViewController:(UIViewController *)containerViewController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration;

/**
 * The attached view controller. If you need to access its view, do not use the UIViewController view property
 * (this triggers lazy creation). Instead, use the addViewToContainerView:inContainerContentStack: method above 
 * when you really need to instantiate the view, and the HLSContainerContent view accessor to access a view which 
 * you created this way.
 */
@property (nonatomic, readonly, retain) UIViewController *viewController;     // <<<---- TODO: Is it possible to hide this behind the HLSContainerContent public interface? Would be safer!
@property (nonatomic, readonly, assign) UIViewController *containerViewController;
@property (nonatomic, readonly, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, readonly, assign) NSTimeInterval duration;

@property (nonatomic, readonly, assign, getter=isAddedAsSubview) BOOL addedToContainerView;
@property (nonatomic, readonly, assign) CGRect originalViewFrame;
@property (nonatomic, readonly, assign) CGFloat originalViewAlpha;


/**
 * Instantiate (if not already) and add the view controller's view as subview of a view managed by the container 
 * controller (the view in which it displays its content).
 *
 * Some view controller containers might display several view controllers simultaneously in the same content view. In
 * such cases, the corresponding stack of container content objects can be provided (the receiver must be part of it).
 * This allows the view to be inserted at the proper location in the view hierarchy. If this parameter is nil, the
 * view is simply added on top.
 * The first element in the stack array is interpreted as the bottommost one.
 * 
 * The frame of the view which is added is automatically adjusted to match the container view bounds. This is the
 * usual behavior of built-in view controller containers (UINavigationController, UITabBarController)
 *
 * Return YES if the view has been added, NO if it was already added. Must assert that containerView is the same view
 * as all views in containerContentStack
 */
- (void)addAsSubviewIntoContainerView:(UIView *)containerView;
- (void)insertAsSubviewIntoContainerView:(UIView *)containerView atIndex:(NSUInteger)index;

/**
 * Remove the view controller's view from the container view. Does not release the view (call releaseViews for this
 * purpose)
 */
- (void)removeViewFromContainerView;

/**
 * Return the view controller's view if added to a container view, nil otherwise. Does not perform lazy instantiation,
 * you must explicitly build the view when you need using addViewToContainerView:inContainerContentStack. This forces
 * you to create the view when you actually need it
 */
- (UIView *)view;

/**
 * Release all view and view-related resources. This also forwards the viewDidUnload message to the corresponding view
 * controller
 */
- (void)releaseViews;

/**
 * Forward the corresponding view lifecycle events to the view controller, ensuring that forwarding occurs only if
 * the view controller current lifecycle phase is coherent
 *
 * Remark: No methods have been provided for viewDidLoad (which is called automatically when the view has been loaded)
 *         and viewDidUnload (which container implementations must not call directly; use the releaseViews method above)
 */
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

/**
 * If set to YES, the view controller properties (title, navigation controller, navigation elements, toolbar, etc.)
 * are forwarded through the container controller if the container is iteslf a view controller. This makes it possible
 * to display those elements transparently higher up in the view controller hierarchy
 */
@property (nonatomic, assign, getter=isForwardingProperties) BOOL forwardingProperties;

@end
