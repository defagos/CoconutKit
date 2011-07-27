//
//  HLSContainedViewControllerInfo.h
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
 * deferred to the time it is really required.
 * 
 * Designated initializer: initWithViewController:transitionStyle:duration:
 */
@interface HLSContainedViewControllerInfo : NSObject {
@private
    UIViewController *m_viewController;
    BOOL m_addedAsSubview;
    UIView *m_blockingView;
    HLSTransitionStyle m_transitionStyle;
    NSTimeInterval m_duration;
    CGRect m_originalViewFrame;
    CGFloat m_originalViewAlpha;
}

/**
 * Provide all basic information needed for a view controller managed by a container, and which can be
 * given before a contained view controller is actually displayed. Most view controller containers
 * can namely be loaded before they are actually displayed
 * The view controller is retained. This is the usual semantics required for a container, and this
 * makes it unnecessary to keep additional strong references to contained view controllers once
 * you have strong references to corresponding HLSContainedViewControllerInfo objects (though this
 * might happen if view controllers have been cached for performance reasons)
 */
- (id)initWithViewController:(UIViewController *)viewController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration;

/**
 * Add the view controller's view as subview of a specified view. If blockInteraction is set to YES, 
 * a transparent stretchable view is inserted below to prevent interaction with view below
 */
- (void)addContainedViewToContainerView:(UIView *)containerView 
                       blockInteraction:(BOOL)blockInteraction;

/**
 * Remove the view controller's view from its superview
 */
- (void)removeContainedViewFromSuperview;

/**
 * Return the view controller's view if added to a view, nil otherwise. Does not perform lazy instantiation
 */
- (UIView *)containedView;

/**
 * Releases the view
 */
- (void)releaseContainedView;

/**
 * The attached view controller. If you need to access its view, do not use the UIViewController view property
 * (which triggers lazy creation), use the containedView accessor above
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
