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
 * iOS 4 as well, and provides powerful features which let you implement custom containers correctly in a snap. The 
 * iOS 5containment API, though powerful, namely still requires a lot of work to implement perfect containers. 
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
 *     implemented is far richer than the ones of UIKit built-in containers (most notably UINavigationController). 
 *     Your custom containers usually just need to forward the events their users might be interested in through a
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
 *   - view controllers are owned by a stack, but if you need to cache some of them for performance reasons,
 *     you still can: Simply keep and manage an external strong reference to the view controllers you want to cache
 *   - storyboards are supported (iOS 5 and above only). You are responsible of implementing segues in your own
 *     container implementations, though (see HLSPlaceholderViewController.m and HLSStackController.m for examples)
 *   - view controller containment relationships are consistent with those expected from UIKit built-in containers.
 *     In particular, some properties are automatically forwarded from a child view controller to a navigation
 *     controller if it displays a custom container, and modal view controllers are presented by the furthest
 *     ancestor container
 *   - a custom container can contain several HLSContainerStacks if it needs to display several children view
 *     controllers simultaneously
 *
 * When implementing your own view controller container, be sure to call the following HLSContainerStack
 * methods, otherwise the behavior is undefined (refer to their documentation for more information):
 *   - releaseViews
 *   - viewWillAppear:
 *   - viewDidAppear:
 *   - viewWillDisappear:
 *   - viewDidDisappear:
 *   - shouldAutorotateToInterfaceOrientation:
 *   - willRotateToInterfaceOrientation:duration:
 *   - willAnimateRotationToInterfaceOrientation:duration:
 *   - didRotateFromInterfaceOrientation:duration:
 * (the deprecated 2-step rotation methods are not supported, you should not have your own containers implement
 * them)
 * Also do not forget to set a containerView, either in your container -loadView or -viewDidLoad methods
 *
 * Remark: No methods have been provided for -viewDidLoad and -viewDidUnload (call -releaseViews instead)
 *
 * Even though the new iOS 5 containment API is promising, implementing your own view controllers using
 * HLSContainerStack has many advantages, and is far easier. For examples of implementations, have a look 
 * at HLSStackController.m and HLSPlaceholderViewController.m. Give it a try, you won't be disappointed!
 *
 * Designated initializer: initWithContainerViewController:capacity:removing:rootViewControllerMandatory:
 */
@interface HLSContainerStack : NSObject <HLSAnimationDelegate> {
@private
    UIViewController *m_containerViewController;               // The container view controller implemented using HLSContainerStack
    NSMutableArray *m_containerContents;                       // The contents loaded into the stack. The first element corresponds to the root view controller
    UIView *m_containerView;                                   // The view where the stack displays its contents
    NSUInteger m_capacity;                                     // The maximum number of top view controllers loaded / not removed at any time
    BOOL m_removing;                                           // If YES, view controllers over capacity are removed from the stack, otherwise their views are simply unloaded
    BOOL m_rootViewControllerMandatory;                        // Is the root view controller mandatory?
    BOOL m_animating;                                          // Set to YES when a transition animation is running
    id<HLSContainerStackDelegate> m_delegate;                  // The stack delegate, usually the custom container which is implemented
}

/**
 * Convenience constructor to instantiate a stack containing at most one child view controller
 */
+ (id)singleControllerContainerStackWithContainerViewController:(UIViewController *)containerViewController;

/**
 * Create a stack which will manage the children view controllers of a container view controller. The containerViewController
 * parameter is the container you want to implement (which must itself instantiate the HLSContainerStack objects it requires) 
 * and is not retained. If removing is NO, the capacity is the maximum number of view controllers whose views are loaded at 
 * any time. If removing is YES, the capacity corresponds to the maximum number of view controllers which can exist in the 
 * container at any time (the view controllers deep enough are automatically removed from the stack). If rootViewControllerMandatory 
 * is set to YES, at least one view controller must always exist in the container
 *
 * Remark: During transition animations, the capacity is temporary increased by one to provide for smooth animations. This
 *         is not a bug
 */
- (id)initWithContainerViewController:(UIViewController *)containerViewController 
                             capacity:(NSUInteger)capacity
                             removing:(BOOL)removing
          rootViewControllerMandatory:(BOOL)rootViewControllerMandatory;

