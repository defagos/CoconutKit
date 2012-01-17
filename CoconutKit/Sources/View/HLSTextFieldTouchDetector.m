//
//  HLSTextFieldTouchDetector.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSTextFieldTouchDetector.h"

@interface HLSTextFieldTouchDetector ()

@property (nonatomic, retain) UIGestureRecognizer *gestureRecognizer;

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation HLSTextFieldTouchDetector

#pragma mark Object creation and destruction

- (id)initWithTextField:(UITextField *)textField
{
    if ((self = [super initWithTextField:textField])) {
        // Create a gesture recognizer capturing taps on the whole window
        self.gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)] autorelease];
        self.gestureRecognizer.cancelsTouchesInView = NO;       // Let the taps go through
        
        self.resigningFirstResponderOnTap = YES;
    }
    return self;
}

- (void)dealloc
{
    self.gestureRecognizer = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize gestureRecognizer = m_gestureRecognizer;

@synthesize resigningFirstResponderOnTap = m_resigningFirstResponderOnTap;

#pragma mark UITextFieldDelegate protocol implementation

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
    
    [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:self.gestureRecognizer];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    
    [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:self.gestureRecognizer]; 
}

#pragma mark Event callbacks

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.resigningFirstResponderOnTap) {
        // Dismiss the keyboard
        [self.textField resignFirstResponder];        
    }
}

@end
