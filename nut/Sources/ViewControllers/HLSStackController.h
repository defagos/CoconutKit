//
//  HLSStackController.h
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSReloadable.h"
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
 * Not meant to be subclassed
 *
 * Question: Not meant to be subclassed => which size? Probably largest size available by default and rely on the parent 
 *           view controller's behavior (should be able to automatically resize its child view controller's views properly).
 *           This is the case for UINavigationController, UITabBarController, HLSPlaceholderViewController
 *
 * Designated initializer: initWithRootCiewController:
 */
@interface HLSStackController : HLSViewController <HLSReloadable, HLSAnimationDelegate> {
@private
    NSMutableArray *m_viewControllerStack;                      // contains UIViewController objects. The last one is the top one
    NSMutableArray *m_addedAsSubviewFlagStack;                  // contains NSNumber (BOOL) objects flagging whether a view controller's 
                                                                // view has been added as subview. Same order as m_viewControllers
    NSMutableArray *m_twoViewAnimationStepDefinitionsStack;     // contains NSArray objects (of HLSTwoViewAnimationStepDefinition objects)
                                                                // describing the animation steps used when pushing views ([NSNull null]
                                                                // if none)
    NSMutableArray *m_originalViewFrameStack;                   // original frames of the view controller's views
    BOOL m_stretchingContent;
    id<HLSStackControllerDelegate> m_delegate;
}

/**
 * Create a new stack controller with the specified view controller as root. This view controller can neither be animated 
 * when installed, nor removed
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
 * This method can also be called before the stack controller is displayed
 */
- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Same as pushViewController:withTransitionStyle:, but the transition duration can be overridden (the duration will be 
 * evenly distributed on the animation steps composing the animation)
 * This method can also be called before the stack controller is displayed
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
 * If set to YES, the content view controller's view frames are automatically adjusted to match the container view bounds. The resizing
 * behavior still depends on the autoresizing behavior of the content views, though (for example, if a content view is able to stretch 
 * in both directions, it will fill the entire container view). If set to NO, the content view is used as is.
 * Default value is NO.
 */
@property (nonatomic, assign, getter=isStretchingContent) BOOL stretchingContent;

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

@property (nonatomic, readonly, assign) HLSStackController *stackController;

@end
