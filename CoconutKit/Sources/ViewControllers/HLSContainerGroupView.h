//
//  HLSContainerGroupView.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A private class to manage group views in an HLSContainerStackView. Such a view has at most two subviews:
 *   - a mandatory content view displaying the content at a given level within the container stack view
 *     hierarchy. This view is wrapped into a transparent view (frontView) having alpha = 1.f, and which 
 *     must be used for animations. This way animations can safely assume they are animating views with
 *     initial alpha = 1.f, which could not be guaranteed if the content view was directly animated (view 
 *     controller's views can have an arbitrary alpha). This relieves us from extra bookkeeping work
 *   - an optional group view displayed behind it
 * Refer to HLSContainerStackView for more information
 *
 * Designated initializer: initWithFrame:frontView:
 */
@interface HLSContainerGroupView : UIView

/**
 * Create a group view with the given content view (mandatory) displayed at the front. If the view was 
 * previously added to another view it is transferred to the group view
 */
- (id)initWithFrame:(CGRect)frame contentView:(UIView *)contentView;

/**
 * The content view which has been inserted into the group view. Do not use this view for animation purposes
 */
@property (nonatomic, readonly, retain) UIView *contentView;

/**
 * The content view wrapper. If you want to animate the group view, animate this view (which has initial
 * alpha = 1.f)
 */
@property (nonatomic, readonly, retain) UIView *frontView;

/**
 * Set the group view displayed behind the front view. If this view was already added to a superview,
 * it is transferred to the group view
 */
@property (nonatomic, retain) HLSContainerGroupView *backGroupView;

@end
