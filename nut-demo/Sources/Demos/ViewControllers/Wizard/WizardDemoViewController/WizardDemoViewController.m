//
//  WizardDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "WizardDemoViewController.h"

#import "MemoryWarningTestCoverViewController.h"

@implementation WizardDemoViewController

#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"WizardDemoViewController";
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wizardTransitionStyle = HLSWizardTransitionStylePushHorizontally;
    
    [self.previousButton setTitle:NSLocalizedString(@"Previous", @"Previous") 
                         forState:UIControlStateNormal];
    [self.nextButton setTitle:NSLocalizedString(@"Next", @"Next") 
                     forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"Done", @"Done") 
                     forState:UIControlStateNormal];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark HLSWizardViewControllerDelegate protocol implementation

- (void)wizardViewControllerHasClickedDoneButton:(HLSWizardViewController *)wizardViewController
{
    MemoryWarningTestCoverViewController *memoryWarningTestViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    [self presentModalViewController:memoryWarningTestViewController animated:YES];
}

@end
