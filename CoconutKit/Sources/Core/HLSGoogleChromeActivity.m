//
//  HLSGoogleChromeActivity.m
//  CoconutKit
//
//  Created by Samuel Défago on 20.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSGoogleChromeActivity.h"

#import "NSBundle+HLSExtensions.h"
#import "UIImage+HLSExtensions.h"

// For more information, refer to the official documentation available at
//   https://developer.chrome.com/multidevice/ios/links

@implementation HLSGoogleChromeActivity

#pragma mark Class methods

+ (NSURL *)URLForActivityItems:(NSArray *)activityItems
{
    if ([activityItems count] != 1) {
        return nil;
    }
    
    id firstActivityItem = [activityItems firstObject];
    if (! [firstActivityItem isKindOfClass:[NSURL class]]) {
        return nil;
    }
    
    NSURL *URL = firstActivityItem;
    
    NSString *googleURLString = nil;
    if ([URL.scheme isEqualToString:@"http"]) {
        googleURLString = [NSString stringWithFormat:@"googlechrome:%@", URL.resourceSpecifier];
    }
    else if ([URL.scheme isEqualToString:@"https"]) {
        googleURLString = [NSString stringWithFormat:@"googlechromes:%@", URL.resourceSpecifier];
    }
    else {
        return nil;
    }
    
    return [NSURL URLWithString:googleURLString];
}

#pragma mark Overrides

- (NSString *)activityType
{
    return @"ch.defagos.CoconutKit.HLSGoogleChromeActivity";
}

- (NSString *)activityTitle
{
    return CoconutKitLocalizedString(@"Open in Chrome", nil);
}

- (UIImage *)activityImage
{
    return [UIImage coconutKitImageNamed:@"GoogleChromeActivityIcon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSURL *URL = [HLSGoogleChromeActivity URLForActivityItems:activityItems];
    if (! URL) {
        return NO;
    }
    return [[UIApplication sharedApplication] canOpenURL:URL];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSURL *URL = [HLSGoogleChromeActivity URLForActivityItems:activityItems];
    BOOL completed = [[UIApplication sharedApplication] openURL:URL];
    [self activityDidFinish:completed];
}

@end
