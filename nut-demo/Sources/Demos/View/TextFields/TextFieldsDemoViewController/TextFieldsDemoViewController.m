//
//  TextFieldsDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 HLSXibView. All rights reserved.
//

#import "TextFieldsDemoViewController.h"

@interface TextFieldsDemoViewController ()

- (void)releaseViews;

@end

@implementation TextFieldsDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.title = NSLocalizedString(@"Text fields", @"Text fields");
    }
    return self;
}

- (void)dealloc
{
    [self releaseViews];
    [super dealloc];
}

- (void)releaseViews
{
    self.textField1 = nil;
    self.textField2 = nil;
    self.textField3 = nil;
    self.textField4 = nil;
}

#pragma mark View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViews];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Accessors and mutators

@synthesize textField1 = m_textField1;

@synthesize textField2 = m_textField2;

@synthesize textField3 = m_textField3;

@synthesize textField4 = m_textField4;

@end
