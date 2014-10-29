//
//  UITextView+HLSCursorVisibility.m
//  CoconutKit
//
//  Created by Samuel Défago on 29.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UITextView+HLSCursorVisibility.h"

#import "HLSLogger.h"
#import "UIView+HLSExtensions.h"
#import "UIWindow+HLSExtensions.h"

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
                                             selector:@selector(textViewDidChangeCursorPosition:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

#pragma mark Visibility

- (void)scrollCursorToVisible
{
    // Locate the first view leaf. Can be the blinking cursor or part of the selection view. This trick works because the possible
    // view hierarchies are stable, this trick namely only targets iOS 7
    UIView *cursorView = self;
    while ([cursorView.subviews count] != 0) {
        cursorView = [cursorView.subviews firstObject];
    }
    
    static const CGFloat HLSCursorVisibilityMargin = 10.f;
    CGRect cursorViewFrameInTextView = [self convertRect:cursorView.bounds fromView:cursorView];
    CGRect enlargedCursorViewFrameInTextView = CGRectMake(CGRectGetMinX(cursorViewFrameInTextView) - HLSCursorVisibilityMargin,
                                                          CGRectGetMinY(cursorViewFrameInTextView) - HLSCursorVisibilityMargin,
                                                          CGRectGetWidth(cursorViewFrameInTextView) + 2 * HLSCursorVisibilityMargin,
                                                          CGRectGetHeight(cursorViewFrameInTextView) + 2 * HLSCursorVisibilityMargin);
    
    [UIView animateWithDuration:0.25 animations:^{
        [self scrollRectToVisible:enlargedCursorViewFrameInTextView animated:NO];
    }];
}

#pragma mark Notification callbacks

+ (void)textViewDidChangeCursorPosition:(NSNotification *)notification
{
    NSAssert([notification.object isKindOfClass:[UITextView class]], @"Expect a text view");
    
    // The cursor position is updated after this notification is changed. Wait a little bit to have the most
    // recent cursor position
    [notification.object performSelector:@selector(scrollCursorToVisible) withObject:nil afterDelay:0.05];
}

+ (void)keyboardDidShow:(NSNotification *)notification
{
    UIView *firstResponderView = [[UIApplication sharedApplication].keyWindow.activeViewController.view firstResponderView];
    if ([firstResponderView isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)firstResponderView;
        [textView scrollCursorToVisible];
    }
}

@end
