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

#import <objc/runtime.h>

static UIScrollView *scrollView_Imp(UIWebView *self, SEL _cmd);

HLSLinkCategory(UIWebView_HLSExtensions)

@interface UIWebView (HLSExtensionsPrivate)

- (NSArray *)shadowViews;

@end

@implementation UIWebView (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (! class_getInstanceMethod(self, @selector(scrollView))) {
        NSString *types = [NSString stringWithFormat:@"%s%s%s", @encode(UIScrollView *), @encode(id), @encode(SEL)];
        class_addMethod(self, NSSelectorFromString(@"scrollView"), (IMP)scrollView_Imp, [types cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    [pool drain];
}

#pragma mark Accessors and mutators

@dynamic scrollView;

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

@end

@implementation UIWebView (HLSExtensionsPrivate)

// The shadow is obtained by the superposition of several image views. Remove them
- (NSArray *)shadowViews
{
    NSMutableArray *shadowViews = [NSMutableArray array];
    for (UIView *subView in [self.scrollView subviews]) {
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

#pragma mark Method implementation functions

static UIScrollView *scrollView_Imp(UIWebView *self, SEL _cmd)
{
    for (id subview in self.subviews) {
        if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
            return (UIScrollView *)subview;
        }
    }
    
    HLSLoggerError(@"Scroll view not found in web view view hierarchy");
    return nil;
}
