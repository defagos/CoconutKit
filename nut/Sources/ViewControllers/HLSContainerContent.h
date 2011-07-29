//
//  HLSContainerContent.h
//  nut
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSAnimation.h"
#import "HLSTransitionStyle.h"

/**
 * View controllers inserted into view controller containers exhibit common properties:
 *   - they belong to a container, which they must be able to identify, and they should not be inserted into several
 *     containers at the same time
 *   - they are displayed using some transition style, and might be stretched to fill the view when the container
 *     displayed them
 *   - a view controller's view must be created lazily at the time it is really required
 *   - it must be possible to pre-load a view controller container before it gets actually displayed
 *   - a view controller container must retain the view controllers it manages
 *   - a view controller's view properties should be restored when it is removed from a container. It might namely
 *     happen that a client caches this view controller for later reuse
 *   - in general, we want to restrict user interaction to the most recently view controller inserted into a container
 *   - we sometimes may want the view controller container to forward some properties of a contained view controller
 *     (e.g. title, navigation elements, toolbar, etc.) transparently
 * The HLSContainerContent class provides a way to ensure that those common properties can be fulfilled. It can be seen
 * as some kind of smart pointer object, taking ownership of a view controller inserted into a view controller
 * container.
 * 
 * When implementing a view controller container, use HLSContainerContent objects (retained by the container) to take 
 * ownership of a view controller when it is inserted, and simply release the HLSContainerContent object when the view 
 * controller gets removed from the container. When interacting with the view controller, use the HLSContainerContent
 * object as a proxy to help you guarantee that the common properties listed above are fulfulled.
 * 
 * Designated initializer: initWithViewController:containerController:transitionStyle:duration:
 */
@interface HLSContainerContent : NSObject {
@private
    UIViewController *m_viewController;
    BOOL m_addedToContainerView;
    UIView *m_blockingView;
    HLSTransitionStyle m_transitionStyle;
    NSTimeInterval m_duration;
    BOOL m_viewControllerContainerForwardingEnabled;
    HLSAnimation *m_cachedAnimation;
    CGRect m_originalViewFrame;
    CGFloat m_originalViewAlpha;
}

/**
 * Return the container in which the specified view controller has been inserted, nil if none
 */
+ (id)containerControllerForViewController:(UIViewController *)viewController;

/**
 * Initialize a container content manager object. Requires the view controller to be managed, the container in which
 * it is inserted, as well as the details of the transition with which it gets displayed. Use the reserved
 * kAnimationTransitionDefaultDuration duration for the default animation duration.
 * The view controller is retained.
 */
- (id)initWithViewController:(UIViewController *)viewController
         containerController:(id)containerController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration;

/**
 * Instantiate and add the view controller's view as subview of a view managed by the container controller (the view in 
 * which it displays its content). If blockInteraction is set to YES, a transparent stretchable view is inserted below 
 * the view controller's view to prevent interaction with other views below.
 * 
 * If the stretch boolean is set to YES, the view controller's view is stretched to fill the whole container view.
 * How this happens depends on the view controller's view autoresizing mask.
 *
 * Return YES if the view has been added, NO if it was already added.
 */
- (BOOL)addViewToContainerView:(UIView *)containerView 
                       stretch:(BOOL)stretch
              blockInteraction:(BOOL)blockInteraction;

/**
 * Same as addViewToContainerView:stretch:blockInteraction, but inserting the view below / above the view of another 
 * container content (which must of course belong to the same container)
 */
- (BOOL)insertViewIntoContainerView:(UIView *)containerView 
              belowContainerContent:(HLSContainerContent *)containerContent
                            stretch:(BOOL)stretch
                   blockInteraction:(BOOL)blockInteraction;
- (BOOL)insertViewIntoContainerView:(UIView *)containerView 
              aboveContainerContent:(HLSContainerContent *)containerContent
                            stretch:(BOOL)stretch
                   blockInteraction:(BOOL)blockInteraction;

/**
 * Remove the view controller's view from the container view
 */
- (void)removeViewFromContainerView;

/**
 * Return the view controller's view if added to a container view, nil otherwise. Does not perform lazy instantiation,
 * you must explicitly build the view when you need using addViewToContainerView:blockInteraction. This guarantees
 * that you create the view when you actually need it
 */
- (UIView *)view;

/**
 * Release all view and view-related resources. This also forwards the viewDidUnload message to the corresponding view
 * controller
 */
- (void)releaseViews;

/**
 * Create and cache an animation which displays the view controller using the defined transition style and duration. 
 * You can provide an array of other container contents (i.e. view controllers) to be hidden during the animation.
 * The commonFrame parameter is the frame where all animation take place (usually the view in which the container draws 
 * the view controllers it manages).
 *
 * The created animation is cached internally. This is required if you need to play the reverse animation when removing
 * the view controller from the container (reverseAnimation method). If the container view changes, the cached animation 
 * will most probably not be correct anymore. In such cases, you need to call this method again so that the animation
 * can be updated appropriately (e.g. during a rotation of the interface).
 *
 * The animation returned by this method has default properties. You usually want to tweak some of them (e.g. delegate, 
 * tag, etc.) right after creation.
 *
 * Note that there is an accessor for the reverse animation, but not for the cached animation. This was made on purpose.
 * The reason is that the animation must be created at the very last moment, when we are sure that the frame dimensions 
 * of the involved views are known. Having no access to the cached animation enforces this good practice by forcing the 
 * user to create the animation where she needs it.
 */
- (HLSAnimation *)createAnimationWithDisappearingContainerContents:(NSArray *)disappearingContainerContents
                                                       commonFrame:(CGRect)commonFrame;

/**
 * Return the reverse animation (if an animation was created), nil otherwise
 */
- (HLSAnimation *)reverseAnimation;

/**
 * The attached view controller. If you need to access its view, do not use the UIViewController view property
 * (this triggers lazy creation). Instead, use the addViewToContainerView:blockInteraction: method above when you
 * really need to instantiate the view, and the HLSContainerContent view accessor to access a view which you
 * created this way.
 */
@property (nonatomic, readonly, retain) UIViewController *viewController;

/**
 * If set to YES, the view controller properties (title, navigation controller, navigation elements, toolbar, etc.)
 * are forwarded through the container controller if this controller is a view controller. This makes it possible
 * to display those elements transparently higher up in the view controller hierarchy
 */
@property (nonatomic, assign, getter=isViewControllerContainerForwardingEnabled) BOOL viewControllerContainerForwardingEnabled;

@end
