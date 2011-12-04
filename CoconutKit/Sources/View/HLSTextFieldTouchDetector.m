//
//  HLSTextFieldTouchDetector.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSTextFieldTouchDetector.h"

#import "HLSAssert.h"
#import "NSObject+HLSExtensions.h"

@interface HLSTextFieldTouchDetector ()

@property (nonatomic, assign) UITextField *textField;       // weak ref. Detector lifetime is managed by the text field
@property (nonatomic, retain) UIGestureRecognizer *gestureRecognizer;

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation HLSTextFieldTouchDetector

#pragma mark Class methods

+ (void)initialize
{
    if (self != [HLSTextFieldTouchDetector class]) {
        return;
    }
    
    NSAssert([self implementsProtocol:@protocol(UITextFieldDelegate)], @"Incomplete implementation");
}

#pragma mark Object creation and destruction

- (id)initWithTextField:(UITextField *)textField
{
    if ((self = [super init])) {
        self.textField = textField;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.textField = nil;
    self.gestureRecognizer = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize textField = m_textField;

@synthesize gestureRecognizer = m_gestureRecognizer;

@synthesize delegate = m_delegate;

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [self.delegate textFieldShouldBeginEditing:textField];
    }
    else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:textField];
    }
    
    // Add a gesture recognizer capturing taps on the whole window
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(dismissKeyboard:)];
    self.gestureRecognizer.cancelsTouchesInView = NO;       // Let the taps go through
    
    [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:self.gestureRecognizer];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        if (! [self.delegate textFieldShouldEndEditing:textField]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:textField];
    }
    
    [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:self.gestureRecognizer]; 
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if (! [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [self.delegate textFieldShouldClear:textField];
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSAssert(self.textField == textField, @"Text field mismatch");
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.delegate textFieldShouldReturn:textField];
    }
    else {
        return YES;
    }
}

#pragma mark Event callbacks

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    // Dismiss the keyboard
    [self.textField resignFirstResponder];
}

@end
