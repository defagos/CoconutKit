//
//  HLSContainerStack.h
//  CoconutKit
//
//  Created by Samuel Défago on 09.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSTransition.h"

// Forward declarations
@protocol HLSContainerStackDelegate;

// Standard capacities
extern const NSUInteger HLSContainerStackMinimalCapacity;
extern const NSUInteger HLSContainerStackDefaultCapacity;
extern const NSUInteger HLSContainerStackUnlimitedCapacity;

/**
 * The HLSContainerStack provides a convenient and easy interface to implement your own view controller containers,
 * which is usually not a trivial task. Unlike the UIViewController containment API, this class is compatible with 
 * iOS 4 as well, and provides powerful features which let you implement custom containers in a snap. The iOS 5 
 * containment API, though powerful, namely still requires a lot of work to implement perfectly working containers. 
 * This is not the case with HLSContainerStack, which provides a robust way to implement the containers of your
 * dreams.
 *
 * A lot of work has been made to provide a clean and powerful interface to implement containers exhibiting
 * correct behavior and maximum flexibility. Most notably:
 *   - view lifecycle and rotation events are correctly forwarded to children view controllers
 *   - custom animations can be provided when pushing view controllers into a stack. A standard set of
 *     animations is provided out of the box. Animations behave correctly in all cases, even if the stack
 *     was rotated between push and pop operations, or if views have been unloaded
 *   - a delegate (usually your container implementation) can register itself with a stack to be notified when 
 *     a view controller gets pushed, popped, appears or disappears. The set of delegate methods which can be 
 *     implemented is far richer than the ones of UIKit built-in containers, e.g. UINavigationController. Your
 *     custom containers usually then only need to forward those events they are interested in through a
 *     dedicated delegate protocol
 *   - the methods -[UIViewController isMovingTo/FromParentViewController] return correct results, consistent
 *     with those returned when using standard built-in UIKit containers (iOS 5 only)
 *   - a depth can be provided so that children view controller's views deep enough are automatically unloaded
 *     and reloaded when needed, saving memory. Alternatively, a view controller can be removed from the stack
 *     as soon as it gets deep enough. This makes it possible to implement containers with a FIFO behavior (the
 *     case where the depth is set to 1 corresponds to a stack displaying a single child view controller)
 *   - custom containers implemented using HLSContainerStack behave correctly, whether they are embedded into 
 *     another container (even built-in ones), displayed as the root of an application, or modally
 *   - stacks can be used to display any kind of view controllers, even standard UIKit containers like
 *     UITabBarController or UINavigationController
 *   - custom containers can be nested to create any kind of application workflow
 *   - view controllers can be preloaded into a stack before it is actually displayed
 *   - view controllers can be inserted into or removed from a stack at any position. Methods have been supplied
 *     to pop to a given view controller (even the root one) or to remove all view controllers at once
 *   - children view controller's views are instantiated right when needed, avoding wasting memory
 *   - view controllers are owned by a stack, but if you need to cached some of them for performance reasons,
 *     you still can: Simply manage an external strong reference to the view controllers you want to cache
 *   - storyboards are supported (iOS 5 and above only). You are responsible of implementing segues in your own
 *     container implementations, though (see HLSPlaceholderViewController.m and HLSStackController.m for examples)
 *   - view controller containment relationships are consistent with those expected from UIKit built-in containers.
 *     In particular, some properties are automatically forwarded from a child view controller to a navigation
 *     controller if it displays a custom container, and modal view controllers are presented by the furthest
 *     ancestor container
 *   - a custom container can contain several HLSContainerStacks if it needs to display several children view
 *     controllers simultaneously
 *
 * Even though the new iOS 5 containment API is promising, implementing your own view controllers using
 * HLSContainerStack has many advantages. Give it a try, you won't be disappointed!
 *
 * Designated initializer: initWithContainerViewController:capacity:removing:rootViewControllerMandatory:
 */
