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
 * Keeps track of common properties needed to manage view controllers put in any kind of view controller
 * container. Provides a convenient management of view creation so that lazy creation can be explicitly
 * deferred to the time it is really required. A view controller remains bound to its container during
 * the lifetime of the HLSContainerContent object it is given to.
 * 
 * Designated initializer: initWithViewController:transitionStyle:duration:
 */
@interface HLSContainerContent : NSObject {
@private
    UIViewController *m_viewController;
    BOOL m_addedAsSubview;
    UIView *m_blockingView;
    HLSTransitionStyle m_transitionStyle;
    NSTimeInterval m_duration;
    HLSAnimation *m_cachedAnimation;
    CGRect m_originalViewFrame;
    CGFloat m_originalViewAlpha;
}

/**
 * Return the container in which the specified view controller has been inserted, nil if none
 */
+ (id)containerControllerForViewController:(UIViewController *)viewController;

/**
 * Provide all basic information needed for a view controller managed by a container, and which can be
 * given before a contained view controller is actually displayed. Most view controller containers
 * can namely be loaded before they are actually displayed
 * The view controller is retained. This is the usual semantics required for a container, and this
 * makes it unnecessary to keep additional strong references to contained view controllers once
 * you have strong references to corresponding HLSContainerContent objects (though this
 * might happen if view controllers have been cached for performance reasons)
 * The container controller is simply an id. In general it will be a UIViewController, but this might
 * not always be the case (e.g. UIPopoverController directly inherits from NSObject)
 */
- (id)initWithViewController:(UIViewController *)viewController
         containerController:(id)containerController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration;

/**
 * Add the view controller's view as subview of a specified view. If blockInteraction is set to YES, 
 * a transparent stretchable view is inserted below to prevent interaction with view below
 */
- (void)addViewToContainerView:(UIView *)containerView 
              blockInteraction:(BOOL)blockInteraction;

/**
 * Remove the view controller's view from its superview
 */
- (void)removeViewFromContainerView;

/**
 * Return the view controller's view if added to a view, nil otherwise. Does not perform lazy instantiation
 */
- (UIView *)view;

/**
 * Releases the view
 */
- (void)releaseView;

/**
 * Create and cache an animation which displays the view controller using the defined transition style and
 * duration. An array of container contents to be hidden (if any) can be provided. The commonFrame parameter
 * is the frame where all animation take place (usually the view in which the container draws the content
 * view controller's views).
 * The created animation is cached. If the container view changes, you usually will need to call this
 * method again so that the new container view frame dimensions are taken into account.
 * The animation returned by this method has default properties. You usually want to set some of them
 * (e.g. delegate, tag, etc.) right away.
 *
 * There is no accessor for the cached animation, and on purpose. The reason is that the animation must 
 * be created at the very last moment, when we are sure that the frame dimensions of the involved views are
 * known. Having no access to the cached animation enforces this good practice by forcing the user to
 * create the animation when she needs it.
 */
- (HLSAnimation *)createAnimationWithDisappearingContainerContents:(NSArray *)disappearingContainerContents
                                                       commonFrame:(CGRect)commonFrame;

/**
 * Return the reverse animation (if an animation was created), nil otherwise
 */
- (HLSAnimation *)reverseAnimation;

/**
 * The attached view controller. If you need to access its view, do not use the UIViewController view property
 * (which triggers lazy creation), use the view accessor above
 */
@property (nonatomic, readonly, retain) UIViewController *viewController;

/**
 * Return YES iff the contained view controller's view has been added as subview of some container view
 */
@property (nonatomic, readonly, assign, getter=isAddedAsSubview) BOOL addedAsSubview;

/**
 * Transition animation properties
 */
@property (nonatomic, readonly, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, readonly, assign) NSTimeInterval duration;

@end
