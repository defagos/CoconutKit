//
//  HLSStackController.h
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSTransitionStyle.h"
#import "HLSViewController.h"

// Forward declarations
@protocol HLSStackControllerDelegate;

/**
 * TODO: Better documentation
 * About view lifecycle events: When a view controller gets covered by pushing another one, it will receive the viewWill
 * and viewDidDisappear events, even if it stays visible because the newly pushed view controller is transparent. Dealing
 * with transparency would have been way too difficult (you have to consider all superimposed views to know if some
 * view controller's view down the stack is partially visible), and in general we want the covered view controller
 * to behave as if it disappeared (though it still stays visible).
 *
 * Designated initializer: initWithRootCiewController:
 */
@interface HLSStackController : HLSViewController {
@private
    NSArray *m_viewControllers;                     // contains UIViewController objects. The last one is the top one
    BOOL m_adjustingContent;
    BOOL m_viewsAdded;
    id<HLSStackControllerDelegate> m_delegate;
}

/**
 * Create a new stack controller with the specified view controller as root. This view controller can neither be animated 
 * when installed, nor removed
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;

/**
 * Push a view controller onto the stack without animation
 */
- (void)pushViewController:(UIViewController *)viewController;

/**
 * Push a view controller onto the stack using one of the built-in transition styles. The transition duration is set by 
 * the animation itself
 */
- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Same as pushViewController:withTransitionStyle:, but the transition duration can be overridden (the duration will be 
 * evenly distributed on the animation steps composing the animation)
 */
- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration;

/**
 * Push a view controller onto the stack. The transition can be animated by providing an NSArray of HLSTwoViewAnimationStepDefinition 
 * objects (first view = pushed view controller's view, second view = previous top view controller's view).
 */
- (void)pushViewController:(UIViewController *)viewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions;

/**
 * Remove the top view controller from the stack. The same animation as when it was pushed onto the stack will be played.
 * The root view controller cannot be popped
 */
- (UIViewController *)popViewController;

/**
 * Remove the top view controller from the stack using one of the built-in transition styles. The transition duration
 * is set by the animation itself
 */
- (UIViewController *)popViewControllerWithTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Same as popViewControllerWithTransitionStyle:, but the transition duration can be overridden (the duration will be 
 * evenly distributed on the animation steps composing the animation)
 */
- (UIViewController *)popViewControllerWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                                                  duration:(NSTimeInterval)duration;

/**
 * Remove the top view controller from the stack. The transition can be animated by providing an NSArray of HLSTwoViewAnimationStepDefinition 
 * objects (first view = popped view controller's view, second view = view of the view controller below it).
 */
- (UIViewController *)popViewControllerWithTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions;

/**
 * Return the view controller currently on top
 */
- (UIViewController *)topViewController;

/**
 * The view controllers in the stack. The first one is the root view controller, the last one the top one
 */
@property (nonatomic, readonly, retain) NSArray *viewControllers;

/**
 * If set to YES, the content view controller's view frames are automatically adjusted to match the view bounds. The resizing
 * behavior still depends on the autoresizing behavior of the content views, though (for example, if a content view is able 
 * to stretch  in both directions, it will fill the entire view). If set to NO, the content view is used as is.
 * Default value is NO.
 */
@property (nonatomic, assign, getter=isAdjustingContent) BOOL adjustingContent;

@property (nonatomic, assign) id<HLSStackControllerDelegate> delegate;

@end

@protocol HLSStackControllerDelegate <NSObject>

@optional

- (void)stackController:(HLSStackController *)stackController 
 willShowViewController:(UIViewController *)viewController 
               animated:(BOOL)animated;
- (void)stackController:(HLSStackController *)stackController
  didShowViewController:(UIViewController *)viewController
               animated:(BOOL)animated;

@end

@interface UIViewController (HLSStackController)

- (HLSStackController *)stackController;

@end
