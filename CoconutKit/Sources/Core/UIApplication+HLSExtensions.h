//
//  UIApplication+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 08/11/13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

@interface UIApplication (HLSExtensions)

/**
 * Call this method from your application delegate implementation, when your application has been started (in general
 * in -application:didFinishLaunchingWithOptions:), to preload elements at the expense of memory (for the moment,
 * only UIWebView preloading is made)
 */
- (void)preload;

@end
