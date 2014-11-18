//
//  HLSContainerStack.h
//  CoconutKit
//
//  Created by Samuel Défago on 09.07.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSAutorotation.h"
#import "HLSTransition.h"

// Stack behavior
typedef NS_ENUM(NSInteger, HLSContainerStackBehavior) {
    HLSContainerStackBehaviorEnumBegin = 0,
    HLSContainerStackBehaviorDefault = HLSContainerStackBehaviorEnumBegin,              // Child view controller views get unloaded when the container capacity has been reached
    HLSContainerStackBehaviorRemoving,                                                  // Child view controllers get removed from the container when its capacity has been reached
    HLSContainerStackBehaviorFixedRoot,                                                 // The root view controller is mandatory and cannot be removed. Otherwise same as HLSContainerStackBehaviorDefault
    HLSContainerStackBehaviorEnumEnd,
    HLSContainerStackBehaviorEnumSize = HLSContainerStackBehaviorEnumEnd - HLSContainerStackBehaviorEnumBegin
};

// Forward declarations
@protocol HLSContainerStackDelegate;

// Standard capacities
extern const NSUInteger HLSContainerStackMinimalCapacity;
extern const NSUInteger HLSContainerStackDefaultCapacity;
extern const NSUInteger HLSContainerStackUnlimitedCapacity;

/**
 * The HLSContainerStack provides a convenient and easy interface to implement your own view controller containers,
 * which is usually not a trivial task. This class is provides powerful features which let you implement custom 
 * containers correctly in a snap. The iOS containment API, though powerful, namely still requires a lot of work
 * to implement perfect containers. This is not the case with HLSContainerStack, which provides a robust way to 
 * implement the containers of your dreams.
 *
 * HLSContainerStack uses the smoother 1-step rotation available from iOS 3. You cannot use the 2-step rotation methods
 * for view controllers you insert in it (they will be ignored, see UIViewController documentation). The 2-step rotation 
 * is deprecated starting with iOS 5, you should not use it anymore in your view controller implementations anyway.
 *
 * A lot of work has been made to provide a clean and powerful interface letting you easily implement containers with
 * correct behavior. Most notably:
 *   - view lifecycle and rotation events are correctly forwarded to children view controllers
 *     Remark: Even if a view controller remains visible behind a transparent top view controller on top of it, it will
 *             still be considered as having disappeared (and therefore will receive the -viewWillDisappear: and 
 *             -viewDidDisappear: events). It would namely be difficult and costly to determine if part of a view 
 *             controller's view is visible through the view controller hierarchy on top of it (this would require
 *             finding the intersections of all view and subview rectangles, multiplicating alphas to find which 
 *             parts of the view are visible and which aren't; clearly not worth it).
 *   - custom animations can be provided when inserting view controllers into a stack. A standard set of
 *     animations is provided out of the box. Animations behave correctly in all cases, even if the stack
 *     was rotated between push and pop operations, or if views have been unloaded
 *   - a delegate (usually your container implementation) can register itself with a stack to be notified when 
 *     a view controller gets pushed, popped, appears or disappears. The set of delegate methods which can be 
 *     implemented is far richer than the ones of UIKit built-in containers (most notably UINavigationController). 
 *     Your custom containers usually just need to forward the events their users might be interested in through a
 *     dedicated delegate protocol
 *   - the methods -[UIViewController isMovingTo/FromParentViewController] return correct results, consistent
 *     with those returned when using standard built-in UIKit containers
 *   - a capacity can be provided so that children view controller's views deep enough are automatically removed
 *     from the view hierarchy and reinserted when needed. The reason is that having too many view non-opaque
 *     view controllers can lead to performance issues, especially during animations (due to layer blending).
 *     By limiting the number of views in the container view hierarchy, such issues can be kept under control.
 *     Alternatively, a view controller can be removed from the stack as soon as it gets deep enough. This makes 
 *     it possible to implement containers with a FIFO behavior (the case where the capacity is set to 1 corresponds 
 *     to a stack displaying a single child view controller). Usually, the default capacity (which is given by
 *     HLSContainerStackDefaultCapacity = 2) should fulfill most needs, but if you require more transparency levels
 *     you can increase this value. Standard capacity values are provided at the beginning of this file.
 *   - custom containers implemented using HLSContainerStack behave correctly, whether they are embedded into 
 *     another container (even built-in ones), displayed as the root of an application, or modally
 *   - stacks can be used to display any kind of view controllers, even standard UIKit containers like
 *     UITabBarController or UINavigationController
 *   - custom containers can be nested to create any kind of application workflow
 *   - view controllers can be preloaded into a stack before it is actually displayed
 *   - view controllers can be inserted into or removed from a stack at any position. Methods have been supplied
 *     to pop to a given view controller (even the root one) or to remove all view controllers at once
 *   - children view controller's views are instantiated right when needed, avoding waste of memory
 *   - view controllers are owned by a stack, but if you need to cache some of them for performance reasons,
 *     you still can: Simply keep and manage an external strong reference to the view controllers you want to cache
 *   - storyboards are supported. You are responsible of implementing segues in your own container implementations, 
 *     though (see HLSPlaceholderViewController.m and HLSStackController.m for examples)
 *   - view controller containment relationships are consistent with those expected from UIKit built-in containers.
 *     In particular, some properties are automatically forwarded from a child view controller to a navigation
 *     controller if it displays a custom container, and modal view controllers are presented by the furthest
 *     ancestor container
 *   - a custom container can contain several HLSContainerStacks if it needs to display several children view
 *     controllers simultaneously
 *   - the container view can be resized at will, even when child view controllers are displayed
 *
 * When implementing your own view controller container, be sure to call the following HLSContainerStack
 * methods, otherwise the behavior is undefined (refer to the documentation of these methods for more 
 * information):
 *     -viewWillAppear:
 *     -viewDidAppear:
 *     -viewWillDisappear:
 *     -viewDidDisappear:
 *     -shouldAutorotateToInterfaceOrientation:
 *     -willRotateToInterfaceOrientation:duration:
 *     -willAnimateRotationToInterfaceOrientation:duration:
 *     -didRotateFromInterfaceOrientation:duration:
 * (the deprecated 2-step rotation methods are not supported, you should not have your own containers implement
 * them)
 *
 * Also do not forget to set a containerView, either in your container -loadView or -viewDidLoad methods
 *
 * Even though the iOS containment API is promising, implementing your own view controllers using
 * HLSContainerStack has many advantages, and is far easier. For examples of implementations, have a look 
 * at HLSStackController.m and HLSPlaceholderViewController.m. Give it a try, you won't be disappointed!
 */
