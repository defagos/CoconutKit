//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A private class to manage group views in an HLSContainerStackView. Such a view has at most two subviews,
 * one for the front content (mandatory and which cannot be changed), and another one for the back content 
 * (optional, and which can be changed).
 *
 * Each of those views is wrapped into a transparent wrapper view with alpha = 1.f, which must be used
 * for animations. This way animations can safely assume they animate views with alpha = 1.f. If we had 
 * animated the content views directly, which can have arbitrary alpha values, this would not have been 
 * possible. Moreover, this additional wrapping yields smoother animations (I cannot explain why, though.
 * Probably blending can be performed more efficiently)
 */
@interface HLSContainerGroupView : UIView

/**
 * Create a group view with the given content view (mandatory) displayed at the front. If the view was 
 * previously added to another view it is transferred to the group view
 */
- (instancetype)initWithFrame:(CGRect)frame frontContentView:(UIView *)frontContentView NS_DESIGNATED_INITIALIZER;

/**
 * The content view which has been inserted at the front into the group view. Do not use this view for 
 * animation purposes, use -frontView instead
 */
@property (nonatomic, readonly) UIView *frontContentView;

/**
 * The front content view wrapper. If you want to animate the group view, animate this view (which has 
 * a guaranteed initial alpha of 1.f)
 */
@property (nonatomic, readonly) UIView *frontView;

/**
 * Set the content view displayed in the back. If this view was already added to a superview, it is 
 * transferred to the group view
 */
@property (nonatomic, nullable) UIView *backContentView;

/**
 * The back content view wrapper. If you want to animate the group view, animate this view (which has
 * a guaranteed initial alpha of 1.f)
 */
@property (nonatomic, readonly, nullable) UIView *backView;

@end

@interface HLSContainerGroupView (UnavailableMethods)

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
