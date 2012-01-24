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
- (void)choose3;
- (void)choose4;

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
    
    self.toolbar = nil;
    self.choiceLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize toolbar = m_toolbar;

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
                             action:@selector(choose3)];
    [actionSheet addButtonWithTitle:@"4"
                             target:self
                             action:@selector(choose4)];
    return actionSheet;
}

#pragma mark Event callbacks

- (IBAction)makeChoiceFromRectAnimated:(id)sender
{
    UIButton *button = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromRect:button.frame
                       inView:self.view 
                     animated:YES];
}

- (IBAction)makeChoiceFromRectNotAnimated:(id)sender
{
    UIButton *button = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromRect:button.frame
                       inView:self.view 
                     animated:NO];
}

// Test methods without parameter (checks UIBarButtonItem+HLSActionSheet implementation correctness)
- (IBAction)makeChoiceInView
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showInView:self.view];
}

- (IBAction)makeChoiceFromToolbar:(id)sender
{
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromToolbar:self.toolbar];
}

- (IBAction)makeChoiceFromBarButtonItemAnimated:(id)sender
{
    UIBarButtonItem *barButtonItem = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromBarButtonItem:barButtonItem
                              animated:YES];
}

- (IBAction)makeChoiceFromBarButtonItemNotAnimated:(id)sender
{
    UIBarButtonItem *barButtonItem = sender;
    HLSActionSheet *actionSheet = [self actionSheetForChoice];
    [actionSheet showFromBarButtonItem:barButtonItem
                              animated:NO];
}

- (void)choose1:(id)sender
{
    self.choiceLabel.text = @"1";
}

- (void)choose2:(id)sender
{
    self.choiceLabel.text = @"2";
}

- (void)choose3
{
    self.choiceLabel.text = @"3";
}

- (void)choose4
{
    self.choiceLabel.text = @"4";
    HLSActionSheet *actionSheet = [[[HLSActionSheet alloc] init] autorelease];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Yes", @"Yes") target:nil action:NULL];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"No", @"No") target:nil action:NULL];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") target:self action:@selector(cancel)];
    }
    [actionSheet showInView:self.view];
}

- (void)cancel
{
    self.choiceLabel.text = nil;
}

- (void)resetChoice:(id)sender
{
    self.choiceLabel.text = @"0";
}

@end
