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
    NSMutableArray *m_containerContents;
    UIView *m_containerView;
    NSUInteger m_capacity;
    BOOL m_forwardingProperties;
    BOOL m_removingInvisibleViewControllers;
}

/**
 * Create a stack which will manage the children of a container view controller. The view controller container
 * is not retained
 */
- (id)initWithContainerViewController:(UIViewController *)containerViewController;

// TODO: Prevent from being changed after the view has been displayed
@property (nonatomic, assign) UIView *containerView;
@property (nonatomic, assign) NSUInteger capacity;

/**
 * If set to YES, the view controller properties (title, navigation controller, navigation elements, toolbar, etc.)
 * are forwarded through the container controller if the container is iteslf a view controller. This makes it possible
 * to display those elements transparently higher up in the view controller hierarchy
 */
@property (nonatomic, assign, getter=isForwardingProperties) BOOL forwardingProperties;

// TODO: Prevent changes when the stack has been displayed once. Default value is NO
@property (nonatomic, assign, getter=isRemovingInvisibleViewControllers) BOOL removingInvisibleViewControllers;

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
                  duration:(NSTimeInterval)duration;

- (void)popViewController;

- (void)popToViewController:(UIViewController *)viewController;
- (void)popToRootViewController;

// TODO: Can be used to pop without animation. Can be used to remove at the front (i.e. remove
//       the root view controller, which can be useful) or in the middle (can be used to implement
//       a popToViewController)
- (void)removeViewControllerAtIndex:(NSUInteger)index;

// TODO: Implement
// - insertViewControllerAtIndex:
// - replaceViewControllerAtIndex:

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
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end

@protocol HLSContainerStackDelegate <NSObject>

- (void)containerStack:(HLSContainerStack *)containerStack
willPushViewController:(UIViewController *)viewController
              animated:(BOOL)animated
              userInfo:(NSDictionary *)userInfo;
- (void)containerStack:(HLSContainerStack *)containerStack
 didPushViewController:(UIViewController *)viewController
              animated:(BOOL)animated
              userInfo:(NSDictionary *)userInfo;
- (void)containerStack:(HLSContainerStack *)containerStack
 willPopViewController:(UIViewController *)viewController
              animated:(BOOL)animated
              userInfo:(NSDictionary *)userInfo;
- (void)containerStack:(HLSContainerStack *)containerStack
  didPopViewController:(UIViewController *)viewController
              animated:(BOOL)animated
              userInfo:(NSDictionary *)userInfo;

@end

@interface UIViewController (HLSContainerStack)

- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass;

@end