@interface HLSContainerStack : NSObject <HLSAnimationDelegate>

/**
 * Convenience constructor to instantiate a stack containing at most one child view controller
 */
+ (instancetype)singleControllerContainerStackWithContainerViewController:(UIViewController *)containerViewController;

/**
 * Create a stack which will manage the children view controllers of a container view controller. The containerViewController
 * parameter is the container you want to implement (which must itself instantiate the HLSContainerStack objects it requires) 
 * and is not retained. The behavior parameter sets how the container manages its child view controllers. If the behavior
 * is HLSContainerStackBehaviorDefault or HLSContainerStackBehaviorFixedRoot, the container unloads child view controller
 * views deep in the stack so that there is never more than 'capacity' views loaded at any time (in addition, if the
 * behavior is HLSContainerStackBehaviorFixedRoot, the root view controller is mandatory and cannot be changed, which means
 * all operations which could later change it will fail). If the behavior is HLSContainerStackBehaviorRemoving, the container 
 * removes child view controller views deep in the stack, so that there is never more than 'capacity' view controllers loaded
 * at any time
 *
 * For standard capacity constants, have a look at the top of this header file
 *
 * Remark: During transition animations, the capacity is temporary increased by one to avoid view controllers popping up
 *         unnecessarily. This is not a bug
 */
- (instancetype)initWithContainerViewController:(UIViewController *)containerViewController
                                       behavior:(HLSContainerStackBehavior)behavior
                                       capacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;

/**
 * The view where the stack must display the children view controller's views. This view must be part of the container
 * view controller's view hierarchy and cannot be set once it has been displayed (in general, though, you need to
 * set it once in the container view controller -loadView or -viewDidLoad method)
 */
@property (nonatomic, strong) UIView *containerView;

