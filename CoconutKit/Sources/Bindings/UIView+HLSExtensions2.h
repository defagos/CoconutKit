//
//  UIView+HLSExtensions2.h
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

// TODO: Move to UIView+HLSExtensions.h
@interface UIView (HLSExtensions2)

/**
 * Return the view controller from which the receiver is the view, nil otherwise
 */
@property (nonatomic, readonly, weak) UIViewController *viewController;

/**
 * Return the nearest view controller which displays the view, nil if none
 */
@property (nonatomic, readonly, weak) UIViewController *nearestViewController;

@end
