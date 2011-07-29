//
//  HLSStackController.h
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSReloadable.h"
#import "HLSTransitionStyle.h"
#import "HLSViewController.h"

// Standard view depths
extern const NSUInteger kStackMinimalViewDepth;
extern const NSUInteger kStackDefaultViewDepth;
extern const NSUInteger kStackUnlimitedViewDepth;

// Forward declarations
@protocol HLSStackControllerDelegate;

/**
 * We often need to manage a stack of view controllers. Usually, we use a navigation controller, but there is no way
 * to use custom animations, and those look quite ugly on the iPad. Sometimes, we also want to show view controllers
 * modally, but often the usual presentModalViewController:animated: method of UIViewController is too limited (modal
 * sheets on the iPad have pre-defined sizes, and when displaying full screen the view below disappears, which prevents
 * from displaying transparent modal windows.
 *
 * To circumvent those problems, HLSStackController provides a generic way to deal with a view controller stack. It can
 * be applied a richer set of transition animations. HLSStackController is used as is and is not meant to be subclassed.
 *
 * This view controller container guarantees correct view lifecycle and rotation event propagation to the view controllers
 * it manages. Note that when a view controller gets pushed onto the stack, the view controller below will get the
 * viewWillDisappear: and viewDidDisappear: events, even if it stays visible through transparency (the same holds for
 * the viewWillAppear: and viewDidAppear: events when the view controller on top gets popped).
 * This decision was made because it would have been extremely difficult and costly to look at all view controller's 
 * views in the stack to find those which are really visible (this would have required to find the intersections of all 
 * view and subview rectangles, cumulating alphas to find which parts of the view stack are visible and which aren't).
 *
 * This view controller uses the smoother 1-step rotation available from iOS3. You cannot use the 2-step rotation
 * for view controllers you pushed in it (it will be ignored, see UIViewController documentation). The 2-step rotation
 * is deprecated starting with iOS 5, you should not use it anymore anyway.
 *
 * Since a stack controller can manage many view controller's views, and since in general only the first few top ones
 * need to be visible, it would be a waste of resources to keep all views loaded at any time. The concept of a "view
 * depth" has thus been introduced. By default, the view depth is set to 2, which means that the container guarantees
 * that the two top view controller's views are loaded at any time. The controller unloads the view controller's views
 * below in the stack. You can set this depth to 1 if all your view controllers are opaque, or you can increase the 
 * depth if more layers of transparency are needed (a value of 2 is what you typically need if you need to push
 * a transparent view controller in the stack)
 *
 * TODO: This class currently does not support view controllers implementing the HLSOrientationCloner protocol
 *
 * Designated initializer: initWithRootViewController:visibilityDepth:
 */
@interface HLSStackController : HLSViewController <HLSReloadable> {
@private
    NSMutableArray *m_containerContentStack;                    // Contains HLSContainerContent objects
    NSUInteger m_viewDepth;
    BOOL m_stretchingContent;                                   // Automatically stretch view controller's views to match
                                                                // container view frame?
    BOOL m_animatingTransition;                                 // Is a transition animation running?
    id<HLSStackControllerDelegate> m_delegate;
}

/**
 * Create a new stack controller with the specified view controller as root. This view controller cannot be animated when 
 * installed, and can neither be replaced, nor removed. Typical view depth constants are available at the top of this file
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController viewDepth:(NSUInteger)viewDepth;

/**
 * Create a new stack controller with the specified view controller as root. This view controller cannot be animated when 
 * installed, and can neither be replaced, nor removed. The standard view depth (2) is applied
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
 * sets the pop animation which will get played when the view controller is later removed)
 */
- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Same as pushViewController:withTransitionStyle:, but the transition duration can be overridden (the duration will be 
 * evenly distributed on the animation steps composing the animation so that the animation rhythm stays the same). Use 
 * the reserved kAnimationTransitionDefaultDuration value as duration to get the default transition duration (same 
 * result as the method above)
 * This method can also be called before the stack controller is displayed (the animation does not get played, but this
 * sets the pop animation which will get played when the view controller is later removed)
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
 * If set to YES, the view controller's view frames are automatically adjusted to match the container view bounds. The 
 * resizing behavior still depends on the autoresizing behavior of the content views, though (for example, if a content 
 * view is able to stretch in both directions, it will fill the entire container view). If set to NO, the content view 
 * is used as is. 
 * Changing this property only affect view controllers which are displayed afterwards. In general, this property is set 
 * right after the stack controller is instantiated and never changed.
 *
 * Default value is NO.
 */
@property (nonatomic, assign, getter=isStretchingContent) BOOL stretchingContent;

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
