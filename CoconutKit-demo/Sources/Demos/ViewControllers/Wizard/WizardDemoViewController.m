//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "WizardDemoViewController.h"

#import "WizardAddressPageViewController.h"
#import "WizardIdentityPageViewController.h"

@implementation WizardDemoViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
        self.wizardTransitionStyle = HLSWizardTransitionStylePushHorizontally; 
        
        WizardIdentityPageViewController *wizardIdentityPageController = [[WizardIdentityPageViewController alloc] init];
        WizardAddressPageViewController *wizardAddressPageController = [[WizardAddressPageViewController alloc] init];
        self.viewControllers = @[wizardIdentityPageController, wizardAddressPageController];
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [HLSModelManager rollbackCurrentModelContext];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark HLSWizardViewControllerDelegate protocol implementation

- (void)wizardViewControllerHasClickedDoneButton:(HLSWizardViewController *)wizardViewController
{
    NSError *error = nil;
    if (! [HLSModelManager saveCurrentModelContext:&error]) {
        [HLSModelManager rollbackCurrentModelContext];
        HLSLoggerError(@"Failed to save context; reason: %@", error);        
    }
            
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"WizardDemoViewController";
}

@end
