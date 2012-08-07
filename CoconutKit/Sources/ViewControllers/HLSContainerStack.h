//
//  HLSContainerStack.h
//  CoconutKit
//
//  Created by Samuel Défago on 09.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSTransitionStyle.h"

// Forward declarations
@protocol HLSContainerStackDelegate;

// Standard capacities
extern const NSUInteger HLSContainerStackMinimalCapacity;
extern const NSUInteger HLSContainerStackDefaultCapacity;
extern const NSUInteger HLSContainerStackUnlimitedCapacity;

/**
 * The HLSContainerStack class purpose is to make container implementation (which is not a trivial task) as
 * easy as possible. Implementing a view controller container correctly is namely difficult. The
 * HLSContainerStack class offers the following features:
 *   - view lifecycle and rotation events are correctly forwarded to children view controllers
 *   - view controllers can be unloaded or removed when deep enough into the stack (capacity)
 *   - view controller properties (title, navigation items, etc.) can be forwarded automatically to the
 *     container view controller
 *   - view controllers can be added and removed anywhere in the stack with the correct animation
 *   - children view controller views are instantiated when really needed, not earlier
 *   - view controllers can be loaded into a container before it is displayed
 
 * Instead of having to manage children view controllers manually, instantiate a container stack, and attach 
 * it the view where children must be drawn once it is available
 *
 */
@interface HLSContainerStack : NSObject <HLSAnimationDelegate> {
@private
    UIViewController *m_containerViewController;
    NSMutableArray *m_containerContents;                       // The first element corresponds to the root view controller
    UIView *m_containerView;
    NSUInteger m_capacity;
    BOOL m_removing;
    BOOL m_rootViewControllerMandatory;
    BOOL m_forwardingProperties;
    id<HLSContainerStackDelegate> m_delegate;
}

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

/**
 * If set to YES, the view controller properties (title, navigation controller, navigation elements, toolbar, etc.)
 * are forwarded through the container controller if the container is iteslf a view controller. This makes it possible
 * to display those elements transparently higher up in the view controller hierarchy
 */
@property (nonatomic, assign, getter=isForwardingProperties) BOOL forwardingProperties;

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
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
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
         withTransitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;
- (void)insertViewController:(UIViewController *)viewController
         belowViewController:(UIViewController *)siblingViewController
         withTransitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;
- (void)insertViewController:(UIViewController *)viewController
         aboveViewController:(UIViewController *)siblingViewController
         withTransitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;

- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * When a container rotates, its content view frame changes. Some animations (most notably those involving views moved
 * outside the screen, e.g. "push from" animations) depend on the frame size: For a push from left animation, the
 * applied horizontal translation used to move view controllers outside view depends on the interface orientation. 
 * For such animations, we must update the view controller's view positions when the device goes from landscape into 
 * portrait mode, otherwise the views might be incorrectly located after a rotation has occurred. 
 *
 * To perform this change, the following method generates an animation object which must be played when the container
 * your are implementing rotates (if your container is itself a view controller, this means this method must be called 
 * from the willAnimateRotationToInterfaceOrientation:duration: method)
 *
 * The animation returned by this method has meaningful settings for a rotation animation (locking interaction, resizing 
 * views, bringing views to front). You can still tweak them or set other properties (e.g. delegate, tag, etc.) if needed.
 */
- (void)rotateWithDuration:(NSTimeInterval)duration;

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
 * Unlike UINavigationController, these events are called when a view controller is shown or hidden, in pair with
 * viewWill and viewDid events sent to the child view controller (these events are of course only received for
 * view controllers at the top of the stack). This makes them more intuitive, meaningful and
 * ultimately useful, though this behavior does not match the one of UINavigationControllerDelegate. It is namely
 * possible to catch appearance and disappearance events both in the child view controllers themselves or in the
 * container delegate, depending on your needs.
 *
 * Moreover, when the willShow method of UINavigationControllerDelegate is called, the child view controller
 * is already installed at the top of [navigationController viewControllers]. This is counter-intuitive and
 * we lose valuable information (i.e. whether the view controller is being added or was already in the child
 * view controller list). This is not the case for HLSContainerStack: The willShow event is sent before a
 * child view controller is shown or even added to the stack. This makes it possible to find whether a push
 * occurs or not.
 *
 * For information, here is UINavigationController behavior: the willShow and didShow methods are called when 
 * presenting a view controller as a result of pushing a new one or popping the one above in the navigation
 * stack. This event is also received when the view controller's view is reloadded after a memory warning has
 * occurred. Similarly for the willHide event (for which UINavigationControllerDelegate has no counterpart),
 * which is received only after the view controller has been hidden or popped off the stack.
 */
@protocol HLSContainerStackDelegate <NSObject>

/**
 * Called before the view controller is shown (and even before it is added in the case of a push). If
 * [containerStack viewControllers] indexOfObject:viewController] == NSNotFound, a call of this method
 * therefore corresponds to a push, otherwise the view controller was already part of the stack and is
 * simply being revealed
 */
- (void)containerStack:(HLSContainerStack *)containerStack
willShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

- (void)containerStack:(HLSContainerStack *)containerStack
 didShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

- (void)containerStack:(HLSContainerStack *)containerStack
willHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

/**
 * Called after the view controller has been hidden (and even after it is removed in the case of a pop). If
 * [containerStack viewControllers] indexOfObject:viewController] == NSNotFound, a call of this method
 * therefore corresponds to a pop, otherwise the view controller was already part of the stack and has
 * simply been hidden from view
 */
- (void)containerStack:(HLSContainerStack *)containerStack
 didHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated;

@end

@interface UIViewController (HLSContainerStack)

- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass;

@end
