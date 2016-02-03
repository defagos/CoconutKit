//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIApplication (HLSExtensions)

/**
 * Call this method from your application delegate implementation, when your application has been started (in general
 * in -application:didFinishLaunchingWithOptions:), to preload elements at the expense of memory (for the moment,
 * only UIWebView preloading is made)
 */
- (void)preload;

@end
