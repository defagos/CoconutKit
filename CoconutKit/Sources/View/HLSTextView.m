//
//  HLSTextView.m
//  CoconutKit
//
//  Created by Samuel Défago on 03.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSTextView.h"

#import "HLSFloat.h"
#import "HLSLabel.h"
#import "UIView+HLSExtensions.h"

@interface HLSTextView ()

- (void)hlsTextViewInit;

@property (nonatomic, retain) HLSLabel *placeholderLabel;

- (void)updatePlaceholderLabelVisibility;

- (void)textChanged:(NSNotification *)notification;

@end

@implementation HLSTextView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsTextViewInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsTextViewInit];
    }
    return self;
}

- (void)hlsTextViewInit
{
    // For a perfect result, the placeholder is drawn exactly where the text view text is drawn
    const CGFloat kMargin = 8.f;
    CGRect bounds = CGRectMake(kMargin,
                               kMargin,
                               floatmax(CGRectGetWidth(self.bounds) - 2 * kMargin, 0.f),
                               floatmax(CGRectGetHeight(self.bounds) - 2 * kMargin, 0.f));
    self.placeholderLabel = [[[HLSLabel alloc] initWithFrame:bounds] autorelease];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.verticalAlignment = HLSLabelVerticalAlignmentTop;
    self.placeholderLabel.numberOfLines = NSIntegerMax;
    self.placeholderLabel.autoresizingMask = HLSViewAutoresizingAll;
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self insertSubview:self.placeholderLabel atIndex:0];
    [self updatePlaceholderLabelVisibility];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.placeholderLabel = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize placeholderLabel = _placeholderLabel;

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self updatePlaceholderLabelVisibility];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeholderLabel.font = font;
}

- (NSString *)placeholderText
{
    return self.placeholderLabel.text;
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    self.placeholderLabel.text = placeholderText;
}

- (UIColor *)placeholderTextColor
{
    return self.placeholderLabel.textColor;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    self.placeholderLabel.textColor = placeholderTextColor;
}

#pragma mark Placeholder management

- (void)updatePlaceholderLabelVisibility
{
    if ([self.text length] == 0) {
        self.placeholderLabel.hidden = NO;
    }
    else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark Notification callbacks

- (void)textChanged:(NSNotification *)notification
{
    [self updatePlaceholderLabelVisibility];
}

@end
