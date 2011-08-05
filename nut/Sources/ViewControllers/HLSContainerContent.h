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
 *   - they are added and removed using some transition style, and might be stretched to fill the container's view 
 *     where they are displayed
 *   - a view controller's view should be created lazily at the time it is really required
 *   - it must be possible to pre-load a view controller container before it gets actually displayed
 *   - a view controller container must retain the view controllers it manages
 *   - a view controller's view properties should be restored when it is removed from a container. It might namely
 *     happen that a client caches this view controller for later reuse
 *   - in general, we want to restrict user interaction to the most recently view controller inserted into a container
 *   - we sometimes may want the view controller container to forward some properties of a contained view controller
 *     (e.g. title, navigation elements, toolbar, etc.) transparently
 *   - the UIViewController interfaceOrientation property (readonly) is only correctly set when the view controller
 *     is presented using built-in UIKit view controller containers. This has to be fixed when a view controller is
 *     presented using a custom container
 *   - the UIViewController parentViewController property returns the parent view controller if it is one of the
 *     buit-in containers (according to UIViewController documentation). But it makes sense to return a parent 
 *     when a view controller has been displayed by a custom container view controller. This does not match the 
 *     documentation, but as for the interfaceOrientation property, it seems that Apple was assuming that no other
 *     containers could exist besides built-in ones
 * The HLSContainerContent class provides a way to ensure that those common properties can be easily implemented. It 
 * can be seen as some kind of smart pointer object, taking ownership of a view controller when inserted into a view 
 * controller container.
 * 
 * When implementing a view controller container, use HLSContainerContent objects (retained by the container) to take 
 * ownership of a view controller when it is inserted, and simply release the HLSContainerContent object when the view 
 * controller gets removed from the container. When interacting with the view controller, use the HLSContainerContent
 * object as a proxy to help you guarantee that the common properties listed above are fulfilled.
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
 * Same as above, using the default transition animation duration
 */
- (id)initWithViewController:(UIViewController *)viewController
         containerController:(id)containerController
             transitionStyle:(HLSTransitionStyle)transitionStyle;

/**
 * Instantiate and add the view controller's view as subview of a view managed by the container controller (the view in 
 * which it displays its content). If blockInteraction is set to YES, a transparent stretchable view is inserted below 
 * the view controller's view to prevent interaction with other views below.
 *
 * Some view controller containers might display several view controllers simultaneously in the same content view. In
 * such cases, the corresponding stack of container content objects can be provided (the receiver must be part of it).
 * This allows the view to be inserted at the proper location in the view hierarchy. If this parameter is nil, the
 * view is simply added on top.
 * The first element in the stack array is interpreted as the bottommost one.
 * 
 * If the stretch boolean is set to YES, the view controller's view is stretched to fill the whole container view.
 * How this happens depends on the view controller's view autoresizing mask.
 *
 * Return YES if the view has been added, NO if it was already added.
 */
- (BOOL)addViewToContainerView:(UIView *)containerView 
                       stretch:(BOOL)stretch
              blockInteraction:(BOOL)blockInteraction
       inContainerContentStack:(NSArray *)containerContentStack;

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
 * Create the animation needed to display the view controller's view in the container view. If the receiver is part
 * of a container content stack, the stack can be supplied as parameter so that the animation can be tailored
 * accordingly.
 *
 * The first element in the stack array is interpreted as the bottommost one.
 *
 * The animation returned by this method has default properties. You usually want to tweak some of them (e.g. delegate, 
 * tag, etc.) right after creation.
 */
- (HLSAnimation *)animationWithContainerContentStack:(NSArray *)containerContentStack
                                       containerView:(UIView *)containerView;

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
