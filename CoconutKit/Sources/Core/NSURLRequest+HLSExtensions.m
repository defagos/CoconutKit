//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSURLRequest+HLSExtensions.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_initWithURL_cachePolicy_timeoutInterval)(id, SEL, id, NSURLRequestCachePolicy, NSTimeInterval) = NULL;

// Swizzled method implementations
static id swizzle_initWithURL_cachePolicy_timeoutInterval(NSURLRequest *self, SEL _cmd, NSURL *url, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval);

@implementation NSURLRequest (HLSExtensions)

+ (void)load
{
    HLSSwizzleSelector(self, @selector(initWithURL:cachePolicy:timeoutInterval:), swizzle_initWithURL_cachePolicy_timeoutInterval, &s_initWithURL_cachePolicy_timeoutInterval);
}

@end

#pragma mark Swizzled method implementations

static id swizzle_initWithURL_cachePolicy_timeoutInterval(NSURLRequest *self, SEL _cmd, NSURL *url, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval)
{
    // Warns about unimplemented NSURLRequest cache policies. See http://blackpixel.com/blog/1659/caching-and-nsurlconnection/
    self = s_initWithURL_cachePolicy_timeoutInterval(self, _cmd, url, cachePolicy, timeoutInterval);
    if (self.cachePolicy != cachePolicy) {
        HLSLoggerWarn(@"The cache policy %lu is not yet implemented and has been replaced with the cache policy %lu", (unsigned long)cachePolicy, (unsigned long)self.cachePolicy);
    }
    return self;
}
