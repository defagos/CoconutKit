//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIApplication+HLSExtensions.h"

#import "HLSApplicationPreloader.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"

// Associated object keys
static void *s_applicationPreloaderKey = &s_applicationPreloaderKey;

@implementation UIApplication (HLSExtensions)

#pragma mark Preloading

- (void)preload
{
    HLSApplicationPreloader *applicationPreloader = hls_getAssociatedObject(self, s_applicationPreloaderKey);
    if (applicationPreloader) {
        HLSLoggerInfo(@"Preloading has already been made");
        return;
    }
    
    // The preloader object is retained since it might involve asychronous processes
    applicationPreloader = [[HLSApplicationPreloader alloc] initWithApplication:self];
    hls_setAssociatedObject(self, s_applicationPreloaderKey, applicationPreloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [applicationPreloader preload];
}

@end
