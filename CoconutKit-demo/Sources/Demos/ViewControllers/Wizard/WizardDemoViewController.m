//
//  WizardDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "WizardDemoViewController.h"

#import "WizardAddressPageViewController.h"
#import "WizardIdentityPageViewController.h"

@implementation WizardDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        self.delegate = self;
        self.wizardTransitionStyle = HLSWizardTransitionStylePushHorizontally; 
        
        WizardIdentityPageViewController *wizardIdentityPageController = [[[WizardIdentityPageViewController alloc] init] autorelease];
        WizardAddressPageViewController *wizardAddressPageController = [[[WizardAddressPageViewController alloc] init] autorelease];
        self.viewControllers = [NSArray arrayWithObjects:wizardIdentityPageController,
                                                    wizardAddressPageController,
                                                    nil];
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [HLSModelManager rollbackDefaultModelContext];
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
    NSError *error = nil;
    if (! [HLSModelManager saveDefaultModelContext:&error]) {
        [HLSModelManager rollbackDefaultModelContext];
        HLSLoggerError(@"Failed to save context; reason: %@", error);        
    }
            
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"WizardDemoViewController";
    [self.previousButton setTitle:NSLocalizedString(@"Previous", @"Previous") forState:UIControlStateNormal];
    [self.nextButton setTitle:NSLocalizedString(@"Next", @"Next") forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"Done", @"Done") forState:UIControlStateNormal];
}

@end
