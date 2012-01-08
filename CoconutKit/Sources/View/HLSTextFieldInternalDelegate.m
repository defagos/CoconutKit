//
//  HLSTextFieldInternalDelegate.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSTextFieldInternalDelegate.h"

#import "HLSAssert.h"
#import "NSObject+HLSExtensions.h"

@interface HLSTextFieldInternalDelegate ()

@property (nonatomic, assign) UITextField *textField;       // weak ref. Detector lifetime is managed by the text field

@end

@implementation HLSTextFieldInternalDelegate

#pragma mark Class methods

+ (void)initialize
{
    if (self != [HLSTextFieldInternalDelegate class]) {
        return;
    }
    
    // Ensure that our protocol implementation stays complete as UIKit evolves
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
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize textField = m_textField;

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

@end