/**
 * The view where the stack must display the children view controller's views. This view must be part of the container
 * view controller's view hierarchy and cannot be set once it has been displayed (in general, though, you need to
 * set it once in the container view controller -loadView or -viewDidLoad method)
 */
@property (nonatomic, strong) UIView *containerView;

/**
 * The stack delegate (usually the container view controller you are implementing)
 */
@property (nonatomic, assign) id<HLSContainerStackDelegate> delegate;

/**
 * Return the root view controller loaded into the stack, or nil if none
 */
- (UIViewController *)rootViewController;

/**
 * Return the current topmost view controller, or nil if none
 */
- (UIViewController *)topViewController;

/**
 * Return the view controllers currently loaded into the stack, from the bottommost to the topmost one
 */
- (NSArray *)viewControllers;

/**
 * Return the number of view controllers loaded into the stack
 */
- (NSUInteger)count;

/**
 * Push a view controller on top of the stack using a given animation class (subclass of HLSTransition). You can subclass
 * HLSTransition to create your custom animations, or use the CoconutKit built-in ones. Refer to HLSTransiton.h for more
 * information. If duration is set to kAnimationTransitionDefaultDuration, the view controller is pushed with the default
 * duration defined by the animation. You can freely change this value, in which case the animation will look the same,
 * only slower or faster. If animated is set to YES, the animation will occur, otherwise not. You can still pop the view
 * controller later with animated = YES.
 *
 * This method can also be used to preload view controllers into a stack (in which case the animated parameter is ignored)
 */
- (void)pushViewController:(UIViewController *)viewController
       withTransitionClass:(Class)transitionClass
                  duration:(NSTimeInterval)duration
                  animated:(BOOL)animated;

/**
 * Pop the current top view controller, playing the reverse animation corresponding to the one it has been pushed with.
 * If a root view controller is mandatory, you cannot pop it
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 * Pop all view controllers up to a given view controller (animated or not). If viewController is set to nil, this 
 * method pops all view controllers (except if a root view controller is mandatory, in which case this method does
 * nothing)
 *
 * When the transition is animated, the pop occurs with the reverse animation corresponding to the animation with
 * which the topmost view controller was pushed
 *
 * If the view controller is not in the stack or if it is already the top view controller, this method does nothing.
 */
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * Same as -popToViewController:animated: (animated or not), but specifying a view controller using its index. Set 
 * index to NSUInteger to pop everything (except if a root view controller is mandatory, in which case this method 
 * does nothing)
 *
 * If the index is invalid or if it is the index of the top view controller (i.e. [self count] - 1), this method 
 * does nothing
 */
- (void)popToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Pop to the root view controller (animated or not)
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;

/**
 * Pop all view controllers (except if a root view controller is mandatory, in which case this does nothing)
 */
- (void)popAllViewControllersAnimated:(BOOL)animated;

/**
 * Insert a view controller at the specified index with some transition animation properties. If index == [self count],
 * the view controller is added at the top of the stack, and the transition animation takes place (provided animated has
 * been set to YES). In all other cases, no animation occurs. Note that the corresponding reverse animation will still 
 * be played when the view controller is later popped
 *
 * If the index is invalid, this method does nothing
 */
- (void)insertViewController:(UIViewController *)viewController
                     atIndex:(NSUInteger)index
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;

/**
 * Insert a view controller below an existing one. If the provided sibling view controller does not exist in the
 * stack, this method does nothing
 */
- (void)insertViewController:(UIViewController *)viewController
         belowViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration;

/**
 * Insert a view controller above an existing one. If the provided sibling view controller does not exist in the
 * stack, this method does nothing. If siblingViewController is the current top view controller, the transition
 * will be animated (provided animated has been set to YES), otherwise no animation will occur
 */
- (void)insertViewController:(UIViewController *)viewController
         aboveViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;

/**
 * Remove the view controller at a given index. If index == [self count] - 1, the removal will be animated
 * (provided animated has been set to YES), otherwise no animation will occur
 *
 * If the index is invalid, this method does nothing
 */
- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Remove a given view controller from the stack. If the view controller is the current top view controller, the
 * transition will be animated (provided animated has been set to YES), otherwise no animation will occur.
 *
 * If the view controller is not in the stack, this method does nothing
 */
- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * Release all view and view-related resources. This also forwards the -viewDidUnload message to the corresponding view
 * controllers. You should call this method from your -viewDidUnload method (better: Have your container view controller
 * subclass HLSViewController, and call this method from its -releaseView method)
 */
- (void)releaseViews;

/**
 * Call this method from your container view controller -viewWillAppear: method, otherwise the behavior is undefined
 */
- (void)viewWillAppear:(BOOL)animated;

/**
 * Call this method from your container view controller -viewDidAppear: method, otherwise the behavior is undefined
 */
- (void)viewDidAppear:(BOOL)animated;

/**
 * Call this method from your container view controller -viewWillDisappear: method, otherwise the behavior is undefined
 */
- (void)viewWillDisappear:(BOOL)animated;

/**
 * Call this method from your container view controller -viewDidDisappear: method, otherwise the behavior is undefined
 */
- (void)viewDidDisappear:(BOOL)animated;

/**
 * Call this method from your container view controller -shouldAutorotateToInterfaceOrientation: method, otherwise the 
 * behavior is undefined
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

/**
 * Call this method from your container view controller -willRotateToInterfaceOrientation:duration: method, otherwise 
 * the behavior is undefined
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

/**
 * Call this method from your container view controller -willAnimateRotationToInterfaceOrientation:duration: method, 
 * otherwise the behavior is undefined
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

/**
 * Call this method from your container view controller -didRotateFromInterfaceOrientation:duration: method, otherwise 
 * the behavior is undefined
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end

/**
 * This protocol offers more methods than the equivalent protocol of UINavigationController. This provides much
 * more information about appearance and disappearance events (and especially since HLSContainerStack allows
 * insertion and removal anywhere in a stack). When implementing your custom containers, you usually just need
 * to set your container as delegate of the stack, catch the events you are interested in, and forward them to 
 * your container delegate through a dedicated protocol
 */
@protocol HLSContainerStackDelegate <NSObject>

/**
 * Called before pushedViewController is about to be pushed onto the stack. When called, pushedViewController does not
 * belong to [self viewControllers] yet, and the parent-child containment relationship has not been established. 
 * The coveredViewController parameter is the view controller which is about to be covered (nil if none)
 */
- (void)containerStack:(HLSContainerStack *)containerStack
willPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated;

/**
 * Called when a child view controller is about to be displayed. When called, viewController is always in 
 * [self viewControllers], even if this event is the result of a push
 */
- (void)containerStack:(HLSContainerStack *)containerStack
willShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

/**
 * Called when a child view controller has been displayed
 */
- (void)containerStack:(HLSContainerStack *)containerStack
 didShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

/**
 * Called when a view controller has been pushed onto the stack. The coveredViewController parameter is the view
 * controller which was covered (nil if none)
 */
- (void)containerStack:(HLSContainerStack *)containerStack
 didPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated;

/**
 * Called when a view controller is about to be popped off the stack. The revealedViewController parameter is the
 * view controller which will be revealed (nil if none)
 */
- (void)containerStack:(HLSContainerStack *)containerStack
 willPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated;

/**
 * Called when a child view controller is about to be hidden
 */
- (void)containerStack:(HLSContainerStack *)containerStack
willHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

/**
 * Called when a view controller has been hidden. When called, viewController is still in [self viewControllers],
 * even if this event is received during a pop
 */
- (void)containerStack:(HLSContainerStack *)containerStack
 didHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

/**
 * Called when a view controller has been popped off the stack. When called, poppedViewController has been removed
 * from [self viewControllers], and the parent-child containment relationship has been broken. The revealedViewController
 * parameter is the view controller which has been revealed (nil if none)
 */
- (void)containerStack:(HLSContainerStack *)containerStack
  didPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated;

@end

@interface UIViewController (HLSContainerStack)

/**
 * Your custom containers should implement a UIViewController method for retrieving the parent container from within
 * a child view controller (as -navigationController or -tabBarController do). Implement your own method returning
 * your parent view controller container (if any) by declaring a UIViewController category. Its implementation is
 * straightforward: Simply call the method below with your container class as argument
 */
- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass;

@end
