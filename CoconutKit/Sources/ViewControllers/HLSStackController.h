//
//  HLSStackController.h
//  CoconutKit
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSContainerStack.h"
#import "HLSViewController.h"

// Forward declarations
@protocol HLSStackControllerDelegate;

/**
 * We often need to manage a stack of view controllers. Usually, we use a navigation controller, but there is no way
 * to easily use other transition animations as the built-in ones. Sometimes, we also want to show view controllers
 * modally, but often the usual -presentViewController:animated:completion: method of UIViewController is too limited. Modal
 * sheets on the iPad have namely pre-defined sizes, and when displaying full screen the view below disappears, which prevents
 * from displaying transparent modal windows (transparent modals are available since iOS 8, though).
 *
 * To circumvent those problems, HLSStackController provides a generic way to deal with a view controller stack, whose
 * root view is fixed and set once at creation time. It can be applied a richer set of transition animations, even
 * custom ones. As UINavigationController and UITabBarController, HLSStackController is not meant to be subclassed.
 *
 * When a view controller's view is inserted into a stack controller, its view frame is automatically adjusted to match 
 * the container view bounds, as is the case with usual UIKit containers (UITabBarController, UINavigationController). 
 * Be sure that the view controller's view size and autoresizing behaviors are correctly set.
 *
 * HLSStackController uses the smoother 1-step rotation available from iOS 3. You cannot use the 2-step rotation methods
 * for view controllers you push in it (they will be ignored, see UIViewController documentation). The 2-step rotation
 * is deprecated starting with iOS 5, you should not use it anymore in your view controller implementations anyway.
 *
 * You can resize or move (even animate!) the stack container view, even when children are displayed. This makes the
 * creation of innovative user interfaces as easy as it can be.
 *
 * Since a stack controller can manage many view controller's views, and since in general only the first few top ones
 * need to be visible, it would be a waste of resources to keep all views loaded at any time. At creation time, the
 * maximal number of view controllers whose views are added to the container view hierarchy ("capacity") can be provided. 
 * By default, the capacity is set to 2, which means that the container guarantees that at most the two top view controller's 
 * views appear in the container view hierarchy. The container simply removes the view controller's views below in the stack 
 * to minimize blending calculations. Usually, the default value should fulfill most needs, but if you require more transparency 
 * levels you can increase this value. Standard capacity values are provided at the beginning of the HLSContainerStack.h file.
 *
 * You can also use stack controllers with storyboards:
 *   - drop a view controller onto the storyboard, and set its class to HLSStackController. You can customize the
 *     view controller capacity by setting an NSNumber user-defined runtime attribute called 'capacity'
 *   - drop another view controller onto the storyboard, and set it as root view controller of the stack by
 *     binding the stack controller with it using an HLSStackPushSegue called 'hls_root'. The transition style which
 *     gets applied is always HLSTransitionStyleNone and cannot be customized
 *   - if you want to push another view controller, drop a view controller onto the storyboard, and connect the 
 *     root view controller with it using another HLSStackPushSegue (with any non-reserved identifier). If you 
 *     need to customize transition settings (e.g. style and duration), you must implement the -prepareForSegue:sender: 
 *     method in your source view controller (the root view controller in this example)
 *   - segues only go one way (as for UINavigationController ones: A segue connection always allocates the 
 *     destination view controller, and thus cannot be bound to existing destinations, refer to the UIStoryboardSegue
 *     documentation for more information). If you want to pop a view controller, you therefore have to do it
 *     programmatically
 * For further information, refer to the documentation of HLSStackPushSegue.
 */
@interface HLSStackController : HLSViewController <HLSContainerStackDelegate>

/**
 * Create a new stack controller with the specified view controller as root. This view controller cannot be animated when 
 * installed, and can neither be replaced, nor removed. The capacity can be freely set. Standard values are provided
 * at the beginning of the HLSContainerStack.h file
 */
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController capacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;

/**
 * Create a new stack controller with the specified view controller as root. This view controller cannot be animated when 
 * installed, and can neither be replaced, nor removed. The default capacity (HLSContainerStackDefaultCapacity= 2) is used.
 */
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

/**
 * Set how the stack controller decides whether it must rotate or not
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
 * The stack controller delegate
 */
@property (nonatomic, weak) id<HLSStackControllerDelegate> delegate;

/**
 * If set to YES, the user interface interaction is blocked during the time the animation is running (see
 * the running property documentation for more information about what "running" actually means)
 *
 * Default is NO
 */
@property (nonatomic, assign) BOOL lockingUI;

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
 * Return the number of view controllers within the stack
 */
- (NSUInteger)count;

/**
 * Push a view controller onto the stack using a given transition class. The transition duration is the one defined by 
 * the animation itself.
 *
 * This method can also be called before the stack controller is displayed (the animation does not get played, but this
 * defines the pop animation which will get played when the view controller is later removed)
 */
- (void)pushViewController:(UIViewController *)viewController 
       withTransitionClass:(Class)transitionClass
                  animated:(BOOL)animated;

/**
 * Same as -pushViewController:withTransitionStyle:, but the transition duration can be tweaked (the animation will
 * look the same, only slower or faster). Use the reserved kAnimationTransitionDefaultDuration value as duration to 
 * get the default transition duration defined by the animation.
 *
 * This method can also be called before the stack controller is displayed (the animation does not get played, but this
 * defines the pop animation which will get played when the view controller is later removed)
 */
