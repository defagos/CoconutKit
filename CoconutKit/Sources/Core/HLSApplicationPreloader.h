//
//  HLSApplicationPreloader.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Collects the code which can be executed right after an application has started so that perceived performance can be
 * increased. For the moment only UIWebView is preloaded so that the time usually required when instantiating the first
 * web view is reduced
 */
@interface HLSApplicationPreloader : NSObject <UIWebViewDelegate> {
@private
    UIApplication *_application;
}

/**
 * Call this method as soon as possible if you want to enable preloading. For simplicity you should use the
 * HLSEnableApplicationPreloading convenience macro instead (see HLSOptionalFeatures.h)
 */
+ (void)enable;

@end
