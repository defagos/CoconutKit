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

#pragma mark Notification callbacks

/**
 * Extremely important: When rotating the interface with the keyboard enabled, the willShow event is fired after the new
 * orientation has been installed, i.e. coordinates are relative to the new orientation
 */
+ (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"Will show");
}

+ (void)keyboardDidShow:(NSNotification *)notification
{
    NSLog(@"Did show");
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"Will hide");
}

+ (void)keyboardDidHide:(NSNotification *)notification
{
    NSLog(@"Did hide");
}

@end

__attribute__ ((constructor)) static void HLSTextFieldInit(void)
{
    // Those events are only fired when the dock keyboard is used. When the keyboard rotates, we receive willHide, didHide,
    // willShow and didShow in sequence
    [[NSNotificationCenter defaultCenter] addObserver:[HLSTextField class]
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[HLSTextField class]
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[HLSTextField class]
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[HLSTextField class]
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}