- (void)pushViewController:(UIViewController *)viewController
       withTransitionClass:(Class)transitionClass
                  duration:(NSTimeInterval)duration
                  animated:(BOOL)animated;

/**
 * Remove the top view controller from the stack, using the reverse animation corresponding to the transition which was 
 * used to push it
 *
 * The root view controller cannot be popped
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 * Pop all view controllers to get back to a given view controller. The current top view controller will transition
 * to the specified view controller using the reverse animation with which it was pushed onto the stack. 
 *
 * If the view controller to pop to does not belong to the stack or is the current top view controller, this method 
 * does nothing
 */
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * Same as -popToViewController:animated:, but specifying a view controller using its index. Set index to NSUIntegerMax
 * to pop everything
 *
 * If the index is invalid or if its is the index of the top view controller (i.e. [self count] - 1), this method
 * does nothing
 */
- (void)popToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Pop all view controllers to get back to the root view controller. The current top view controller will transition
 * to the root view controller using the reverse animation with which it was pushed onto the stack
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;

/**
 * Insert a view controller at the specified index with some transition animation properties. If index == [self count],
 * the view controller is added at the top of the stack, and the transition animation takes place (provided animated has
 * been set to YES). In all other cases, no animation occurs. Note that the corresponding reverse animation will still
 * be played when the view controller is later popped
 *
 * If the index is invalid, or if index == 0, this method does nothing
 */
- (void)insertViewController:(UIViewController *)viewController
                     atIndex:(NSUInteger)index
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated;

/**
 * Insert a view controller below an existing one. 
 *
 * If the provided sibling view controller does not exist in the stack, or if it is the root view controller, this 
 * method does nothing
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
 * If the index is invalid, or if it is 0, this method does nothing
 */
- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Remove a given view controller from the stack. If the view controller is the current top view controller, the
 * transition will be animated (provided animated has been set to YES), otherwise no animation will occur.
 *
 * If the view controller is not in the stack, or if it is the root view controller, this method does nothing
 */
- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface HLSStackController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 * This protocol offers more methods than the equivalent protocol of UINavigationController. This provides much
 * more information about appearance and disappearance events (and especially since HLSStackController allows
 * insertion and removal anywhere in a stack)
 */
@protocol HLSStackControllerDelegate <NSObject>

@optional

/**
 * Called before pushedViewController is about to be pushed onto the stack. When called, pushedViewController does not
 * belong to [self viewControllers] yet, and the parent-child containment relationship has not been established.
 * The coveredViewController parameter is the view controller which is about to be covered (nil if none)
 */
- (void)stackController:(HLSStackController *)stackController
 willPushViewController:(UIViewController *)pushedViewController
    coverViewController:(UIViewController *)coveredViewController
               animated:(BOOL)animated;

/**
 * Called when a child view controller is about to be displayed. When called, viewController is always in
 * [self viewControllers], even if this event is the result of a push
 */
- (void)stackController:(HLSStackController *)stackController
 willShowViewController:(UIViewController *)viewController 
               animated:(BOOL)animated;

/**
 * Called when a child view controller has been displayed
 */
- (void)stackController:(HLSStackController *)stackController
  didShowViewController:(UIViewController *)viewController
               animated:(BOOL)animated;

/**
 * Called when a view controller has been pushed onto the stack. The coveredViewController parameter is the view
 * controller which was covered (nil if none)
 */
- (void)stackController:(HLSStackController *)stackController
  didPushViewController:(UIViewController *)pushedViewController
    coverViewController:(UIViewController *)coveredViewController
               animated:(BOOL)animated;

/**
 * Called when a view controller is about to be popped off the stack. The revealedViewController parameter is the
 * view controller which will be revealed (nil if none)
 */
- (void)stackController:(HLSStackController *)stackController
  willPopViewController:(UIViewController *)poppedViewController
   revealViewController:(UIViewController *)revealedViewController
               animated:(BOOL)animated;

/**
 * Called when a child view controller is about to be hidden
 */
- (void)stackController:(HLSStackController *)stackController
 willHideViewController:(UIViewController *)viewController
               animated:(BOOL)animated;

/**
 * Called when a view controller has been hidden. When called, viewController is still in [self viewControllers],
 * even if this event is received during a pop
 */
- (void)stackController:(HLSStackController *)stackController
  didHideViewController:(UIViewController *)viewController
               animated:(BOOL)animated;

/**
 * Called when a view controller has been popped off the stack. When called, poppedViewController has been removed
 * from [self viewControllers], and the parent-child containment relationship has been broken. The revealedViewController
 * parameter is the view controller which has been revealed (nil if none)
 */
- (void)stackController:(HLSStackController *)stackController
   didPopViewController:(UIViewController *)poppedViewController
   revealViewController:(UIViewController *)revealedViewController
               animated:(BOOL)animated;

@end

/**
 * User-defined runtime attributes exposed in the attributes inspector. Not meant to be set in code
 */
@interface HLSStackController (HLSInspectables)

/**
 * The maximum number of views loaded at any time in the stack
 */
@property (nonatomic, readonly, assign) IBInspectable NSUInteger capacity;

@end

@interface UIViewController (HLSStackController)

/**
 * Return the stack controller the view controller is inserted in, or nil if none.
 */
@property (nonatomic, readonly, weak) HLSStackController *stackController;

@end
