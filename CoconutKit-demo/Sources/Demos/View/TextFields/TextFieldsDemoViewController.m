//
//  TextFieldsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TextFieldsDemoViewController.h"

@implementation TextFieldsDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.textField1 = nil;
    self.textField2 = nil;
    self.textField3 = nil;
    self.textField4 = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    self.textField3.delegate = self;
    self.textField4.delegate = self;
    
    self.textField2.resigningFirstResponderOnTap = NO;
}

#pragma mark Accessors and mutators

@synthesize textField1 = _textField1;

@synthesize textField2 = _textField2;

@synthesize textField3 = _textField3;

@synthesize textField4 = _textField4;

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];

    self.title = NSLocalizedString(@"Text fields", @"Text fields");
}

@end
