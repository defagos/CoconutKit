//
//  HLSContainerGroupView.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A private class to manage group views in an HLSContainerStackView. Such a view has at most two subviews:
 *   - a mandatory front view displaying the content at a given level within the container stack view
 *     hierarchy
 *   - an optional group view display behind it
 * Refer to HLSContainerStackView for more information
 *
 * Designated initializer: initWithFrame:frontView:
 */
@interface HLSContainerGroupView : UIView

/**
 * Create a group view with the given view (mandatory) displayed at the front. If the view was previously
 * added to another view it is transferred to the group view
 */
- (id)initWithFrame:(CGRect)frame frontView:(UIView *)frontView;

/**
 * The front view
 */
@property (nonatomic, readonly, retain) UIView *frontView;

/**
 * Set the group view displayed behind the front view. If this view was already added to a superview,
 * it is transferred to the group view
 */
@property (nonatomic, retain) HLSContainerGroupView *backGroupView;

@end
