//
//  NSURLRequest+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 29.05.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "NSURLRequest+HLSExtensions.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_NSURLRequest__initWithURL_cachePolicy_timeoutInterval_Imp)(id, SEL, id, NSURLRequestCachePolicy, NSTimeInterval) = NULL;

// Swizzled method implementations
static id swizzled_NSURLRequest__initWithURL_cachePolicy_timeoutInterval_Imp(NSURLRequest *self, SEL _cmd, NSURL *url, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval);

@implementation NSURLRequest (HLSExtensions)

+ (void)load
{
    s_NSURLRequest__initWithURL_cachePolicy_timeoutInterval_Imp = (id (*)(id, SEL, id, NSURLRequestCachePolicy, NSTimeInterval))HLSSwizzleSelector(self, 
                                                                                                                                                   @selector(initWithURL:cachePolicy:timeoutInterval:),
                                                                                                                                                   (IMP)swizzled_NSURLRequest__initWithURL_cachePolicy_timeoutInterval_Imp);
}

@end

#pragma mark Swizzled method implementations

static id swizzled_NSURLRequest__initWithURL_cachePolicy_timeoutInterval_Imp(NSURLRequest *self, SEL _cmd, NSURL *url, NSURLRequestCachePolicy cachePolicy, NSTimeInterval timeoutInterval)
{
    // Warns about unimplemented NSURLRequest cache policies. See http://blackpixel.com/blog/1659/caching-and-nsurlconnection/
    self = (*s_NSURLRequest__initWithURL_cachePolicy_timeoutInterval_Imp)(self, _cmd, url, cachePolicy, timeoutInterval);
    if (self.cachePolicy != cachePolicy) {
        HLSLoggerWarn(@"The cache policy %d is not yet implemented and has been replaced with the cache policy %d", cachePolicy, self.cachePolicy);
    }
    return self;
}
