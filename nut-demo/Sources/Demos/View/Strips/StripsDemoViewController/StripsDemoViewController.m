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
    self.userInteractionLabel = nil;
    self.userInteractionSwitch = nil;
    self.clearButton = nil;
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

@synthesize userInteractionLabel = m_userInteractionLabel;

@synthesize userInteractionSwitch = m_userInteractionSwitch;

@synthesize clearButton = m_clearButton;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stripContainerView.positions = 50;
    self.stripContainerView.delegate = self;
    
    // Start with two strips (can be set in any order)
    HLSStrip *strip1 = [HLSStrip stripWithBeginPosition:20 endPosition:30];
    HLSStrip *strip2 = [HLSStrip stripWithBeginPosition:3 endPosition:10];
    [self.stripContainerView setStrips:[NSArray arrayWithObjects:strip1, strip2, nil]];
    
    self.infoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Valid positions: 0 - %d", @"Valid positions: 0 - %d"), 
                           self.stripContainerView.positions - 1];
    
    self.addLabel.text = NSLocalizedString(@"Add (center - length)", @"Add (center - length)");
    self.splitlabel.text = NSLocalizedString(@"Split (position)", @"Split (position)");
    self.deleteAtPositionLabel.text = NSLocalizedString(@"Delete (position)", @"Delete (position)");
    self.deleteAtIndexLabel.text = NSLocalizedString(@"Delete (index)", @"Delete (index)");
    
    self.addBeginPositionTextField.delegate = self;
    self.addLengthTextField.delegate = self;
    self.splitPositionTextField.delegate = self;
    self.deletePositionTextField.delegate = self;
    self.deleteIndexTextField.delegate = self;
    
    self.addBeginPositionTextField.text = @"0";
    self.addLengthTextField.text = @"0";
    self.splitPositionTextField.text = @"0";
    self.deletePositionTextField.text = @"0";
    self.deleteIndexTextField.text = @"0";
    
    self.userInteractionLabel.text = NSLocalizedString(@"User interaction", @"User interaction");
    
    self.userInteractionSwitch.on = self.stripContainerView.userInteractionEnabled;
    
    [self.clearButton setTitle:NSLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark HLSStripContainerViewDelegate protocol implementation

- (void)stripContainerView:(HLSStripContainerView *)stripContainerView didAddStrip:(HLSStrip *)strip
{

}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Event callbacks

- (IBAction)addStrip:(id)sender
{
    NSUInteger beginPosition = (NSUInteger)[self.addBeginPositionTextField.text intValue];
    NSUInteger length = (NSUInteger)[self.addLengthTextField.text intValue];
    
    [self.stripContainerView addStripAtPosition:beginPosition length:length animated:YES];
}

- (IBAction)splitStrip:(id)sender
{
    NSUInteger splitPosition = (NSUInteger)[self.splitPositionTextField.text intValue];
    
    [self.stripContainerView splitStripAtPosition:splitPosition animated:YES];
}

- (IBAction)deleteStripAtPosition:(id)sender
{
    NSUInteger deletePosition = (NSUInteger)[self.deletePositionTextField.text intValue];
    
    [self.stripContainerView deleteStripsAtPosition:deletePosition animated:YES];
}

- (IBAction)deleteStripAtIndex:(id)sender
{
    NSUInteger deleteIndex = (NSUInteger)[self.deleteIndexTextField.text intValue];
    
    [self.stripContainerView deleteStripWithIndex:deleteIndex animated:YES];
}

- (IBAction)toggleUserInteraction:(id)sender
{
    self.stripContainerView.userInteractionEnabled = self.userInteractionSwitch.on;
}

- (IBAction)clearStrips:(id)sender
{
    [self.stripContainerView clear];
}

@end
