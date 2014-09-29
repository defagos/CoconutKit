//
//  UIFont+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 1/17/13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UIFont+HLSExtensions.h"

#import "HLSLogger.h"

@implementation UIFont (HLSExtensions)

+ (BOOL)loadFontWithFileName:(NSString *)fileName inBundle:(NSBundle *)bundle
{
    if (! bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    NSString *fontFilePath = [bundle pathForResource:[fileName stringByDeletingPathExtension]
                                              ofType:[fileName pathExtension]];
    NSData *fontData = [NSData dataWithContentsOfFile:fontFilePath];
    return [self loadFontWithData:fontData];
}

+ (BOOL)loadFontWithData:(NSData *)data
{
    // See http://www.marco.org/2012/12/21/ios-dynamic-font-loading
    BOOL success = YES;
    CFErrorRef error = NULL;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        HLSLoggerError(@"Failed to register font, reason: %@", errorDescription);
        CFRelease(errorDescription);
        CFRelease(error);
        success = NO;
    }
    CFRelease(font);
    CFRelease(provider);
    
    return success;
}

@end