/**
 * Set how a container decides whether it must rotate or not. Your containers should in general exhibit a similar 
 * property, whose implementation must be forwarded to this HLSContainerContent property
 *
 * HLSAutorotationModeContainer: All child view controllers loaded according to the capacity decide whether rotation
 *                               can occur, and receive the related events
 * HLSAutorotationModeContainerAndNoChildren: No children decide whether rotation occur, and none receive the
 *                                            related events
 * HLSAutorotationModeContainerAndTopChildren: The top child view controller decide whether rotation can occur,
 *                                             and receive the related events
 * HLSAutorotationModeContainerAndAllChildren: All child view controllers decide whether rotation can occur, and receive 
 *                                             the related events
 *
 * The default value is HLSAutorotationModeContainer
 */
@property (nonatomic, assign) HLSAutorotationMode autorotationMode;

/**
 * The stack delegate (usually the container view controller you are implementing)
 */
@property (nonatomic, weak) id<HLSContainerStackDelegate> delegate;

/**
 * If set to YES, the user interface interaction is blocked during the time the animation is running (see
 * the running property documentation for more information about what "running" actually means)
 *
 * Default is YES
 */
@property (nonatomic, assign) BOOL lockingUI;

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
 * If the root view controller is fixed, you cannot pop it
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 * Pop all view controllers up to a given view controller (animated or not). If viewController is set to nil, this 
 * method pops all view controllers (except if the root view controller is fixed, in which case this method does
 * nothing)
 *
 * When the transition is animated, the pop occurs with the reverse animation corresponding to the animation with
 * which the topmost view controller was pushed
 *
 * If the view controller is not in the stack or if it is already the top view controller, this method does nothing.
 */
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * Same as -popToViewController:animated:, but specifying a view controller using its index. Set index to NSUIntegerMax
 * to pop everything (except if the root view controller is fixed, in which case this method does nothing)
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
 * Pop all view controllers (except if the root view controller is fixed, in which case this method does nothing)
 */
- (void)popAllViewControllersAnimated:(BOOL)animated;

/**
 * Insert a view controller at the specified index with some transition animation properties. If index == [self count],
 * the view controller is added at the top of the stack, and the transition animation takes place (provided animated has
 * been set to YES). In all other cases, no animation occurs. Note that the corresponding reverse animation will still 
 * be played when the view controller is later popped
 *
 * If the index is invalid, or if its is 0 and the root view controller is fixed (after the stack has been displayed
 * once), this method does nothing
 */
- (void)insertViewController:(UIViewController *)viewController
                     atIndex:(NSUInteger)index
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;

/**
 * Insert a view controller below an existing one. If the provided sibling view controller does not exist in the
 * stack, or if the sibling view controller is the root view controller and is fixed, this method does nothing
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
 * If the index is invalid, or if it is 0 and the root view controller is fixed, this method does nothing
 */
- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Remove a given view controller from the stack. If the view controller is the current top view controller, the
 * transition will be animated (provided animated has been set to YES), otherwise no animation will occur.
 *
 * If the view controller is not in the stack, or if it is the root view controller and is fixed, this method 
 * does nothing
 */
- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated;

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
 * Call this method from your container view controller -shouldAutorotate: method, otherwise the behavior is undefined
 */
- (BOOL)shouldAutorotate;

/**
 * Call this method from your container view controller -supportedInterfaceOrientations method, otherwise the behavior
 * is undefined
 */
- (NSUInteger)supportedInterfaceOrientations;

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
 * straightforward: Simply call the method below with your container class as argument. If Nil is provided as class
 * parameter, lookup is performed for any kind of CoconutKit-based container
 */
- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass;

/**
 * Return the interface orientation used for displaying the view controller. For view controllers not embedded into
 * CoconutKit containers, this value is the same as the one returned by -[UIViewController interfaceOrientation], 
 * matching the status bar orientation. For view controllers embedded into CoconutKit containers, this is the 
 * orientation of the view controller, compatible with the container, which has been used for display (this might
 * not necessarily match the status bar orientation)
 */
@property (nonatomic, readonly, assign) UIInterfaceOrientation displayedInterfaceOrientation;

@end

@interface HLSContainerStack (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
