//
//  HLSApplicationPreloader.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.07.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * Collects the code which can be executed right after an application has started so that perceived performance can be
 * increased. For the moment only UIWebView is preloaded so that the time usually required when instantiating the first
 * web view is reduced
 */
@interface HLSApplicationPreloader : NSObject <UIWebViewDelegate>

/**
 * Initialize the preloader. An application is required
 */
- (instancetype)initWithApplication:(UIApplication *)application NS_DESIGNATED_INITIALIZER;

/**
 * Execute preloading
 */
- (void)preload;

@end

@interface HLSApplicationPreloader (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
