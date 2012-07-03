//
//  HLSApplicationPreLoader.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Simply call this macro somewhere in global scope to enable preloading. Good places are for example main.m 
 * or your application delegate .m file. Enabling preloading incurs a memory overhead you might not want to
 * pay if you do not need it, it is therefore disabled by default
 */
#define HLSEnableApplicationPreloading()                                                                  \
    __attribute__ ((constructor)) void HLSEnableApplicationPreloadingConstructor(void)                    \
    {                                                                                                     \
        [HLSApplicationPreLoader enable];                                                                 \
    }

/**
 * Collects the code which can be executed right after an application has started so that perceived performance can be
 * increased. For the moment only UIWebView is preloaded so that the time usually required when instantiating the first
 * web view can be reduced.
 */
@interface HLSApplicationPreLoader : NSObject <UIWebViewDelegate> {
@private
    UIApplication *_application;
}

/**
 * Call this method as soon as possible if you want to enable preloading. For simplicity you should use the
 * HLSEnableApplicationPreloading convenience macro instead
 */
+ (void)enable;

@end
