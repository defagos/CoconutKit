//
//  UIWebView+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface UIWebView (HLSExtensions)

/**
 * The web view exhibits a gray background by default. This method removes it
 */
- (void)removeBackground;

@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;

@end
