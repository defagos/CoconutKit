//
//  HLSContainerGroupView.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A private class to manage group views in an HLSContainerStackView. Such a view has at most two subviews,
 * one for the front content (mandatory and which cannot be changed), and another one for the back content 
 * (optional, and which can be changed).
 *
 * Each of those views is wrapped into a transparent wrapper view with alpha = 1.f, which must be used
 * for animations. This way:
 *   - animations can safely assume they animate views with alpha = 1.f. If we had animated the content
 *     views directly, which can have arbitrary alpha values, this would not have been possible
 *   - we can flatten views very easily by replacing the contents within the wrapper with a UIImageView
 *     of their content when appropriate. This can be especially useful to optimize animations, especially
 *     considered the CALayer shouldRasterize setting is only a hint and does not ensure rasterization
 *     will not be made several times during animation
 *
 * Designated initializer: initWithFrame:frontView:
 */
@interface HLSContainerGroupView : UIView {
@private
    UIView *m_savedFrontContentView;
    UIView *m_savedBackContentView;
    BOOL m_flattened;
}

/**
 * Create a group view with the given content view (mandatory) displayed at the front. If the view was 
 * previously added to another view it is transferred to the group view
 */
- (id)initWithFrame:(CGRect)frame frontContentView:(UIView *)frontContentView;

/**
 * The content view which has been inserted at the front into the group view. Do not use this view for 
 * animation purposes, use -frontView instead
 */
@property (nonatomic, readonly, retain) UIView *frontContentView;

/**
 * The front content view wrapper. If you want to animate the group view, animate this view (which has 
 * a guaranteed initial alpha of 1.f)
 */
@property (nonatomic, readonly, retain) UIView *frontView;

/**
 * Set the content view displayed in the back. If this view was already added to a superview, it is 
 * transferred to the group view
 */
@property (nonatomic, retain) UIView *backContentView;

/**
 * The back content view wrapper. If you want to animate the group view, animate this view (which has
 * a guaranteed initial alpha of 1.f)
 */
@property (nonatomic, readonly, retain) UIView *backView;

/**
 * Flatten the content view hierarchies as two images
 */
- (void)flatten;

/**
 * Unflatten the content view hierarchies
 */
- (void)unflatten;

@end