@interface HLSContainerStack : NSObject <HLSAnimationDelegate> {
@private
    UIViewController *m_containerViewController;
    NSMutableArray *m_containerContents;                       // The first element corresponds to the root view controller
    UIView *m_containerView;
    NSUInteger m_capacity;
    BOOL m_removing;
    BOOL m_rootViewControllerMandatory;
    BOOL m_animating;
    id<HLSContainerStackDelegate> m_delegate;
}

/**
 * Convenience constructor to instantiate a 
 */
+ (id)singleControllerContainerStackWithContainerViewController:(UIViewController *)containerViewController;

/**
 * Create a stack which will manage the children of a container view controller. The view controller container
 * is not retained
 */

// Document: During insertions, we might have capacity + 1 view controllers at the same time. This ensures that no view controller
// is abruptly removed when showing a new one. capacity is the "static" number of view controllers available when no animations
// take place
- (id)initWithContainerViewController:(UIViewController *)containerViewController 
                             capacity:(NSUInteger)capacity
                             removing:(BOOL)removing
          rootViewControllerMandatory:(BOOL)rootViewControllerMandatory;

// TODO: Prevent from being changed after the view has been displayed
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) id<HLSContainerStackDelegate> delegate;

- (UIViewController *)rootViewController;
- (UIViewController *)topViewController;

- (NSArray *)viewControllers;

- (NSUInteger)count;

/**
 * Create the animation needed to display the view controller's view in the container view. If the receiver is part
 * of a container content stack, the stack can be supplied as parameter so that the animation can be tailored
 * accordingly.
 *
 * The first element in the stack array is interpreted as the bottommost one.
 *
 * The animation returned by this method has meaningful settings for a container animation (locking interaction, not resizing 
 * views, bringing views to front). You can still tweak them or set other properties (e.g. delegate, tag, etc.) if needed.
 */
- (void)pushViewController:(UIViewController *)viewController
       withTransitionClass:(Class)transitionClass
                  duration:(NSTimeInterval)duration
                  animated:(BOOL)animated;

- (void)popViewControllerAnimated:(BOOL)animated;

// If viewController is nil: Pop everything. Also add remark about view controllers with transparency (this of course
// does not yield a nice effect)
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

// Pass NSUIntegerMax to pop all
- (void)popToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)popAllViewControllersAnimated:(BOOL)animated;

// TODO: Document special values (cnt - 1, integermax)
- (void)insertViewController:(UIViewController *)viewController
                     atIndex:(NSUInteger)index
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;
- (void)insertViewController:(UIViewController *)viewController
         belowViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;
- (void)insertViewController:(UIViewController *)viewController
         aboveViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;

- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated;

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
// TODO: Call these methods containerViewWill/Did or simply containerWill/Did?
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end

/**
 * This protocol offers more methods than the equivalent protocol of a UINavigationController. This provides much
 * more information about the appearance and disappearance events (and especially since HLSContainerStack allows
 * popping to an arbitrary view in the stack)
 */
@protocol HLSContainerStackDelegate <NSObject>

/**
 * Called before viewController is added to [containerStack viewControllers] (before the parent-child containment
 * relationship is established)
 */
- (void)containerStack:(HLSContainerStack *)containerStack
willPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated;

/**
 * When called, viewController is always in [containerStack viewControllers], even if this event is the result
 * of a push
 */
- (void)containerStack:(HLSContainerStack *)containerStack
willShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

- (void)containerStack:(HLSContainerStack *)containerStack
 didShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

- (void)containerStack:(HLSContainerStack *)containerStack
 didPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated;

- (void)containerStack:(HLSContainerStack *)containerStack
 willPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated;

- (void)containerStack:(HLSContainerStack *)containerStack
willHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

/**
 * When called, viewController is still in [containerStack viewControllers]
 */
- (void)containerStack:(HLSContainerStack *)containerStack
 didHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

/**
 * When called, viewController has been removed from [containerStack viewControllers] (and the parent-child containment
 * relationship has been removed)
 */
- (void)containerStack:(HLSContainerStack *)containerStack
  didPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated;

@end

@interface UIViewController (HLSContainerStack)

- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass;

@end
