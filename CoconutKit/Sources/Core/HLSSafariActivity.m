//
//  HLSSafariActivity.m
//  CoconutKit
//
//  Created by Samuel Défago on 20.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSSafariActivity.h"

#import "NSBundle+HLSExtensions.h"
#import "UIImage+HLSExtensions.h"

@implementation HLSSafariActivity

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
    
    return firstActivityItem;
}

#pragma mark Overrides

- (NSString *)activityType
{
    return @"ch.defagos.CoconutKit.HLSSafariActivity";
}

- (NSString *)activityTitle
{
    return CoconutKitLocalizedString(@"Open in Safari", nil);
}

- (UIImage *)activityImage
{
    return [UIImage coconutKitImageNamed:@"SafariActivityIcon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSURL *URL = [HLSSafariActivity URLForActivityItems:activityItems];
    if (! URL) {
        return NO;
    }
    return [[UIApplication sharedApplication] canOpenURL:URL];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSURL *URL = [HLSSafariActivity URLForActivityItems:activityItems];
    BOOL completed = [[UIApplication sharedApplication] openURL:URL];
    [self activityDidFinish:completed];
}

@end
