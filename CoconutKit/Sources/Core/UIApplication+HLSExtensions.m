//
//  UIApplication+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 08/11/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "UIApplication+HLSExtensions.h"

#import "HLSApplicationPreloader.h"
#import "HLSLogger.h"
#import <objc/runtime.h>

// Associated object keys
static void *s_applicationPreloaderKey = &s_applicationPreloaderKey;

@implementation UIApplication (HLSExtensions)

#pragma mark Preloading

- (void)preload
{
    HLSApplicationPreloader *applicationPreloader = objc_getAssociatedObject(self, s_applicationPreloaderKey);
    if (applicationPreloader) {
        HLSLoggerInfo(@"Preloading has already been made");
        return;
    }
    
    // The preloader object is retained since it might involve asychronous processes
    applicationPreloader = [[HLSApplicationPreloader alloc] initWithApplication:self];
    objc_setAssociatedObject(self, s_applicationPreloaderKey, applicationPreloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [applicationPreloader preload];
}

@end
