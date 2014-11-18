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
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGFontRef fontRef = CGFontCreateWithDataProvider(providerRef);
    if (! fontRef) {
        HLSLoggerError(@"Could not create font");
        CFRelease(providerRef);
        return NO;
    }
    
    BOOL result = YES;
    
    CFErrorRef errorRef = NULL;
    if (! CTFontManagerRegisterGraphicsFont(fontRef, &errorRef)) {
        CFStringRef errorDescriptionStringRef = CFErrorCopyDescription(errorRef);
        HLSLoggerError(@"Failed to register font, reason: %@", errorDescriptionStringRef);
        CFRelease(errorDescriptionStringRef);
        CFRelease(errorRef);
        result = NO;
    }
    
    CFRelease(fontRef);
    CFRelease(providerRef);
    return result;
}

@end
