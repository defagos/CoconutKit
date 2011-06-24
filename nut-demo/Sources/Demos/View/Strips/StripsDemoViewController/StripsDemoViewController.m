//
//  StripsDemoViewController.m
//  nut-dev
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StripsDemoViewController.h"

@implementation StripsDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Strips", @"Strips");
    }
    return self;
}

- (void)dealloc
{
    // Code
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.stripContainerView = nil;
    self.infoLabel = nil;
    self.addLabel = nil;
    self.addBeginPositionTextField = nil;
    self.addLengthTextField = nil;
    self.addButton = nil;
    self.splitlabel = nil;
    self.splitPositionTextField = nil;
    self.splitButton = nil;
    self.deleteAtPositionLabel = nil;
    self.deletePositionTextField = nil;
    self.deleteAtPositionButton = nil;
    self.deleteAtIndexLabel = nil;
    self.deleteIndexTextField = nil;
    self.deleteAtIndexButton = nil;
}

#pragma mark Accessors and mutators

@synthesize stripContainerView = m_stripContainerView;

@synthesize infoLabel = m_infoLabel;

@synthesize addLabel = m_addLabel;

@synthesize addBeginPositionTextField = m_addBeginPositionTextField;

@synthesize addLengthTextField = m_addLengthTextField;

@synthesize addButton = m_addButton;

@synthesize splitlabel = m_splitlabel;

@synthesize splitPositionTextField = m_splitPositionTextField;

@synthesize splitButton = m_splitButton;

@synthesize deleteAtPositionLabel = m_deleteAtPositionLabel;

@synthesize deletePositionTextField = m_deletePositionTextField;

@synthesize deleteAtPositionButton = m_deleteAtPositionButton;

@synthesize deleteAtIndexLabel = m_deleteAtIndexLabel;

@synthesize deleteIndexTextField = m_deleteIndexTextField;

@synthesize deleteAtIndexButton = m_deleteAtIndexButton;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stripContainerView.positions = 50;

    self.infoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Valid positions: 0 - %d", @"Valid positions: 0 - %d"), 
                           self.stripContainerView.positions - 1];
    
    self.addLabel.text = NSLocalizedString(@"Add (begin - length)", @"Add (begin - length)");
    self.splitlabel.text = NSLocalizedString(@"Split (position)", @"Split (position)");
    self.deleteAtPositionLabel.text = NSLocalizedString(@"Delete (position)", @"Delete (position)");
    self.deleteAtIndexLabel.text = NSLocalizedString(@"Delete (index)", @"Delete (index)");
    
    self.addBeginPositionTextField.delegate = self;
    self.addLengthTextField.delegate = self;
    self.splitPositionTextField.delegate = self;
    self.deleteIndexTextField.delegate = self;
    self.deleteIndexTextField.delegate = self;
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Event callbacks

- (IBAction)addStrip
{
    NSUInteger beginPosition = (NSUInteger)[self.addBeginPositionTextField.text intValue];
    NSUInteger length = (NSUInteger)[self.addLengthTextField.text intValue];
    
    [self.stripContainerView addStripAtPosition:beginPosition length:length];
}

- (IBAction)splitStrip
{
    NSUInteger splitPosition = (NSUInteger)[self.splitPositionTextField.text intValue];
    
    [self.stripContainerView splitStripAtPosition:splitPosition];
}

- (IBAction)deleteStripAtPosition
{
    NSUInteger deletePosition = (NSUInteger)[self.deletePositionTextField.text intValue];
    
    [self.stripContainerView deleteStripsAtPosition:deletePosition];
}

- (IBAction)deleteStripAtIndex
{
    NSUInteger deleteIndex = (NSUInteger)[self.deleteIndexTextField.text intValue];
    
    [self.stripContainerView deleteStripWithIndex:deleteIndex];
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
