//
//  HLSStackController.h
//  CoconutKit
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSReloadable.h"
#import "HLSTransitionStyle.h"
#import "HLSViewController.h"

// Standard capacities
extern const NSUInteger kStackMinimalCapacity;
extern const NSUInteger kStackDefaultCapacity;
extern const NSUInteger kStackUnlimitedCapacity;

// Forward declarations
@protocol HLSStackControllerDelegate;

/**
 * We often need to manage a stack of view controllers. Usually, we use a navigation controller, but there is no way
 * to use other transition animations as the built-in ones. Sometimes, we also want to show view controllers
 * modally, but often the usual presentModalViewController:animated: method of UIViewController is too limited (modal
 * sheets on the iPad have pre-defined sizes, and when displaying full screen the view below disappears, which prevents
 * from displaying transparent modal windows).
 *
 * To circumvent those problems, HLSStackController provides a generic way to deal with a view controller stack. It can
 * be applied a richer set of transition animations. HLSStackController is not meant to be subclassed.
 *
 * This view controller container guarantees correct view lifecycle and rotation event propagation to the view controllers
 * it manages. Note that when a view controller gets pushed onto the stack, the view controller below will get the
 * viewWillDisappear: and viewDidDisappear: events, even if it stays visible through transparency (the same holds for
 * the viewWillAppear: and viewDidAppear: events when the view controller on top gets popped).
 * This decision was made because it would have been extremely difficult and costly to look at all view controller's 
 * views in the stack to find those which are really visible (this would have required to find the intersections of all 
 * view and subview rectangles, cumulating alphas to find which parts of the view stack are visible and which aren't;
 * clearly not worth it).
 *
 * When a view controller's view is inserted into a stack controller, its view frame is automatically adjusted to match 
 * the container view bounds, as for usual UIKit containers (UITabBarController, UINavigationController). Be sure that
 * the view controller's view size and autoresizing behaviors are correctly set.
 *
 * HLSStackController uses the smoother 1-step rotation available from iOS3. You cannot use the 2-step rotation for view 
 * controllers you pushed in it (it will be ignored, see UIViewController documentation). The 2-step rotation is deprecated 
 * starting with iOS 5, you should not use it anymore anyway.
 *
 * Since a stack controller can manage many view controller's views, and since in general only the first few top ones
 * need to be visible, it would be a waste of resources to keep all views loaded at any time. At creation time, the
 * maximal number of loaded view controllers ("capacity") can be provided. By default, the capacity is set to 2, 
 * which means that the container guarantees that at most the two top view controller's views are loaded. The 
 * controller simply unloads the view controller's views below in the stack so save memory. Usually, the default value
 * should fulfill most needs, but if you require more transparency levels or if you want to minimize load / unload
 * operations, you can increase this value. Standard capacity values are provided at the beginning of this file.
 *
 * TODO: This class currently does not support view controllers implementing the HLSOrientationCloner protocol
 *
 * Designated initializer: initWithRootViewController:capacity:
 */
@interface HLSStackController : HLSViewController <HLSReloadable> {
@private
    NSMutableArray *m_containerContentStack;                    // Contains HLSContainerContent objects
    NSUInteger m_capacity;
    BOOL m_forwardingProperties;                                // Does the container forward inset navigation properties transparently?
    id<HLSStackControllerDelegate> m_delegate;
}

/**
 * Create a new stack controller with the specified view controller as root. This view controller cannot be animated when 
 * installed, and can neither be replaced, nor removed. The capacity can be freely set.
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController capacity:(NSUInteger)capacity;

/**
 * Create a new stack controller with the specified view controller as root. This view controller cannot be animated when 
 * installed, and can neither be replaced, nor removed. The default capacity is used.
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;

/**
 * Push a view controller onto the stack without animation.
 * This method can also be called before the stack controller is displayed
 */
- (void)pushViewController:(UIViewController *)viewController;

/**
 * Push a view controller onto the stack using one of the built-in transition styles. The transition duration is set by 
 * the animation itself
 * This method can also be called before the stack controller is displayed (the animation does not get played, but this
 * defines the pop animation which will get played when the view controller is later removed)
 */
- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Same as pushViewController:withTransitionStyle:, but the transition duration can be overridden (the duration will be 
 * evenly distributed on the animation steps composing the animation so that the animation rhythm stays the same). Use 
 * the reserved kAnimationTransitionDefaultDuration value as duration to get the default transition duration (same 
 * result as the method above)
 * This method can also be called before the stack controller is displayed (the animation does not get played, but this
 * defines the pop animation which will get played when the view controller is later removed)
 */
- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration;

/**
 * Remove the top view controller from the stack. The same animation as when it was pushed onto the stack will be played.
 * The root view controller cannot be popped
 */
- (void)popViewController;

/**
 * Return the view controller at the bottom
 */
- (UIViewController *)rootViewController;

/**
 * Return the view controller currently on top
 */
- (UIViewController *)topViewController;

/**
 * The view controllers in the stack. The first one is the root view controller, the last one the top one
 */
- (NSArray *)viewControllers;

/**
 * If set to YES, properties of the top view controller (title, navigation item, toolbar) are forwarded to the stack 
 * controller. When inserted into a navigation controller, the stack view controller thus behaves as if its top view 
 * controller has been directly pushed into it.
 *
 * Default value is NO.
 */
@property (nonatomic, assign, getter=isForwardingProperties) BOOL forwardingProperties;

@property (nonatomic, assign) id<HLSStackControllerDelegate> delegate;

@end

@protocol HLSStackControllerDelegate <NSObject>

@optional

/**
 * Called when a view controller will be shown. This happens when a view controller is pushed onto the stack or
 * revealed by popping the one on top of it
 */
- (void)stackController:(HLSStackController *)stackController 
 willShowViewController:(UIViewController *)viewController 
               animated:(BOOL)animated;

/**
 * Called when a view controller has been shown. This happens when a view controller is pushed onto the stack or
 * revealed by popping the one on top of it
 */
- (void)stackController:(HLSStackController *)stackController
  didShowViewController:(UIViewController *)viewController
               animated:(BOOL)animated;

@end

@interface UIViewController (HLSStackController)

/**
 * Return the stack controller the view controller is inserted in, or nil if none.
 */
@property (nonatomic, readonly, assign) HLSStackController *stackController;

@end
