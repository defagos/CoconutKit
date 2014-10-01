//
//  HLSContainerStackView.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSContainerGroupView.h"

// Forward declarations
@protocol HLSContainerStackViewDelegate;

/**
 * Private class for managing the view hierarchy of an HLSContainerStack (the generic class which CoconutKit provides 
 * to implement custom view controller containers, and upon which CoconutKit containers are themselves built). 
 *
 * When inserting a view controller's view into an existing stack of view controller's views using some kind of
 * transition animation, we namely want the following to occur correctly:
 *   - the views of the view controllers below the one which gets inserted (and which might not all be loaded since
 *     an HLSContainerStack is able to unload invisible views to save memory) must all be applied the same
 *     disappearance animation
 *   - the alpha of any view in the stack must consistently take into account the alphas of all views above
 *     (by multipliying this alpha with the product of all above alphas)
 *
 * The simplest view hiearchy we may want to use is a flat one, i.e. all view controller's views are added as
 * subviews of the container view:
 *
 *       container view
 *             |
 *             |-- child view 0 (bottom)
 *             |
 *             |-- child view 1
 *             |
 *             |-- child view 2
 *             |
 *             .
 *             .
 *             |-- child view N-2
 *             |
 *             |-- child view N-1
 *             |
 *             \-- child view N (top)
 *
 * This makes view insertion and removal easy, but at the cost of extra bookkeeping work to calculate alphas
 * correctly and to apply animations when a view controller gets inserted or removed:
 *   - when a view controller is inserted, all loaded views below must be animated in the same way
 *   - the products of all loaded view alphas must be computed and applied manually
 * Wouldn't it be nice if we could get all this tricky stuff for free at the cost of slightly more complicated insertion
 * and removal operations? Well, this is exactly the purpose of HLSContainerStackView.
 * 
 * When thinking about the best way how to solve the above issues, you may realize that each view controller insertion
 * actually performs two kinds of changes on views:
 *   - a change is applied to the view which is inserted ("appearing" view)
 *   - a common change is applied to the views below ("disappearing" views)
 * Instead of a flat view hierarchy, we introduce a view hiearchy which will ensure collective animation of disappearing
 * views, and automatic calculation of the alpha at each level. This is achieved by grouping views so that at most
 * two subviews coexist at each level of the container view hierarchy. When inserting a new view controller's view,
 * the disappearance animation is simply applied on the bottom subview, which guarantees that all changes are consistently
 * applied to all its sub-view hierarchy (thanks to UIKit which automatically moves subviews collectively and calculate 
 * their alpha based on their parent view alphas):
 *
 *       container view
 *         |
 *         \- HLSContainerStackView
 *              |
 *              \-- group view N (HLSContainerGroupView)
 *                    |
 *                    |-- group view N-1 (HLSContainerGroupView)
 *                    |     |
 *                    |     |-- group view N-2 (HLSContainerGroupView)
 *                    |     |     |
 *                    |     |     |-- group view N-2 (HLSContainerGroupView)
 *                    |     |     |     |
 *                    |     |     |     .
 *                    |     |     |     .
 *                    |     |     |     |--..-- group view 2 (HLSContainerGroupView)
 *                    |     |     |     |         |
 *                    |     |     |     |         |-- group view 1 (HLSContainerGroupView)
 *                    |     |     |     .         |     |
 *                    |     |     |     .         |     \-- child view 0 (bottom)
 *                    |     |     |               |
 *                    |     |     |               \-- child view 1
 *                    |     |     |
 *                    |     |     |
 *                    |     |     |
 *                    |     |     |
 *                    |     |     |
 *                    |     |     |
 *                    |     |     |
 *                    |     |     |
 *                    |     |     \-- child view N-2
 *                    |     |
 *                    |     \-- child view N-1
 *                    |
 *                    \-- child view N (top)
 *
 *
 * The HLSContainerStackView class simply implements the above view hierarchy and provides methods for easy insertion
 * and removal of views.
 */
@interface HLSContainerStackView : UIView

/**
 * Create the stack view
 */
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

/**
 * Return the array of views used to display content (child views), from the bottommost to the topmost one
 */
- (NSArray *)contentViews;
 
/**
 * Insert a view at a given index. If index is [contentViews count], then the view is added at the top
 */
- (void)insertContentView:(UIView *)contentView atIndex:(NSInteger)index;

/**
 * Remove a given content view
 */
- (void)removeContentView:(UIView *)contentView;

/**
 * Return the group view containing a given view as topmost subview. Return nil if not found
 */
- (HLSContainerGroupView *)groupViewForContentView:(UIView *)contentView;

@property (nonatomic, weak) id<HLSContainerStackViewDelegate> delegate;

@end

@protocol HLSContainerStackViewDelegate <NSObject>

/**
 * Called right before the container view frame changes
 */
- (void)containerStackViewWillChangeFrame:(HLSContainerStackView *)containerStackView;

/**
 * Called right after the container view frame changed
 */
- (void)containerStackViewDidChangeFrame:(HLSContainerStackView *)containerStackView;

@end
