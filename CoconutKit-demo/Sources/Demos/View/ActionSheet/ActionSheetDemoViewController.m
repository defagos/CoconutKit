//
//  ActionSheetDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ActionSheetDemoViewController.h"

@interface ActionSheetDemoViewController ()

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
    
    self.actionSheetButton = nil;
    self.choiceLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize actionSheetButton = m_actionSheetButton;

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
    [self.actionSheetButton setTitle:NSLocalizedString(@"Choose", @"Choose") forState:UIControlStateNormal];
}

#pragma mark Event callbacks

- (IBAction)makeChoice:(id)sender
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
    [actionSheet showFromRect:self.actionSheetButton.frame
                       inView:self.view 
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
