//
//  UITextView+HLSCursorVisibility.m
//  CoconutKit
//
//  Created by Samuel Défago on 29.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UITextView+HLSCursorVisibility.h"

#import "HLSLogger.h"

// TODO: This functionality can be completely removed when CoconutKit requires iOS 8

@implementation UITextView (HLSCursorVisibility)

#pragma mark Class methods

+ (void)enableCursorVisibility
{
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        HLSLoggerInfo(@"Cursor fixes not needed since iOS 8");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewTextDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

#pragma mark Notification callbacks

+ (void)textViewTextDidChange:(NSNotification *)notification
{
    NSAssert([notification.object isKindOfClass:[UITextView class]], @"Expect a text view");
    
    // Locate the blinking cursor in the text view hierarchy, and ensure its stays visible
    UITextView *textView = notification.object;
    UIView *containerView = [textView.subviews firstObject];
    UIView *selectionView = [containerView.subviews firstObject];
    UIView *cursorView = [selectionView.subviews firstObject];
    
    static const CGFloat HLSCursorVisibilityMargin = 10.f;
    CGRect cursorViewFrameInTextView = [textView convertRect:cursorView.bounds fromView:cursorView];
    CGRect enlargedCursorViewFrameInTextView = CGRectMake(CGRectGetMinX(cursorViewFrameInTextView) - HLSCursorVisibilityMargin,
                                                          CGRectGetMinY(cursorViewFrameInTextView) - HLSCursorVisibilityMargin,
                                                          CGRectGetWidth(cursorViewFrameInTextView) + 2 * HLSCursorVisibilityMargin,
                                                          CGRectGetHeight(cursorViewFrameInTextView) + 2 * HLSCursorVisibilityMargin);
    
    [UIView animateWithDuration:0.25 animations:^{
        [textView scrollRectToVisible:enlargedCursorViewFrameInTextView animated:NO];
    }];
}

@end
