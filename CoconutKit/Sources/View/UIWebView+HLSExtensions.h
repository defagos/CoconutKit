//
//  UIWebView+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface UIWebView (HLSExtensions)

/**
 * Return the scroll view embedded into the web view
 *
 * This property is available starting with iOS 5 (in which case its implementation will be used)
 */
@property (nonatomic, readonly, retain) UIScrollView *scrollView;

/**
 * Make the web view background transparent
 */
- (void)makeBackgroundTransparent;

/**
 * If set to YES, remove the shadow seen behind the web view when it is scrolled to the top of the bottom.
 * Default value is NO
 */
@property (nonatomic, assign, getter=isShadowHidden) BOOL shadowHidden;

@end
