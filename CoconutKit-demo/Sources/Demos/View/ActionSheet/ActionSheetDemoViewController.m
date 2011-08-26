//
//  ActionSheetDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ActionSheetDemoViewController.h"

@interface ActionSheetDemoViewController ()

- (HLSActionSheet *)actionSheetForChoice;

- (void)choose1:(id)sender;
- (void)choose2:(id)sender;
- (void)choose3:(id)sender;
- (void)choose4:(id)sender;
- (void)resetChoice:(id)sender;

@end

@implementation ActionSheetDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.showFromRectButton = nil;
    self.showInViewButton = nil;
    self.toolbar = nil;
    self.showFromToolbarBarButtonItem = nil;
    self.showFromBarButtonItemBarButtonItem = nil;
    self.choiceLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize showFromRectButton = m_showFromRectButton;

@synthesize showInViewButton = m_showInViewButton;

@synthesize toolbar = m_toolbar;

@synthesize showFromToolbarBarButtonItem = m_showFromToolbarBarButtonItem;

@synthesize showFromBarButtonItemBarButtonItem = m_showFromBarButtonItemBarButtonItem;

@synthesize choiceLabel = m_choiceLabel;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.choiceLabel.text = @"0";
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Action sheet", @"Action sheet");
    [self.showFromRectButton setTitle:NSLocalizedString(@"Choose", @"Choose") forState:UIControlStateNormal];
    [self.showInViewButton setTitle:NSLocalizedString(@"Choose", @"Choose") forState:UIControlStateNormal];
    self.showFromToolbarBarButtonItem.title = NSLocalizedString(@"Choose", @"Choose");
    self.showFromBarButtonItemBarButtonItem.title = NSLocalizedString(@"Choose", @"Choose");
}

#pragma mark Common action sheet code

- (HLSActionSheet *)actionSheetForChoice
{
    HLSActionSheet *actionSheet = [[[HLSActionSheet alloc] init] autorelease];
    [actionSheet addDestructiveButtonWithTitle:NSLocalizedString(@"Reset", @"Reset") 
                                        target:self
                                        action:@selector(resetChoice:)];
    [actionSheet addButtonWithTitle:@"1"
                             target:self
                             action:@selector(choose1:)];
    [actionSheet addButtonWithTitle:@"2"
                             target:self
                             action:@selector(choose2:)];
    [actionSheet addButtonWithTitle:@"3"
                             target:self
                             action:@selector(choose3:)];
    [actionSheet addButtonWithTitle:@"4"
                             target:self
                             action:@selector(choose4:)];
    return actionSheet;
}

#pragma mark Event callbacks

- (IBAction)makeChoiceFromRect:(id)sender
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromRect:self.showFromRectButton.frame
                       inView:self.view 
                     animated:YES];
}

- (IBAction)makeChoiceInView:(id)sender
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showInView:self.view];
}

- (IBAction)makeChoiceFromToolbar:(id)sender
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromToolbar:self.toolbar];
}

- (IBAction)makeChoiceFromBarButtonItem:(id)sender
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromBarButtonItem:self.showFromBarButtonItemBarButtonItem 
                              animated:YES];
}

- (void)choose1:(id)sender
{
    self.choiceLabel.text = @"1";
}

- (void)choose2:(id)sender
{
    self.choiceLabel.text = @"2";
}

- (void)choose3:(id)sender
{
    self.choiceLabel.text = @"3";
}

- (void)choose4:(id)sender
{
    self.choiceLabel.text = @"4";
}

- (void)resetChoice:(id)sender
{
    self.choiceLabel.text = @"0";
}

@end
