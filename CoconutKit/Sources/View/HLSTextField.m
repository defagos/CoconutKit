//
//  HLSTextField.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/12/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTextField.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSTextFieldTouchDetector.h"

// The minimal distance to be kept between the active text field and the top of the scroll view top or the keyboard. If the
// scroll view area is too small to fulfill both, visibility at the top wins
const CGFloat kTextFieldMinVisibilityDistance = 20.f;           // Corresponds to IB guides

@interface HLSTextField ()

@property (nonatomic, retain) HLSTextFieldTouchDetector *touchDetector;

@end

@implementation HLSTextField

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsTextFieldInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsTextFieldInit];
    }
    return self;
}

// Common initialization code
- (void)hlsTextFieldInit
{
    self.minVisibilityDistance = kTextFieldMinVisibilityDistance;
    
    self.touchDetector = [[[HLSTextFieldTouchDetector alloc] initWithTextField:self] autorelease];
    super.delegate = self.touchDetector;
}

- (void)dealloc
{
    self.touchDetector = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark Accessors and mutators

- (void)setTextFieldMinVisibilityDistance:(CGFloat)minVisibilityDistance
{
    // Sanitize input
    if (floatlt(minVisibilityDistance, 0.f)) {
        HLSLoggerWarn(@"Invalid value; must be positive");
        _minVisibilityDistance = 0.f;
    }
    else {
        _minVisibilityDistance = minVisibilityDistance;
    }
}

- (BOOL)resigningFirstResponderOnTap
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    return touchDetector.resigningFirstResponderOnTap;
}

- (void)setResigningFirstResponderOnTap:(BOOL)resigningFirstResponderOnTap
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    touchDetector.resigningFirstResponderOnTap = resigningFirstResponderOnTap;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    touchDetector.delegate = delegate;
}

- (id<UITextFieldDelegate>)delegate
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    return touchDetector.delegate;
}

@end
