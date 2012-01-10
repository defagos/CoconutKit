//
//  UIWebView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIWebView+HLSExtensions.h"

#import "HLSLogger.h"

@implementation UIWebView (HLSExtensions)

#pragma mark Accessors and mutators

@dynamic scrollEnabled;

- (BOOL)isScrollEnabled
{
    for (id subview in self.subviews) {
        if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            return scrollView.scrollEnabled;
        }
    }
    
    HLSLoggerError(@"Scroll view not found in web view view hierarchy");
    return YES;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    for (id subview in self.subviews) {
        if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            scrollView.scrollEnabled = scrollEnabled;
            return;
        }
    }
    
    HLSLoggerError(@"Scroll view not found in web view view hierarchy");
}

#pragma mark Skinning

- (void)removeBackground
{
    // Make the web view transparent
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    // Remove the ugly background when scrolling
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            for (UIView *shadowView in [subview subviews]) {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    [shadowView setHidden:YES];
                }
            }
        }
    }
}

@end
