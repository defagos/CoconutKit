//
//  HLSTextField.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/12/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTextField.h"

#import "HLSTextFieldTouchDetector.h"

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
    self.touchDetector = [[[HLSTextFieldTouchDetector alloc] initWithTextField:self] autorelease];
    super.delegate = self.touchDetector;
}

- (void)dealloc
{
    self.touchDetector = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

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
