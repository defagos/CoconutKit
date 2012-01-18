//
//  UIWebView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIWebView+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "HLSLogger.h"

HLSLinkCategory(UIWebView_HLSExtensions)

@interface UIWebView (HLSExtensionsPrivate)

- (UIScrollView *)webScrollView;
- (NSArray *)shadowViews;

@end

@implementation UIWebView (HLSExtensions)

#pragma mark Accessors and mutators

- (void)makeBackgroundTransparent
{
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
}

@dynamic shadowHidden;

- (BOOL)isShadowHidden
{
    for (UIView *shadowView in [self shadowViews]) {
        if (! shadowView.hidden) {
            return YES;
        }
    }
    
    return NO;    
}

- (void)setShadowHidden:(BOOL)shadowHidden
{
    for (UIView *shadowView in [self shadowViews]) {
        shadowView.hidden = shadowHidden;
    }
}

@dynamic scrollEnabled;

- (BOOL)isScrollEnabled
{
    UIScrollView *scrollView = [self webScrollView];
    return scrollView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    UIScrollView *scrollView = [self webScrollView];
    scrollView.scrollEnabled = scrollEnabled;
}

@end

@implementation UIWebView (HLSExtensionsPrivate)

- (UIScrollView *)webScrollView
{
    for (id subview in self.subviews) {
        if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
            return (UIScrollView *)subview;
        }
    }
    
    HLSLoggerError(@"Scroll view not found in web view view hierarchy");
    return nil;
}

// The shadow is obtained by the superposition of several image views. Remove them
- (NSArray *)shadowViews
{
    NSMutableArray *shadowViews = [NSMutableArray array];
    UIScrollView *scrollView = [self webScrollView];
    for (UIView *subView in [scrollView subviews]) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [shadowViews addObject:subView];
        }
    }
    
    if ([shadowViews count] == 0) {
        HLSLoggerError(@"No shadow views found in web view view hierarchy");
    }
    return [NSArray arrayWithArray:shadowViews];
}

@end
