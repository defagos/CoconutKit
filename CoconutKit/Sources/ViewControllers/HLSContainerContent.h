//
//  HLSContainerContent.h
//  CoconutKit
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSContainerStackView.h"

/**
 * View controllers inserted into view controller containers exhibit common properties:
 *   - they belong to a container, which they must be able to identify, and they should not be inserted into several
 *     containers at the same time
 *   - they are inserted into a container with some transition animation, and removed from it with the corresponding
 *     reverse animation
 *   - a child view controller's view should be created lazily at the time it is really required
 *   - it must be possible to preload a view controller container before it gets actually displayed (i.e. before the
 *     container view is loaded)
 *   - a view controller container must retain the child view controllers it manages
 *   - a view controller's view properties should be restored when it is removed from a container. It might namely
 *     happen that a client caches this view controller for later reuse
 *   - animations should always be able to assume that view controller's views have alpha = 1.f (this makes implementing
 *     them easy since this does not require any knowledge about the view controller's view alpha). This issue is solved
 *     by having HLSContainerContent always wrap view controller's views within an invisible view having alpha = 1.f
 *   - a child view controller's view must be adjusted to fill the entire container view it is drawn in. This matches
 *     the behavior of standard UIKit containers (UINavigationController, UITabBarController, etc.)
 *   - view lifecycle and rotation events must be forwarded correctly from the container to the contained view controllers
 *   - the view controller containment chain must be preserved, so that view controller properties can be automatically
 *     forwarded from a child to its parent (and higher up in the view controller hierarchy if this parent is itself
 *     embedded into a container). This makes it possible for a navigation controller to use relevant child view controller 
 *     properties when it displays the corresponding parent view controller, for example. Moreover, this ensures that when 
 *     a child view controller presents another view controller modally, it is actually its furthest ancestor who does. 
 *     Finally, this guarantees that the -[UIViewController interfaceOrientation] method returns a correct result
 *   - the iOS containment API defines methods -[UIViewController isMovingTo/FromParentViewController] so that
 *     a child knows when it is inserted or removed from a container. These methods must return a correct result
 *     for custom containers as well
 *   - when a view controller is removed from a container, its view must not be released. This lets clients decide whether
 *     they want to cache the associated view (by retaining the view controller elsewhere) or not (if the view controller
 *     is not retained elsewhere, it will simply be deallocated when it gets removed from the container, and so will be 
 *     its view)
 *
 * The private HLSContainerContent class provides a way to ensure that all above common properties can be easily 
 * fulfilled. It can be seen as some kind of smart pointer object, keeping ownership of a view controller as long
 * as it belongs to a container, and destroyed when the view controller is removed from the container (the view
 * controller itself might be retained elsewhere for caching purposes, though). All interactions with a child view 
 * controller must happen through the HLSContainerContent interface to guarantee proper status tracking and to 
 * ensure that the view is created when it is really needed, not earlier.
 *
 * HLSContainerContent can only be used when implementing containers for which automatic view lifecycle event forwarding
 * has been disabled, i.e. for which the -[UIViewController shouldAutomaticallyForwardRotationMethods] and 
 * -[UIViewController shouldAutomaticallyForwardAppearanceMethods] methods return NO
 */
@interface HLSContainerContent : NSObject

/**
 * Return the CoconutKit-based container into which a view controller has been inserted into (if any). If a class parameter 
 * is provided, the method returns nil if the container class does not match
 */
+ (UIViewController *)containerViewControllerKindOfClass:(Class)containerViewControllerClass
                                       forViewController:(UIViewController *)viewController;

/**
 * Initialize a container content object. Expect the view controller to be managed (which is retained), the container 
 * in which it is inserted into (not retained), as well as the details of the transition animation with which it gets 
 * displayed. Use the reserved kAnimationTransitionDefaultDuration duration to use the default animation duration.
 */
- (instancetype)initWithViewController:(UIViewController *)viewController
               containerViewController:(UIViewController *)containerViewController
                       transitionClass:(Class)transitionClass
                              duration:(NSTimeInterval)duration NS_DESIGNATED_INITIALIZER;

/**
 * The attached view controller. If you need to access its view, do not use the -[UIViewController view] property
 * (this triggers lazy creation). Instead, use the view insertion methods provided by HLSContainerContent when you 
 * really need to instantiate the view (i.e. when building up the container view hierarchy), and the 
 * -[HLSContainerContent viewIfLoaded] accessor to access a view which you created this way (and which does not
 * instantiate the view lazily).
 */
@property (nonatomic, readonly, strong) UIViewController *viewController;

/**
 * The container into which a view controller has been inserted
 */
@property (nonatomic, readonly, weak) UIViewController *containerViewController;

/**
 * The transition properties to be applied when the view controller's view gets displayed
 */
@property (nonatomic, readonly, assign) Class transitionClass;
@property (nonatomic, readonly, assign) NSTimeInterval duration;

/**
 * Return YES iff the view controller has been added to a container
 */
@property (nonatomic, readonly, assign, getter=isAddedToContainerView) BOOL addedToContainerView;

/**
 * Instantiate (if not already) and add the view controller's view at the top of a stack view. The frame of the view
 * controller's view is automatically adjusted to match the bounds of the stack view
 *
 * If the view has already been added to a stack view, this method does nothing
 */
- (void)addAsSubviewIntoContainerStackView:(HLSContainerStackView *)containerStackView;

/**
 * Valid values for index range from 0 to [containerStackView.contentViews count] (this last value being equivalent to
 * calling -addAsSubviewIntoContainerStackView:)
 *
 * If the view has already been added to a stack view or if the index is invalid, this method does nothing
 */
- (void)insertAsSubviewIntoContainerStackView:(HLSContainerStackView *)containerStackView atIndex:(NSUInteger)index;

/**
 * Return the view controller's view if it has been loaded, nil otherwise. This does not perform lazy view 
 * creation. When you need to create the associated view, use -addAsSubviewIntoContainerStackView: or
 * -insertAsSubviewIntoContainerStackView:index
 */
- (UIView *)viewIfLoaded;

/**
 * Remove the view controller's view from its container view (if added to a container view)
 */
- (void)removeViewFromContainerStackView;

/**
 * Forward the corresponding view lifecycle events to the view controller, ensuring that forwarding occurs only if
 * the view controller current lifecycle phase is coherent with it. Set movingTo/FromParentViewController to YES
 * if the events occur because the view controller is being added to / removed from its parent container
 *
 * Remark: No methods have been provided for -viewDidLoad (which is called automatically when the view has been loaded)
 *         and -viewWill/DidUnload
 */
- (void)viewWillAppear:(BOOL)animated movingToParentViewController:(BOOL)movingToParentViewController;
- (void)viewDidAppear:(BOOL)animated movingToParentViewController:(BOOL)movingToParentViewController;
- (void)viewWillDisappear:(BOOL)animated movingFromParentViewController:(BOOL)movingFromParentViewController;
- (void)viewDidDisappear:(BOOL)animated movingFromParentViewController:(BOOL)movingFromParentViewController;

/**
 * Forward the corresponding view rotation events to the view controller
 *
 * Remark: No methods have been provided for the deprecated 2-step rotation methods
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end

@interface HLSContainerContent (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
