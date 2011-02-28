//
//  WizardDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "WizardDemoViewController.h"

@implementation WizardDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

@end
